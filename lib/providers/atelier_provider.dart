 import 'dart:async';
import '../core/firestore_errors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/atelier.dart';

class AtelierProvider extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _atelierSub;

  Atelier? _atelier;
  bool _loading = true;
  String? _error;

  Atelier? get atelier => _atelier;
  bool get loading => _loading;
  String? get error => _error;

  AtelierProvider() {
    // Écoute en temps réel dès qu'un utilisateur se connecte ; se réabonne
    // à chaque changement d'utilisateur, se désabonne à la déconnexion.
    // Avantage mode hors-ligne : Firestore sert immédiatement la dernière
    // valeur connue depuis le cache local si le réseau est indisponible,
    // puis met à jour automatiquement dès que la synchro reprend — pas
    // besoin de bouton "recharger".
    if (_auth.currentUser != null) {
      _listen(_auth.currentUser!.uid);
    } else {
      _loading = false;
    }
    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listen(user.uid);
      } else {
        reset();
      }
    });
  }

  void _listen(String userId) {
    _loading = true;
    notifyListeners();
    _atelierSub?.cancel();
    _atelierSub = _firestore.collection('ateliers').doc(userId).snapshots().listen(
      (doc) {
        _atelier = doc.exists ? Atelier.fromMap(doc.id, doc.data()!) : null;
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

  @override
  void dispose() {
    _authSub?.cancel();
    _atelierSub?.cancel();
    super.dispose();
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
      await _firestore.collection('ateliers').doc(userId).set({
        'nomAtelier': nomAtelier,
        'specialite': specialite,
        'telephone': telephone,
        'ville': ville,
        'logoUrl': null,
        'createdAt': now,
        'updatedAt': now,
      });
      // Pas besoin de mettre à jour `_atelier` manuellement : l'écoute
      // temps réel (_listen) reçoit ce changement automatiquement, y
      // compris hors ligne (écriture locale reflétée immédiatement).
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
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
      await _firestore.collection('ateliers').doc(_atelier!.id).update(mapped);
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
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
      // Pas de contrainte de clé étrangère côté Firestore (contrairement à
      // Postgres) donc aucune dépendance d'ordre entre ces 4 collections —
      // on les supprime en parallèle plutôt que l'une après l'autre.
      await Future.wait([
        _deleteAllWhereUserId('fiches', userId),
        _deleteAllWhereUserId('paiements', userId),
        _deleteAllWhereUserId('commandes', userId),
        _deleteAllWhereUserId('clients', userId),
      ]);
      await _firestore.collection('ateliers').doc(userId).delete();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
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
    _atelierSub?.cancel();
    _atelier = null;
    _loading = false;
    notifyListeners();
  }
}
