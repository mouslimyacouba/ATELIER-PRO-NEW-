import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Statuts de commande (avant : enum Postgres `statut_commande`, maintenant
/// juste une chaîne stockée telle quelle côté Firestore).
enum OrderStatus { enAttente, enCours, termine, livre }

extension OrderStatusX on OrderStatus {
  String get value {
    switch (this) {
      case OrderStatus.enAttente:
        return 'en_attente';
      case OrderStatus.enCours:
        return 'en_cours';
      case OrderStatus.termine:
        return 'termine';
      case OrderStatus.livre:
        return 'livre';
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.enAttente:
        return 'En attente';
      case OrderStatus.enCours:
        return 'En cours';
      case OrderStatus.termine:
        return 'Terminée';
      case OrderStatus.livre:
        return 'Livrée';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.enAttente:
        return const Color(0xFFF59E0B); // status-pending
      case OrderStatus.enCours:
        return const Color(0xFF3B82F6); // status-progress
      case OrderStatus.termine:
        return const Color(0xFF10B981); // status-done
      case OrderStatus.livre:
        return const Color(0xFF6366F1); // status-delivered
    }
  }

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => OrderStatus.enAttente,
    );
  }
}

class AtelierOrder {
  final String id;
  final String userId;
  final String clientId;
  final String? ficheMesureId;
  final String description;
  final OrderStatus status;
  final DateTime dateCommande;
  final DateTime? dateEcheance;
  final double prixTotal;
  final double acompte;
  final DateTime createdAt;
  // Dénormalisé (copié au moment de la création) : Firestore ne fait pas de
  // jointures. Si le client est renommé plus tard, les anciennes commandes
  // gardent l'ancien nom affiché — compromis standard et acceptable ici.
  final String? clientName;

  AtelierOrder({
    required this.id,
    required this.userId,
    required this.clientId,
    this.ficheMesureId,
    required this.description,
    required this.status,
    required this.dateCommande,
    this.dateEcheance,
    required this.prixTotal,
    required this.acompte,
    required this.createdAt,
    this.clientName,
  });

  double get remaining => (prixTotal - acompte).clamp(0, double.infinity);
  bool get isFullyPaid => remaining <= 0;

  // Alias pratiques utilisés dans l'UI (montants).
  double get totalAmount => prixTotal;
  double get paidAmount => acompte;
  DateTime? get dueDate => dateEcheance;

  factory AtelierOrder.fromMap(String id, Map<String, dynamic> map) {
    return AtelierOrder(
      id: id,
      userId: map['userId'] as String,
      clientId: map['clientId'] as String,
      ficheMesureId: map['ficheId'] as String?,
      description: map['description'] as String,
      status: OrderStatusX.fromValue(map['statut'] as String),
      dateCommande: (map['dateCommande'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateEcheance: (map['dateEcheance'] as Timestamp?)?.toDate(),
      prixTotal: (map['prixTotal'] as num).toDouble(),
      acompte: (map['acompte'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      clientName: map['clientNom'] as String?,
    );
  }

  Map<String, dynamic> toInsertMap() {
    return {
      'userId': userId,
      'clientId': clientId,
      'clientNom': clientName,
      'ficheId': ficheMesureId,
      'description': description,
      'statut': status.value,
      'dateCommande': Timestamp.fromDate(dateCommande),
      'dateEcheance': dateEcheance != null ? Timestamp.fromDate(dateEcheance!) : null,
      'prixTotal': prixTotal,
      'acompte': acompte,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
