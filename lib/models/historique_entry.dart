import 'package:cloud_firestore/cloud_firestore.dart';

class HistoriqueEntry {
  final String id;
  final String userId;
  final String commandeId;
  final String champModifie;
  final String? ancienneValeur;
  final String? nouvelleValeur;
  final DateTime createdAt;

  HistoriqueEntry({
    required this.id,
    required this.userId,
    required this.commandeId,
    required this.champModifie,
    this.ancienneValeur,
    this.nouvelleValeur,
    required this.createdAt,
  });

  static const champLabels = {
    'description': 'Description',
    'prixTotal': 'Montant total',
    'dateEcheance': 'Date de livraison',
    'statut': 'Statut',
    'modele': 'Modèle de fabrication',
  };

  String get champLabel => champLabels[champModifie] ?? champModifie;

  factory HistoriqueEntry.fromMap(String id, Map<String, dynamic> map) {
    return HistoriqueEntry(
      id: id,
      userId: map['userId'] as String,
      commandeId: map['commandeId'] as String,
      champModifie: map['champModifie'] as String? ?? '',
      ancienneValeur: map['ancienneValeur'] as String?,
      nouvelleValeur: map['nouvelleValeur'] as String?,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'commandeId': commandeId,
      'champModifie': champModifie,
      'ancienneValeur': ancienneValeur,
      'nouvelleValeur': nouvelleValeur,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    };
  }
}
