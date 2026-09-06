import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/atelier.dart';

class AtelierProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;

  Atelier? _atelier;
  bool _loading = true;
  String? _error;

  Atelier? get atelier => _atelier;
  bool get loading => _loading;
  String? get error => _error;

  AtelierProvider() {
    // Charge (ou recharge) l'atelier dès qu'un utilisateur se connecte ;
    // réinitialise à la déconnexion. Évite d'avoir à appeler
    // loadForCurrentUser() manuellement depuis chaque écran.
    if (_auth.currentUser != null) {
      loadForCurrentUser();
    } else {
      _loading = false;
    }
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        loadForCurrentUser();
      } else {
        reset();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  // L'atelier est stocké avec l'UID de l'utilisateur comme ID de document
  // (collection('ateliers').doc(uid)) : relation 1-pour-1 directe, pas
  // besoin de requête ni de table de jointure séparée.
  Future<void> loadForCurrentUser() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      _atelier = null;
      _loading = false;
      notifyListeners();
      return;
    }

    _loading = true;
    notifyListeners();

    try {
      final doc = await _firestore.collection('ateliers').doc(userId).get();
      _atelier = doc.exists ? Atelier.fromMap(doc.id, doc.data()!) : null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> createAtelier({
    required String nomAtelier,
    String? specialite,
    String? telephone,
    String? ville,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return 'Utilisateur non connecté';

    try {
      final now = FieldValue.serverTimestamp();
      final docRef = _firestore.collection('ateliers').doc(userId);
      await docRef.set({
        'nomAtelier': nomAtelier,
        'specialite': specialite,
        'telephone': telephone,
        'ville': ville,
        'logoUrl': null,
        'createdAt': now,
        'updatedAt': now,
      });
      final fresh = await docRef.get();
      _atelier = Atelier.fromMap(fresh.id, fresh.data()!);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Accepte les mêmes clés "changes" que les écrans envoient déjà
  /// (héritées de la version Supabase, snake_case) et les traduit en
  /// camelCase côté Firestore — évite de retoucher les écrans appelants.
  Future<String?> updateAtelier(Map<String, dynamic> changes) async {
    if (_atelier == null) return 'Aucun atelier chargé';
    const keyMap = {
      'nom_atelier': 'nomAtelier',
      'logo_url': 'logoUrl',
    };
    final mapped = {
      for (final entry in changes.entries) (keyMap[entry.key] ?? entry.key): entry.value,
    };
    mapped['updatedAt'] = FieldValue.serverTimestamp();

    try {
      final docRef = _firestore.collection('ateliers').doc(_atelier!.id);
      await docRef.update(mapped);
      final fresh = await docRef.get();
      _atelier = Atelier.fromMap(fresh.id, fresh.data()!);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateLogo(String logoUrl) => updateAtelier({'logo_url': logoUrl});

  /// Supprime définitivement l'atelier et toutes ses données liées (clients,
  /// commandes, paiements, fiches). Contrairement à Postgres, Firestore n'a
  /// pas de ON DELETE CASCADE : on supprime manuellement chaque collection
  /// liée par lots (batch) avant de supprimer le document atelier lui-même.
  /// Ne supprime PAS le compte Firebase Auth (nécessiterait une Cloud
  /// Function avec droits admin — hors scope ici, comme pour iPayMoney).
  Future<String?> deleteAtelier() async {
    if (_atelier == null) return null;
    final userId = _atelier!.id;

    try {
      for (final collection in ['fiches', 'paiements', 'commandes', 'clients']) {
        await _deleteAllWhereUserId(collection, userId);
      }
      await _firestore.collection('ateliers').doc(userId).delete();
      _atelier = null;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> _deleteAllWhereUserId(String collection, String userId) async {
    final snapshot = await _firestore.collection(collection).where('userId', isEqualTo: userId).get();
    // Firestore limite un batch à 500 opérations : on découpe par sécurité.
    for (var i = 0; i < snapshot.docs.length; i += 400) {
      final batch = _firestore.batch();
      for (final doc in snapshot.docs.skip(i).take(400)) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }

  void reset() {
    _atelier = null;
    _loading = false;
    notifyListeners();
  }
}
