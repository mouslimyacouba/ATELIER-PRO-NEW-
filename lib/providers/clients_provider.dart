import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientsProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _sub;

  List<AtelierClient> _clients = [];
  bool _loading = false;
  String? _error;

  List<AtelierClient> get clients => _clients;
  bool get loading => _loading;
  String? get error => _error;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  /// Charge les clients en temps réel. S'abonne aux changements Firestore.
  Future<void> load(String userId) async {
    // Si on écoute déjà le bon utilisateur, on ne fait rien
    if (_sub != null) return;

    _loading = true;
    _error = null;
    notifyListeners();

    _sub = _firestore
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _clients = snapshot.docs.map((d) => AtelierClient.fromMap(d.id, d.data())).toList();
        _loading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _loading = false;
        notifyListeners();
      },
    );
  }

  /// Arrête l'écoute (utile lors de la déconnexion)
  void stop() {
    _sub?.cancel();
    _sub = null;
    _clients = [];
    notifyListeners();
  }

  Future<String?> addClient(AtelierClient client) async {
    try {
      await _firestore.collection('clients').add(client.toInsertMap());
      // Plus besoin de manipuler _clients manuellement, snapshots() s'en charge !
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// Accepte les mêmes clés que les écrans envoient déjà (héritées de la
  /// version Supabase, snake_case) et les traduit en camelCase Firestore.
  Future<String?> updateClient(String id, Map<String, dynamic> changes) async {
    const keyMap = {
      'nom_complet': 'nomComplet',
      'photo_url': 'photoUrl',
    };
    final mapped = {
      for (final entry in changes.entries) (keyMap[entry.key] ?? entry.key): entry.value,
    };
    mapped['updatedAt'] = FieldValue.serverTimestamp();

    try {
      final docRef = _firestore.collection('clients').doc(id);
      await docRef.update(mapped);
      final fresh = await docRef.get();
      final updated = AtelierClient.fromMap(fresh.id, fresh.data()!);
      final idx = _clients.indexWhere((c) => c.id == id);
      if (idx != -1) _clients[idx] = updated;
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updatePhoto(String clientId, String photoUrl) =>
      updateClient(clientId, {'photo_url': photoUrl});

  /// Supprime le client, ainsi que ses commandes, paiements et fiches
  /// associés. On ajoute le filtre userId sur chaque requête pour respecter
  /// les règles de sécurité Firestore.
  Future<String?> deleteClient(String id) async {
    try {
      final client = byId(id);
      if (client == null) return 'Client introuvable';
      final userId = client.userId;

      // 1. Supprimer les commandes (et leurs paiements)
      final commandes = await _firestore
          .collection('commandes')
          .where('userId', isEqualTo: userId)
          .where('clientId', isEqualTo: id)
          .get();

      for (final commande in commandes.docs) {
        final paiements = await _firestore
            .collection('paiements')
            .where('userId', isEqualTo: userId)
            .where('commandeId', isEqualTo: commande.id)
            .get();
        for (final p in paiements.docs) {
          await p.reference.delete();
        }
        await commande.reference.delete();
      }

      // 2. Supprimer les fiches
      final fiches = await _firestore
          .collection('fiches')
          .where('userId', isEqualTo: userId)
          .where('clientId', isEqualTo: id)
          .get();
      for (final f in fiches.docs) {
        await f.reference.delete();
      }

      // 3. Supprimer le client lui-même
      await _firestore.collection('clients').doc(id).delete();

      _clients.removeWhere((c) => c.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  AtelierClient? byId(String id) {
    try {
      return _clients.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
