import 'dart:async';
import '../core/firestore_errors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/client.dart';

class ClientsProvider extends ChangeNotifier {
  final _firestore = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  String? _currentUserId;

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

  /// S'abonne en temps réel aux clients de cet utilisateur. Hors ligne,
  /// Firestore sert immédiatement la dernière version connue depuis le
  /// cache local ; les écritures faites hors ligne (ajout/modif/suppression)
  /// apparaissent aussi immédiatement ici (cache local), puis se
  /// synchronisent en arrière-plan dès que le réseau revient — aucune
  /// action de l'utilisateur n'est nécessaire.
  ///
  /// Retourne un Future qui se termine dès la première donnée reçue (utile
  /// pour le pull-to-refresh), sans se désabonner : l'écoute reste active
  /// pour les mises à jour suivantes.
  Future<void> load(String userId) {
    if (_currentUserId == userId && _sub != null) {
      return Future.value(); // déjà abonné, rien à refaire
    }
    _currentUserId = userId;
    _loading = true;
    notifyListeners();

    final completer = Completer<void>();
    _sub?.cancel();
    _sub = _firestore
        .collection('clients')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _clients = snapshot.docs
            .map((d) => AtelierClient.fromMap(d.id, d.data()))
            .toList();
        // Tri serveur via orderBy() — plus de .sort() côté client
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

  Future<String?> addClient(AtelierClient client) async {
    try {
      await _firestore.collection('clients').add(client.toInsertMap());
      return null; // l'écoute temps réel met à jour _clients automatiquement
    } catch (e) {
      return friendlyFirestoreError(e);
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
      for (final entry in changes.entries)
        (keyMap[entry.key] ?? entry.key): entry.value,
    };
    mapped['updatedAt'] = FieldValue.serverTimestamp();

    try {
      await _firestore.collection('clients').doc(id).update(mapped);
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
    }
  }

  Future<String?> updatePhoto(String clientId, String photoUrl) =>
      updateClient(clientId, {'photo_url': photoUrl});

  /// Supprime le client, ainsi que ses commandes, paiements et fiches
  /// associés (Firestore ne fait aucune suppression en cascade automatique,
  /// contrairement aux contraintes ON DELETE CASCADE de Postgres).
  ///
  /// ⚠️ `userId` est requis dans CHAQUE requête de recherche des documents à
  /// supprimer (`where('userId', ...)` en plus de `where('clientId', ...)`),
  /// pas juste dans la règle de sécurité elle-même. Sans ça, Firestore
  /// rejette la lecture avec "permission-denied" : ses règles ne peuvent
  /// autoriser une requête que si elles peuvent prouver, à partir des
  /// conditions `where` de la requête elle-même, que tous les documents
  /// retournés respecteront la règle — une requête filtrée seulement par
  /// `clientId` ne suffit pas à le prouver, même si en pratique tous les
  /// documents concernés appartiennent bien à l'utilisateur.
  Future<String?> deleteClient(String id, String userId) async {
    try {
      final batch = _firestore.batch();

      final commandes = await _firestore
          .collection('commandes')
          .where('userId', isEqualTo: userId)
          .where('clientId', isEqualTo: id)
          .get();
      for (final c in commandes.docs) {
        batch.delete(c.reference);
      }

      final paiements = await _firestore
          .collection('paiements')
          .where('userId', isEqualTo: userId)
          .where('clientId', isEqualTo: id)
          .get();
      for (final p in paiements.docs) {
        batch.delete(p.reference);
      }

      final fiches = await _firestore
          .collection('fiches')
          .where('userId', isEqualTo: userId)
          .where('clientId', isEqualTo: id)
          .get();
      for (final f in fiches.docs) {
        batch.delete(f.reference);
      }

      batch.delete(_firestore.collection('clients').doc(id));
      await batch.commit();
      return null;
    } catch (e) {
      return friendlyFirestoreError(e);
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
