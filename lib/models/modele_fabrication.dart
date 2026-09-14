import 'package:cloud_firestore/cloud_firestore.dart';

class EtapeFabrication {
  final String id;
  final String titre;
  final String? description;

  EtapeFabrication({
    required this.id,
    required this.titre,
    this.description,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'titre': titre,
        'description': description,
      };

  factory EtapeFabrication.fromJson(Map<String, dynamic> json) => EtapeFabrication(
        id: json['id'] ?? '',
        titre: json['titre'] ?? '',
        description: json['description'],
      );
}

class ModeleFabrication {
  final String id;
  final String userId;
  final String nom;
  final String typeProduit;
  final String description;
  final String? photoUrl;
  final List<String> champsMesures;
  final List<String> materiauxDefaut;
  final List<EtapeFabrication> etapes;
  final double? prixIndicatif;
  final bool actif;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModeleFabrication({
    required this.id,
    required this.userId,
    required this.nom,
    required this.typeProduit,
    required this.description,
    this.photoUrl,
    required this.champsMesures,
    required this.materiauxDefaut,
    required this.etapes,
    this.prixIndicatif,
    required this.actif,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'nom': nom,
        'typeProduit': typeProduit,
        'description': description,
        'photoUrl': photoUrl,
        'champsMesures': champsMesures,
        'materiauxDefaut': materiauxDefaut,
        'etapes': etapes.map((e) => e.toJson()).toList(),
        'prixIndicatif': prixIndicatif,
        'actif': actif,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory ModeleFabrication.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModeleFabrication(
      id: doc.id,
      userId: data['userId'] ?? '',
      nom: data['nom'] ?? '',
      typeProduit: data['typeProduit'] ?? '',
      description: data['description'] ?? '',
      photoUrl: data['photoUrl'],
      champsMesures: List<String>.from(data['champsMesures'] ?? []),
      materiauxDefaut: List<String>.from(data['materiauxDefaut'] ?? []),
      etapes: (data['etapes'] as List<dynamic>? ?? [])
          .map((e) => EtapeFabrication.fromJson(e as Map<String, dynamic>))
          .toList(),
      prixIndicatif: (data['prixIndicatif'] as num?)?.toDouble(),
      actif: data['actif'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ModeleFabrication copyWith({
    String? nom,
    String? typeProduit,
    String? description,
    String? photoUrl,
    List<String>? champsMesures,
    List<String>? materiauxDefaut,
    List<EtapeFabrication>? etapes,
    double? prixIndicatif,
    bool? actif,
  }) {
    return ModeleFabrication(
      id: id,
      userId: userId,
      nom: nom ?? this.nom,
      typeProduit: typeProduit ?? this.typeProduit,
      description: description ?? this.description,
      photoUrl: photoUrl ?? this.photoUrl,
      champsMesures: champsMesures ?? this.champsMesures,
      materiauxDefaut: materiauxDefaut ?? this.materiauxDefaut,
      etapes: etapes ?? this.etapes,
      prixIndicatif: prixIndicatif ?? this.prixIndicatif,
      actif: actif ?? this.actif,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
