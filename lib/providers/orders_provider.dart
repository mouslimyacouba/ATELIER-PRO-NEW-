import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/firestore_errors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/payment.dart';
import '../models/historique_entry.dart';
import '../core/notification_service.dart';
import 'stock_provider.dart';
import 'modeles_provider.dart';
import 'package:provider/provider.dart';

class OrdersProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _paymentsSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _historiqueSub;
  String? _currentUserId;

  List<AtelierOrder> _orders = [];
  List<AtelierPayment> _payments = [];
  List<HistoriqueEntry> _historique = [];
  bool _loading = false;
  String? _error;

  List<AtelierOrder> get orders => _orders;
  List<AtelierPayment> get payments => _payments;
  List<HistoriqueEntry> get historique => _historique;
  bool get loading => _loading;
  String? get error => _error;

  List<AtelierOrder> byStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  double get chiffreAffairesTotal =>
      _orders.fold(0, (sum, o) => sum + o.prixTotal);

  double get montantRestantDu => _orders.fold(0, (sum, o) => sum + o.remaining);

  List<AtelierOrder> get enRetard {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return _orders.where((o) {
      if (o.dateEcheance == null) return false;
      if (o.status == OrderStatus.livre) return false;
      return o.dateEcheance!.isBefore(todayOnly);
    }).toList();
  }

  List<AtelierPayment> paymentsForOrder(String orderId) =>
      _payments.where((p) => p.commandeId == orderId).toList();

  List<AtelierPayment> paymentsForClient(String clientId) =>
      _payments.where((p) => p.clientId == clientId).toList();

  List<HistoriqueEntry> historiqueForOrder(String orderId) {
    final list = _historique.where((h) => h.commandeId == orderId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  @override
  void dispose() {
    _ordersSub?.cancel();
    _paymentsSub?.cancel();
    _historiqueSub?.cancel();
    super.dispose();
  }

  Future<void> load(String userId) {
    if (_currentUserId == userId && _ordersSub != null) {
      return Future.value();
    }
    _currentUserId = userId;
    _loading = true;
    notifyListeners();

    final completer = Completer<void>();

    _ordersSub?.cancel();
    _ordersSub = _firestore
        .collection('commandes')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _orders = snapshot.docs
            .map((d) => AtelierOrder.fromMap(d.id, d.data()))
            .toList();
        _orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _loading = false;
        _error = null;
        notifyListeners();
        NotificationService.syncReminders(_orders);
        if (!completer.isCompleted) completer.complete();
      },
      onError: (e) {
        _error = friendlyFirestoreError(e);
        _loading = false;
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
    );

    _paymentsSub?.cancel();
    _paymentsSub = _firestore
        .collection('paiements')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _payments = snapshot.docs
            .map((d) => AtelierPayment.fromMap(d.id, d.data()))
            .toList();
        _payments.sort((a, b) => b.datePaiement.compareTo(a.datePaiement));
        notifyListeners();
      },
      onError: (e) {
        _payments = [];
        _error = friendlyFirestoreError(e);
        notifyListeners();
      },
    );

    _historiqueSub?.cancel();
    _historiqueSub = _firestore
        .collection('historique_modifications')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _historique = snapshot.docs
            .map((d) => HistoriqueEntry.fromMap(d.id, d.data()))
            .toList();
        notifyListeners();
      },
      onError: (e) {
        _historique = [];
        notifyListeners();
      },
    );

    return completer.future;
  }

  Future<String?> createOrder(AtelierOrder order,
      {StockProvider? stockProvider, List<String>? materiauxDefaut}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      debugPrint('========== CREATION COMMANDE ==========');
      debugPrint('Firebase UID : ${currentUser?.uid}');
      debugPrint('Order UID   : ${order.userId}');
      debugPrint('========================================');

      if (currentUser == null) {
        return 'Utilisateur non connecté.';
      }

      if (currentUser.uid != order.userId) {
        return 'Erreur utilisateur : l’atelier ne correspond pas au compte connecté.';
      }

      final docRef = _firestore.collection('commandes').doc();
      final compteurRef = _firestore.collection('compteurs').doc(order.userId);

      // Utilisation de runTransaction() sur tous les supports (Web inclus).
      // cloud_firestore ^5.x supporte les transactions Web — la branche
      // kIsWeb séquentielle était obsolète et présentait deux risques :
      // 1. Non-atomicité : compteur incrémenté même si l'écriture commande échoue.
      // 2. Sur Flutter Web, les deux .set() séquentiels pouvaient déclencher
      //    une FirebaseException selon le contexte de sérialisation JS.
      await _firestore.runTransaction((transaction) async {
        final compteurSnap = await transaction.get(compteurRef);

        int nouveauNumero = 1;

        if (compteurSnap.exists && compteurSnap.data() != null) {
          nouveauNumero =
              (compteurSnap.data()!['dernierNumero'] as num? ?? 0).toInt() + 1;
        }

        final map = order.toInsertMap();
        map['numero'] = nouveauNumero;

        transaction.set(
          compteurRef,
          {
            'dernierNumero': nouveauNumero,
            'updatedAt': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        transaction.set(docRef, map);
      });

      if (stockProvider != null &&
          materiauxDefaut != null &&
          materiauxDefaut.isNotEmpty) {
        try {
          final listConsommes =
              materiauxDefaut.map((m) => {'nom': m, 'quantite': 1.0}).toList();
          await stockProvider.consommerMateriaux(order.userId, listConsommes);
        } catch (_) {}
      }

      debugPrint('Commande créée avec succès : ${docRef.id}');
      return null;
    } on FirebaseException catch (e, stackTrace) {
      debugPrint('========== FIREBASE ERROR ==========');
      debugPrint('CODE    : ${e.code}');
      debugPrint('MESSAGE : ${e.message}');
      debugPrint('PLUGIN  : ${e.plugin}');
      debugPrint('STACK   : $stackTrace');
      debugPrint('====================================');

      return '${e.code} : ${e.message ?? "Erreur Firestore"}';
    } catch (e, stackTrace) {
      debugPrint('========== ERROR ==========');
      debugPrint('ERROR : $e');
      debugPrint('STACK : $stackTrace');
      debugPrint('============================');

      return e.toString();
    }
  }

  Future<void> _enregistrerHistorique({
    required String userId,
    required String commandeId,
    required String champModifie,
    String? ancienneValeur,
    String? nouvelleValeur,
  }) async {
    if (ancienneValeur == nouvelleValeur) return;
    await _firestore.collection('historique_modifications').add(
          HistoriqueEntry(
            id: '',
            userId: userId,
            commandeId: commandeId,
            champModifie: champModifie,
            ancienneValeur: ancienneValeur,
            nouvelleValeur: nouvelleValeur,
            createdAt: DateTime.now(),
          ).toInsertMap(),
        );
  }

  Future<String?> updateStatus(String orderId, OrderStatus status) async {
    try {
      final order = byId(orderId);
      await _firestore.collection('commandes').doc(orderId).update(
          {'statut': status.value, 'updatedAt': FieldValue.serverTimestamp()});
      if (order != null && order.status != status) {
        await _enregistrerHistorique(
          userId: order.userId,
          commandeId: orderId,
          champModifie: 'statut',
          ancienneValeur: order.status.label,
          nouvelleValeur: status.label,
        );
      }
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> updateOrder(
    String orderId, {
    String? description,
    double? prixTotal,
    DateTime? dateEcheance,
    String? ficheMesureId,
    String? modeleId,
    List<Map<String, dynamic>>? etapesSnapshot,
  }) async {
    try {
      final avant = byId(orderId);
      final changes = <String, dynamic>{
        if (description != null) 'description': description,
        if (prixTotal != null) 'prixTotal': prixTotal,
        if (dateEcheance != null)
          'dateEcheance': Timestamp.fromDate(dateEcheance),
        // Ne mettre à jour ficheId que si explicitement fourni — null signifie
        // "pas de changement demandé", pas "détacher la fiche".
        if (ficheMesureId != null) 'ficheId': ficheMesureId,
        if (modeleId != null) 'modeleId': modeleId,
        if (etapesSnapshot != null) 'etapesSnapshot': etapesSnapshot,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('commandes').doc(orderId).update(changes);

      if (avant != null) {
        if (description != null) {
          await _enregistrerHistorique(
            userId: avant.userId,
            commandeId: orderId,
            champModifie: 'description',
            ancienneValeur: avant.description,
            nouvelleValeur: description,
          );
        }
        if (prixTotal != null) {
          await _enregistrerHistorique(
            userId: avant.userId,
            commandeId: orderId,
            champModifie: 'prixTotal',
            ancienneValeur: avant.prixTotal.toStringAsFixed(0),
            nouvelleValeur: prixTotal.toStringAsFixed(0),
          );
        }
        if (dateEcheance != null) {
          await _enregistrerHistorique(
            userId: avant.userId,
            commandeId: orderId,
            champModifie: 'dateEcheance',
            ancienneValeur: avant.dateEcheance?.toIso8601String(),
            nouvelleValeur: dateEcheance.toIso8601String(),
          );
        }
      }
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> toggleEtape(
      String orderId, String etapeId, bool terminee) async {
    try {
      final order = byId(orderId);
      if (order == null) return null;
      final etapes =
          List<Map<String, dynamic>>.from(order.etapesSnapshot ?? []);
      final index = etapes.indexWhere((e) => e['id'] == etapeId);
      if (index == -1) return null;
      etapes[index] = {...etapes[index], 'terminee': terminee};
      await _firestore.collection('commandes').doc(orderId).update({
        'etapesSnapshot': etapes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> addPhoto(String orderId, String url) async {
    try {
      await _firestore.collection('commandes').doc(orderId).update({
        'photoUrls': FieldValue.arrayUnion([url]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> removePhoto(String orderId, String url) async {
    try {
      await _firestore.collection('commandes').doc(orderId).update({
        'photoUrls': FieldValue.arrayRemove([url]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> deleteOrder(String orderId) async {
    try {
      final batch = _firestore.batch();
      for (final p in _payments.where((p) => p.commandeId == orderId)) {
        batch.delete(_firestore.collection('paiements').doc(p.id));
      }
      for (final h in _historique.where((h) => h.commandeId == orderId)) {
        batch.delete(
            _firestore.collection('historique_modifications').doc(h.id));
      }
      batch.delete(_firestore.collection('commandes').doc(orderId));
      await batch.commit();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> recordPayment({
    required String orderId,
    required String userId,
    required double amount,
    required String mode,
  }) async {
    try {
      final order = byId(orderId);
      final paymentRef = _firestore.collection('paiements').doc();
      final orderRef = _firestore.collection('commandes').doc(orderId);

      final batch = _firestore.batch();
      batch.set(
        paymentRef,
        AtelierPayment(
          id: '',
          userId: userId,
          commandeId: orderId,
          clientId: order?.clientId ?? '',
          montant: amount,
          mode: mode,
          datePaiement: DateTime.now(),
          createdAt: DateTime.now(),
        ).toInsertMap(),
      );
      batch.update(orderRef, {
        'acompte': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  AtelierOrder? byId(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
