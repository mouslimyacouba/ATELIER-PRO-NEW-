import 'dart:async';
import '../core/firestore_errors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/fiche_mesure.dart';

class FichesMesuresProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  String? _currentUserId;

  List<FicheMesure> _fiches = [];
  bool _loading = false;
  String? _error;

  List<FicheMesure> get fiches => _fiches;
  bool get loading => _loading;
  String? get error => _error;

  List<FicheMesure> forClient(String clientId) =>
      _fiches.where((f) => f.clientId == clientId).toList();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// S'abonne en temps réel aux fiches de cet utilisateur — voir
  /// ClientsProvider.load pour le détail du comportement hors ligne
  /// (identique ici).
  Future<void> load(String userId) {
    if (_currentUserId == userId && _sub != null) {
      return Future.value();
    }
    _currentUserId = userId;
    _loading = true;
    notifyListeners();

    final completer = Completer<void>();
    _sub?.cancel();
    _sub = _firestore
        .collection('fiches')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .listen(
      (snapshot) {
        _fiches = snapshot.docs
            .map((d) => FicheMesure.fromMap(d.id, d.data()))
            .toList();
        _fiches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
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
    return completer.future;
  }

  Future<String?> addFiche(FicheMesure fiche) async {
    try {
      await _firestore.collection('fiches').add(fiche.toInsertMap());
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> updateFiche(String id, Map<String, dynamic> changes) async {
    final mapped = Map<String, dynamic>.from(changes);
    mapped['updatedAt'] = FieldValue.serverTimestamp();
    try {
      await _firestore.collection('fiches').doc(id).update(mapped);
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> deleteFiche(String id) async {
    try {
      await _firestore.collection('fiches').doc(id).delete();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  FicheMesure? byId(String id) {
    try {
      return _fiches.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }
}
