import 'package:cloud_firestore/cloud_firestore.dart';

class AtelierClient {
  final String id;
  final String userId;
  final String nomComplet;
  final String? telephone;
  final String? adresse;
  final String? notes;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  AtelierClient({
    required this.id,
    required this.userId,
    required this.nomComplet,
    this.telephone,
    this.adresse,
    this.notes,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AtelierClient.fromMap(String id, Map<String, dynamic> map) {
    return AtelierClient(
      id: id,
      userId: map['userId'] as String,
      nomComplet: map['nomComplet'] as String,
      telephone: map['telephone'] as String?,
      adresse: map['adresse'] as String?,
      notes: map['notes'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'nomComplet': nomComplet,
      'telephone': telephone,
      'adresse': adresse,
      'notes': notes,
      'photoUrl': photoUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
