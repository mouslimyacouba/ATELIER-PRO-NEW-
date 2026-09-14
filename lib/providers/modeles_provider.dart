import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/modele_fabrication.dart';

class ModelesProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ModeleFabrication> _modeles = [];
  bool _isLoading = false;
  String? _error;

  List<ModeleFabrication> get modeles => _modeles.where((m) => m.actif).toList();
  List<ModeleFabrication> get tousLesModeles => _modeles;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ModelesProvider() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        chargerModeles();
      } else {
        _modeles = [];
        notifyListeners();
      }
    });
  }

  Future<void> chargerModeles() async {
    final user = _auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('modeles')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _modeles = snapshot.docs
          .map((doc) => ModeleFabrication.fromFirestore(doc))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

    await docRef.set(nouveauModele.toJson());
    _modeles.insert(0, nouveauModele);
    notifyListeners();
  }

  Future<void> modifierModele(ModeleFabrication modele) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final updatedModele = modele.copyWith();
    await _firestore
        .collection('modeles')
        .doc(modele.id)
        .update(updatedModele.toJson());

    final index = _modeles.indexWhere((m) => m.id == modele.id);
    if (index != -1) {
      _modeles[index] = updatedModele;
      notifyListeners();
    }
  }

  Future<void> supprimerModele(String id) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // Soft delete
    await _firestore.collection('modeles').doc(id).update({
      'actif': false,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });

    _modeles.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}
