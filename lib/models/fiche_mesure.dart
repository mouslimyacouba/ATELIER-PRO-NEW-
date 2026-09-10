import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle générique de fiche métier (mesures couture, fiche véhicule, fiche
/// chantier...). Le champ `mesures` contient les données saisies, avec pour
/// clés les `id` des [ChampFiche] du [FicheTemplate] correspondant au métier
/// de l'atelier — voir `core/fiche_templates.dart`. Stocké dans la
/// collection Firestore `fiches`.
class FicheMesure {
  final String id;
  final String userId;
  final String clientId;
  final String titre;
  final Map<String, dynamic> mesures;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  FicheMesure({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.titre,
    required this.mesures,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FicheMesure.fromMap(String id, Map<String, dynamic> map) {
    return FicheMesure(
      id: id,
      userId: map['userId'] as String,
      clientId: map['clientId'] as String,
      titre: (map['titre'] as String?) ?? 'Fiche',
      mesures: Map<String, dynamic>.from(map['mesures'] as Map? ?? {}),
      notes: map['notes'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'titre': titre,
      'mesures': mesures,
      'notes': notes,
      'createdAt': Timestamp.fromDate(DateTime.now()), // pas serverTimestamp() : sinon disparaît des listes triées jusqu'à confirmation serveur
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
