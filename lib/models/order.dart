import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
        return const Color(0xFFF59E0B);
      case OrderStatus.enCours:
        return const Color(0xFF3B82F6);
      case OrderStatus.termine:
        return const Color(0xFF10B981);
      case OrderStatus.livre:
        return const Color(0xFF6366F1);
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
  final String? clientName;

  final String? modeleId;
  final List<Map<String, dynamic>>? etapesSnapshot;
  final List<String> photoUrls;
  final Map<String, dynamic>? specificationsMetier;
  final int? numero;

  final double coutMateriaux;
  final double coutMainDoeuvre;
  final double coutTransport;

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
    this.modeleId,
    this.etapesSnapshot,
    this.photoUrls = const [],
    this.specificationsMetier,
    this.numero,
    this.coutMateriaux = 0.0,
    this.coutMainDoeuvre = 0.0,
    this.coutTransport = 0.0,
  });

  double get coutTotalRevient => coutMateriaux + coutMainDoeuvre + coutTransport;
  double get beneficeEstime => prixTotal - coutTotalRevient;

  double get remaining => (prixTotal - acompte).clamp(0, double.infinity);
  bool get isFullyPaid => remaining <= 0;

  double get totalAmount => prixTotal;
  double get paidAmount => acompte;
  DateTime? get dueDate => dateEcheance;

  String get numeroFormate {
    if (numero == null) return '';
    return 'CMD-${numero.toString().padLeft(4, '0')}';
  }

  int get etapesCompletes {
    if (etapesSnapshot == null) return 0;
    return etapesSnapshot!.where((e) => e['terminee'] == true).length;
  }

  double get progressionFabrication {
    if (etapesSnapshot == null || etapesSnapshot!.isEmpty) return 0.0;
    return etapesCompletes / etapesSnapshot!.length;
  }

  factory AtelierOrder.fromMap(String id, Map<String, dynamic> map) {
    return AtelierOrder(
      id: id,
      userId: map['userId'] as String,
      clientId: map['clientId'] as String,
      ficheMesureId: map['ficheId'] as String?,
      description: map['description'] as String,
      status: OrderStatusX.fromValue(map['statut'] as String),
      dateCommande:
          (map['dateCommande'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dateEcheance: (map['dateEcheance'] as Timestamp?)?.toDate(),
      prixTotal: (map['prixTotal'] as num).toDouble(),
      acompte: (map['acompte'] as num?)?.toDouble() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      clientName: map['clientNom'] as String?,
      modeleId: map['modeleId'] as String?,
      etapesSnapshot: (map['etapesSnapshot'] as List<dynamic>?)
          ?.map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      photoUrls: (map['photoUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      specificationsMetier: map['specificationsMetier'] != null
          ? Map<String, dynamic>.from(map['specificationsMetier'] as Map)
          : null,
      numero: (map['numero'] as num?)?.toInt(),
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
      'dateEcheance':
          dateEcheance != null ? Timestamp.fromDate(dateEcheance!) : null,
      'prixTotal': prixTotal,
      'acompte': acompte,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'modeleId': modeleId,
      'etapesSnapshot': etapesSnapshot,
      'photoUrls': photoUrls,
      'specificationsMetier': specificationsMetier,
      'numero': numero,
      'coutMateriaux': coutMateriaux,
      'coutMainDoeuvre': coutMainDoeuvre,
      'coutTransport': coutTransport,
    };
  }
}
