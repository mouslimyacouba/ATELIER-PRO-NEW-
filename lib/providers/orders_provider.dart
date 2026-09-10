import 'dart:async';
import '../core/firestore_errors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/payment.dart';

class OrdersProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _paymentsSub;
  String? _currentUserId;

  List<AtelierOrder> _orders = [];
  List<AtelierPayment> _payments = [];
  bool _loading = false;
  String? _error;

  List<AtelierOrder> get orders => _orders;
  List<AtelierPayment> get payments => _payments;
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

  /// Paiements d'une commande — simple filtre local (plus de requête réseau
  /// à chaque ouverture d'écran), car tous les paiements de l'atelier sont
  /// déjà tenus à jour en mémoire par l'écoute temps réel de `load()`.
  List<AtelierPayment> paymentsForOrder(String orderId) =>
      _payments.where((p) => p.commandeId == orderId).toList();

  /// Tous les paiements d'un client, tous secteurs/commandes confondus —
  /// utilisé pour la timeline d'activité sur la fiche client. Même principe :
  /// filtre local, pas de requête réseau.
  List<AtelierPayment> paymentsForClient(String clientId) =>
      _payments.where((p) => p.clientId == clientId).toList();

  @override
  void dispose() {
    _ordersSub?.cancel();
    _paymentsSub?.cancel();
    super.dispose();
  }

  /// S'abonne en temps réel aux commandes ET aux paiements de cet
  /// utilisateur. Tenir les paiements en mémoire (plutôt que de les
  /// requêter à la demande par commande/client) simplifie l'affichage de
  /// l'historique — qui devient un simple filtre local, toujours à jour
  /// sans rechargement manuel.
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

    return completer.future;
  }

  Future<String?> createOrder(AtelierOrder order) async {
    try {
      await _firestore.collection('commandes').add(order.toInsertMap());
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> updateStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('commandes').doc(orderId).update(
          {'statut': status.value, 'updatedAt': FieldValue.serverTimestamp()});
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  /// Modifie la description, le montant total et/ou la fiche liée.
  /// Ne touche pas à `acompte` (géré exclusivement via recordPayment).
  Future<String?> updateOrder(
    String orderId, {
    String? description,
    double? prixTotal,
    DateTime? dateEcheance,
    String? ficheMesureId,
  }) async {
    try {
      final changes = <String, dynamic>{
        if (description != null) 'description': description,
        if (prixTotal != null) 'prixTotal': prixTotal,
        if (dateEcheance != null)
          'dateEcheance': Timestamp.fromDate(dateEcheance),
        'ficheId': ficheMesureId,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await _firestore.collection('commandes').doc(orderId).update(changes);
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  /// Supprime la commande et ses paiements associés. Les paiements à
  /// supprimer viennent de la liste déjà en mémoire (`_payments`, tenue à
  /// jour en temps réel) — pas de requête Firestore nécessaire, donc pas de
  /// risque de rejet par les règles de sécurité (voir note dans
  /// ClientsProvider.deleteClient pour le détail de ce piège).
  Future<String?> deleteOrder(String orderId) async {
    try {
      final batch = _firestore.batch();
      for (final p in _payments.where((p) => p.commandeId == orderId)) {
        batch.delete(_firestore.collection('paiements').doc(p.id));
      }
      batch.delete(_firestore.collection('commandes').doc(orderId));
      await batch.commit();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  /// Enregistre un paiement manuel (espèces, ou mobile money saisi à la main
  /// tant que l'intégration automatique iPayMoney n'est pas branchée ici).
  /// Écriture atomique par lot (WriteBatch) : la création du paiement et
  /// l'incrément de `acompte` sur la commande réussissent ou échouent
  /// ensemble, en un seul aller-retour réseau au lieu de deux séquentiels.
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
