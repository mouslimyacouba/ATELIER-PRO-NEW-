import 'package:cloud_firestore/cloud_firestore.dart';
import 'type_atelier.dart';

class Atelier {
  final String id; // = uid de l'utilisateur (voir AtelierProvider)
  final String userId;
  final String nomAtelier;
  final String? telephone;
  final String? ville;
  final String? specialite;
  final String? logoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Atelier({
    required this.id,
    required this.userId,
    required this.nomAtelier,
    this.telephone,
    this.ville,
    this.specialite,
    this.logoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  /// [id] est l'ID du document Firestore (passé séparément, pas stocké dans
  /// le contenu du document — convention Firestore standard).
  factory Atelier.fromMap(String id, Map<String, dynamic> map) {
    return Atelier(
      id: id,
      userId: id, // même valeur : le doc atelier est indexé par uid
      nomAtelier: map['nomAtelier'] as String,
      telephone: map['telephone'] as String?,
      ville: map['ville'] as String?,
      specialite: map['specialite'] as String?,
      logoUrl: map['logoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Métier de l'atelier, dérivé du champ texte libre `specialite` (aucune
  /// colonne dédiée nécessaire — voir TypeAtelier.fromDbValue).
  TypeAtelier get typeAtelier => TypeAtelier.fromDbValue(specialite);

  String get specialiteLabel => specialite ?? 'Non renseignée';
}
