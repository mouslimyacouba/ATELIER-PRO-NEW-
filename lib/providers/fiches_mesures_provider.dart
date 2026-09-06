import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/fiche_mesure.dart';

class FichesMesuresProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;

  List<FicheMesure> _fiches = [];
  bool _loading = false;
  String? _error;

  List<FicheMesure> get fiches => _fiches;
  bool get loading => _loading;
  String? get error => _error;

  List<FicheMesure> forClient(String clientId) =>
      _fiches.where((f) => f.clientId == clientId).toList();

  Future<void> load(String userId) async {
    _loading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('fiches')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();
      _fiches = snapshot.docs.map((d) => FicheMesure.fromMap(d.id, d.data())).toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> addFiche(FicheMesure fiche) async {
    try {
      final docRef = await _firestore.collection('fiches').add(fiche.toInsertMap());
      final fresh = await docRef.get();
      _fiches.insert(0, FicheMesure.fromMap(fresh.id, fresh.data()!));
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateFiche(String id, Map<String, dynamic> changes) async {
    final mapped = Map<String, dynamic>.from(changes);
    mapped['updatedAt'] = FieldValue.serverTimestamp();
    try {
      final docRef = _firestore.collection('fiches').doc(id);
      await docRef.update(mapped);
      final fresh = await docRef.get();
      final updated = FicheMesure.fromMap(fresh.id, fresh.data()!);
      final idx = _fiches.indexWhere((f) => f.id == id);
      if (idx != -1) _fiches[idx] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> deleteFiche(String id) async {
    try {
      await _firestore.collection('fiches').doc(id).delete();
      _fiches.removeWhere((f) => f.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
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
