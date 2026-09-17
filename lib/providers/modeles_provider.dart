import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/modele_fabrication.dart';

/// Provider des modèles de fabrication.
///
/// Architecture identique aux autres providers (ClientsProvider, StockProvider…) :
/// - Stream Firestore temps réel — la liste se met à jour automatiquement
///   sans appel manuel à chargerModeles().
/// - Reset propre à la déconnexion via _authSub.
/// - Hors ligne : Firestore sert depuis le cache local, synchronisation
///   automatique à la reconnexion.
/// - Pas de mise à jour manuelle de _modeles après write : le stream gère
///   tout, éliminant tout risque de désynchronisation.
class ModelesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;
  StreamSubscription<User?>? _authSub;

  List<ModeleFabrication> _modeles = [];
  bool _isLoading = false;
  String? _error;

  List<ModeleFabrication> get modeles =>
      _modeles.where((m) => m.actif).toList();
  List<ModeleFabrication> get tousLesModeles => _modeles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ModelesProvider() {
    // Abonnement immédiat si déjà connecté (cold start / redémarrage app).
    if (_auth.currentUser != null) {
      _listen(_auth.currentUser!.uid);
    }

    _authSub = _auth.authStateChanges().listen((user) {
      if (user != null) {
        _listen(user.uid);
      } else {
        _reset();
      }
    });
  }

  void _listen(String userId) {
    // Évite de recréer le stream si déjà abonné pour ce même userId.
    if (_sub != null) return;

    _isLoading = true;
    notifyListeners();

    _sub = _firestore
        .collection('modeles')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
      (snapshot) {
        _modeles = snapshot.docs
            .map((doc) => ModeleFabrication.fromFirestore(doc))
            .toList();
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        // Si l'erreur contient "failed-precondition", c'est presque toujours
        // un index Firestore composite manquant. On loggue pour le détecter
        // immédiatement sans avoir à ouvrir la console Firebase.
        debugPrint('[ModelesProvider] Erreur stream : $_error');
        notifyListeners();
      },
    );
  }

  void _reset() {
    _sub?.cancel();
    _sub = null;
    _modeles = [];
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _authSub?.cancel();
    super.dispose();
  }

  Future<void> ajouterModele({
    required String nom,
    required String typeProduit,
    required String description,
    String? photoUrl,
    required List<String> champsMesures,
    required List<String> materiauxDefaut,
    required List<EtapeFabrication> etapes,
    double? prixIndicatif,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Utilisateur non connecté');

    final docRef = _firestore.collection('modeles').doc();
    final maintenant = DateTime.now();

    final nouveauModele = ModeleFabrication(
      id: docRef.id,
      userId: user.uid,
      nom: nom,
      typeProduit: typeProduit,
      description: description,
      photoUrl: photoUrl,
      champsMesures: champsMesures,
      materiauxDefaut: materiauxDefaut,
      etapes: etapes,
      prixIndicatif: prixIndicatif,
      actif: true,
      createdAt: maintenant,
      updatedAt: maintenant,
    );

    // Pas de _modeles.insert() manuel : le stream reçoit le nouveau document
    // automatiquement et notifie les widgets.
    await docRef.set(nouveauModele.toJson());
  }

  /// Met à jour un modèle existant avec les données du [modele] reçu.
  /// L'écran (modele_form_screen) construit le modèle modifié via copyWith(...)
  /// avant d'appeler cette méthode — on envoie ce modèle directement à Firestore.
  Future<void> modifierModele(ModeleFabrication modele) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final data = modele.toJson();
    // Remplace updatedAt par le timestamp serveur pour la cohérence.
    data['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('modeles').doc(modele.id).update(data);
    // Pas de mise à jour manuelle : le stream rafraîchit la liste.
  }

  Future<void> supprimerModele(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Soft delete — actif = false. Le stream renverra le document mis à jour,
    // le getter `modeles` le filtrera automatiquement.
    await _firestore.collection('modeles').doc(id).update({
      'actif': false,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
