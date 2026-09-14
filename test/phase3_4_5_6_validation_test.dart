import 'package:flutter_test/flutter_test.dart';
import 'package:atelierpro_mobile/models/type_atelier.dart';
import 'package:atelierpro_mobile/models/order.dart';
import 'package:atelierpro_mobile/models/payment.dart';
import 'package:atelierpro_mobile/models/historique_entry.dart';
import 'package:atelierpro_mobile/core/config/metier_registry.dart';

void main() {
  group('PHASE 3 — Validation Fiche de commande dynamique', () {
    test('Chaque métier produit des spécifications sérialisables dans AtelierOrder', () {
      final specMecanique = {'vehicule': 'Toyota Hilux', 'kilometrage': 120000};
      final orderMeca = AtelierOrder(
        id: 'ord-meca-1',
        userId: 'usr-1',
        clientId: 'cli-1',
        description: 'Réparation freinage',
        status: OrderStatus.enCours,
        dateCommande: DateTime.now(),
        prixTotal: 50000,
        acompte: 20000,
        createdAt: DateTime.now(),
        specificationsMetier: specMecanique,
      );

      final map = orderMeca.toInsertMap();
      expect(map['specificationsMetier'], equals(specMecanique));

      final restored = AtelierOrder.fromMap('ord-meca-1', map);
      expect(restored.specificationsMetier?['vehicule'], equals('Toyota Hilux'));
      expect(restored.specificationsMetier?['kilometrage'], equals(120000));
    });
  });

  group('PHASE 4 — Validation Renforcement du modèle Commande & Numérotation', () {
    test('Formatage automatique des numéros CMD-XXXX', () {
      final o1 = AtelierOrder(
        id: '1', userId: 'u1', clientId: 'c1', description: 'Test',
        status: OrderStatus.enAttente, dateCommande: DateTime.now(),
        prixTotal: 100, acompte: 0, createdAt: DateTime.now(), numero: 1,
      );
      expect(o1.numeroFormate, equals('CMD-0001'));

      final o7 = AtelierOrder(
        id: '7', userId: 'u1', clientId: 'c1', description: 'Test',
        status: OrderStatus.enAttente, dateCommande: DateTime.now(),
        prixTotal: 100, acompte: 0, createdAt: DateTime.now(), numero: 7,
      );
      expect(o7.numeroFormate, equals('CMD-0007'));

      final o100 = AtelierOrder(
        id: '100', userId: 'u1', clientId: 'c1', description: 'Test',
        status: OrderStatus.enAttente, dateCommande: DateTime.now(),
        prixTotal: 100, acompte: 0, createdAt: DateTime.now(), numero: 100,
      );
      expect(o100.numeroFormate, equals('CMD-0100'));
    });

    test('Snapshot des étapes de fabrication & progression', () {
      final etapes = [
        {'id': 'e1', 'ordre': 1, 'titre': 'Découpe', 'terminee': true},
        {'id': 'e2', 'ordre': 2, 'titre': 'Assemblage', 'terminee': false},
        {'id': 'e3', 'ordre': 3, 'titre': 'Finition', 'terminee': false},
      ];

      final order = AtelierOrder(
        id: 'o-snap', userId: 'u1', clientId: 'c1', description: 'Meuble',
        status: OrderStatus.enCours, dateCommande: DateTime.now(),
        prixTotal: 150000, acompte: 50000, createdAt: DateTime.now(),
        etapesSnapshot: etapes,
      );

      expect(order.etapesCompletes, equals(1));
      expect(order.progressionFabrication, closeTo(0.333, 0.01));
    });
  });

  group('PHASE 5 — Validation Historique + Paiements', () {
    test('Création et sérialisation d\'une entrée d\'historique', () {
      final h = HistoriqueEntry(
        id: 'h-1',
        userId: 'u1',
        commandeId: 'c1',
        champModifie: 'statut',
        ancienneValeur: 'En attente',
        nouvelleValeur: 'En cours',
        createdAt: DateTime.now(),
      );

      final map = h.toInsertMap();
      expect(map['champModifie'], equals('statut'));
      expect(map['ancienneValeur'], equals('En attente'));
      expect(map['nouvelleValeur'], equals('En cours'));
    });

    test('Calcul du solde restant après paiement', () {
      final order = AtelierOrder(
        id: 'o-pay', userId: 'u1', clientId: 'c1', description: 'Bague or',
        status: OrderStatus.enAttente, dateCommande: DateTime.now(),
        prixTotal: 200000, acompte: 50000, createdAt: DateTime.now(),
      );

      expect(order.remaining, equals(150000));
      expect(order.isFullyPaid, isFalse);

      final orderPaye = AtelierOrder(
        id: 'o-pay', userId: 'u1', clientId: 'c1', description: 'Bague or',
        status: OrderStatus.enAttente, dateCommande: DateTime.now(),
        prixTotal: 200000, acompte: 200000, createdAt: DateTime.now(),
      );

      expect(orderPaye.remaining, equals(0));
      expect(orderPaye.isFullyPaid, isTrue);
    });
  });

  group('PHASE 6 — Validation Calendrier & Détection d\'échéance', () {
    test('Détection d\'échéance en retard', () {
      final pastDate = DateTime.now().subtract(const Duration(days: 2));
      final orderRetard = AtelierOrder(
        id: 'o-retard', userId: 'u1', clientId: 'c1', description: 'Retard',
        status: OrderStatus.enCours, dateCommande: DateTime.now().subtract(const Duration(days: 10)),
        dateEcheance: pastDate, prixTotal: 10000, acompte: 0, createdAt: DateTime.now(),
      );

      final todayOnly = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      final isOverdue = orderRetard.status != OrderStatus.livre && orderRetard.dateEcheance!.isBefore(todayOnly);
      expect(isOverdue, isTrue);
    });
  });
}
