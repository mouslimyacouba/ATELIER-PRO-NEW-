import 'package:cloud_firestore/cloud_firestore.dart';

class AtelierPayment {
  final String id;
  final String userId;
  final String commandeId;
  final String clientId; // dénormalisé — évite une requête par commande pour l'historique client
  final double montant;
  final String mode;
  final DateTime datePaiement;
  final DateTime createdAt;

  AtelierPayment({
    required this.id,
    required this.userId,
    required this.commandeId,
    required this.clientId,
    required this.montant,
    required this.mode,
    required this.datePaiement,
    required this.createdAt,
  });

  // `mode` est un simple champ texte (pas d'enum) : ces libellés sont juste
  // pour l'affichage, on peut en ajouter librement.
  static const modeLabels = {
    'especes': 'Espèces',
    'airtel_money': 'Airtel Money',
    'moov_flooz': 'Moov Flooz',
    'wave': 'Wave',
    'zamani_cash': 'Zamani Cash',
    'virement': 'Virement',
    'autre': 'Autre',
  };

  String get modeLabel => modeLabels[mode] ?? mode;

  factory AtelierPayment.fromMap(String id, Map<String, dynamic> map) {
    return AtelierPayment(
      id: id,
      userId: map['userId'] as String,
      commandeId: map['commandeId'] as String,
      clientId: map['clientId'] as String? ?? '',
      montant: (map['montant'] as num).toDouble(),
      mode: (map['mode'] as String?) ?? 'especes',
      datePaiement: (map['datePaiement'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'commandeId': commandeId,
      'clientId': clientId,
      'montant': montant,
      'mode': mode,
      'datePaiement': Timestamp.fromDate(DateTime.now()), // idem : évite de disparaître de la liste triée
      'createdAt': Timestamp.fromDate(DateTime.now()), // pas serverTimestamp() : sinon disparaît des listes triées jusqu'à confirmation serveur
    };
  }
}
