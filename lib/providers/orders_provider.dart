import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/order.dart';
import '../models/payment.dart';

class OrdersProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<AtelierOrder> _orders = [];
  bool _loading = false;
  String? _error;

  List<AtelierOrder> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  List<AtelierOrder> byStatus(OrderStatus status) =>
      _orders.where((o) => o.status == status).toList();

  double get chiffreAffairesTotal =>
      _orders.fold(0, (sum, o) => sum + o.prixTotal);

  double get montantRestantDu =>
      _orders.fold(0, (sum, o) => sum + o.remaining);

  List<AtelierOrder> get enRetard {
    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);
    return _orders.where((o) {
      if (o.dateEcheance == null) return false;
      if (o.status == OrderStatus.livre) return false;
      return o.dateEcheance!.isBefore(todayOnly);
    }).toList();
  }

  Future<void> load(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('commandes')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _orders = snapshot.docs.map((d) => AtelierOrder.fromMap(d.id, d.data())).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> createOrder(AtelierOrder order) async {
    try {
      final docRef = await _firestore.collection('commandes').add(order.toInsertMap());
      final fresh = await docRef.get();
      _orders.insert(0, AtelierOrder.fromMap(fresh.id, fresh.data()!));
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateStatus(String orderId, OrderStatus status) async {
    try {
      final docRef = _firestore.collection('commandes').doc(orderId);
      await docRef.update({'statut': status.value, 'updatedAt': FieldValue.serverTimestamp()});
      final fresh = await docRef.get();
      final updated = AtelierOrder.fromMap(fresh.id, fresh.data()!);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) _orders[idx] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
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
        if (dateEcheance != null) 'dateEcheance': Timestamp.fromDate(dateEcheance),
        'ficheId': ficheMesureId,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      final docRef = _firestore.collection('commandes').doc(orderId);
      await docRef.update(changes);
      final fresh = await docRef.get();
      final updated = AtelierOrder.fromMap(fresh.id, fresh.data()!);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) _orders[idx] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Supprime la commande et ses paiements associés. Le filtre userId est
  /// obligatoire pour que Firestore autorise la lecture des documents à supprimer.
  Future<String?> deleteOrder(String orderId) async {
    try {
      final order = byId(orderId);
      if (order == null) return 'Commande introuvable';
      final userId = order.userId;

      final paiements = await _firestore
          .collection('paiements')
          .where('userId', isEqualTo: userId)
          .where('commandeId', isEqualTo: orderId)
          .get();

      for (final p in paiements.docs) {
        await p.reference.delete();
      }

      await _firestore.collection('commandes').doc(orderId).delete();
      _orders.removeWhere((o) => o.id == orderId);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Enregistre un paiement manuel (espèces, ou mobile money saisi à la main
  /// tant que l'intégration automatique iPayMoney n'est pas branchée ici).
  /// Incrémente `acompte` sur la commande de façon atomique
  /// (FieldValue.increment évite toute perte de mise à jour concurrente,
  /// contrairement à un simple read-then-write).
  Future<String?> recordPayment({
    required String orderId,
    required String userId,
    required double amount,
    required String mode,
  }) async {
    try {
      await _firestore.collection('paiements').add(
        AtelierPayment(
          id: '',
          userId: userId,
          commandeId: orderId,
          montant: amount,
          mode: mode,
          datePaiement: DateTime.now(),
          createdAt: DateTime.now(),
        ).toInsertMap(),
      );

      final docRef = _firestore.collection('commandes').doc(orderId);
      await docRef.update({
        'acompte': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      final fresh = await docRef.get();
      final updated = AtelierOrder.fromMap(fresh.id, fresh.data()!);
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) _orders[idx] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<List<AtelierPayment>> paymentsForOrder(String orderId) async {
    final snapshot = await _firestore
        .collection('paiements')
        .where('commandeId', isEqualTo: orderId)
        .orderBy('datePaiement', descending: true)
        .get();
    return snapshot.docs.map((d) => AtelierPayment.fromMap(d.id, d.data())).toList();
  }

  AtelierOrder? byId(String id) {
    try {
      return _orders.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}
