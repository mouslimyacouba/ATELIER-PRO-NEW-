import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/stock_item.dart';
import '../core/firestore_errors.dart';

class StockProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _stockSub;
  String? _currentUserId;

  List<StockItem> _items = [];
  bool _loading = false;
  String? _error;

  List<StockItem> get items => _items;
  bool get loading => _loading;
  String? get error => _error;

  List<StockItem> get itemsEnAlerte =>
      _items.where((item) => item.isAlerteStock).toList();

  @override
  void dispose() {
    _stockSub?.cancel();
    super.dispose();
  }

  Future<void> load(String userId) async {
    if (_currentUserId == userId && _stockSub != null) return;
    _currentUserId = userId;
    _loading = true;
    notifyListeners();

    _stockSub?.cancel();
    _stockSub = _firestore
        .collection('stock')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _items = snapshot.docs
            .map((doc) => StockItem.fromMap(doc.id, doc.data()))
            .toList();
        _items.sort((a, b) => a.nom.compareTo(b.nom));
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = friendlyFirestoreError(e);
        _loading = false;
        notifyListeners();
      },
    );
  }

  Future<String?> saveItem(StockItem item) async {
    try {
      if (item.id.isEmpty) {
        await _firestore.collection('stock').add(item.toInsertMap());
      } else {
        await _firestore.collection('stock').doc(item.id).update(item.toInsertMap());
      }
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> deleteItem(String id) async {
    try {
      await _firestore.collection('stock').doc(id).delete();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  /// Déduit automatiquement les quantités du stock selon une liste de matériaux consommés (BOM)
  Future<String?> consommerMateriaux(String userId, List<Map<String, dynamic>> materiauxConsommes) async {
    try {
      final batch = _firestore.batch();
      for (final mat in materiauxConsommes) {
        final nom = mat['nom'] as String?;
        final quantite = (mat['quantite'] as num?)?.toDouble() ?? 0.0;
        if (nom == null || quantite <= 0) continue;

        // Chercher si l'article existe déjà en stock pour cet utilisateur
        final match = _items.where((i) => i.nom.toLowerCase() == nom.toLowerCase()).toList();
        if (match.isNotEmpty) {
          final stockItem = match.first;
          final nouvelleQuantite = (stockItem.quantite - quantite).clamp(0.0, double.infinity);
          final docRef = _firestore.collection('stock').doc(stockItem.id);
          batch.update(docRef, {
            'quantite': nouvelleQuantite,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
      await batch.commit();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }
}
