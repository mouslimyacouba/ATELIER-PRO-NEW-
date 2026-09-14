import 'package:cloud_firestore/cloud_firestore.dart';

/// Représente un matériau ou article en stock dans l'atelier.
class StockItem {
  final String id;
  final String userId;
  final String nom;
  final String categorie; // ex: "Tissus", "Quincaillerie", "Bois", etc.
  final double quantite;
  final String unite; // ex: "mètres", "pièces", "kg", "litres", "bobines"
  final double seuilAlerte; // Alerte si quantite <= seuilAlerte
  final double coutUnitaire; // Coût d'achat unitaire (FCFA)
  final DateTime updatedAt;

  StockItem({
    required this.id,
    required this.userId,
    required this.nom,
    required this.categorie,
    required this.quantite,
    required this.unite,
    required this.seuilAlerte,
    required this.coutUnitaire,
    required this.updatedAt,
  });

  bool get isAlerteStock => quantite <= seuilAlerte;

  factory StockItem.fromMap(String id, Map<String, dynamic> map) {
    return StockItem(
      id: id,
      userId: map['userId'] as String? ?? '',
      nom: map['nom'] as String? ?? '',
      categorie: map['categorie'] as String? ?? 'Général',
      quantite: (map['quantite'] as num?)?.toDouble() ?? 0.0,
      unite: map['unite'] as String? ?? 'unités',
      seuilAlerte: (map['seuilAlerte'] as num?)?.toDouble() ?? 2.0,
      coutUnitaire: (map['coutUnitaire'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'nom': nom,
      'categorie': categorie,
      'quantite': quantite,
      'unite': unite,
      'seuilAlerte': seuilAlerte,
      'coutUnitaire': coutUnitaire,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
