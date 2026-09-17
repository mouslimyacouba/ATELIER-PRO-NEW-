import 'package:flutter_test/flutter_test.dart';
import 'package:atelierpro_mobile/models/type_atelier.dart';
import 'package:atelierpro_mobile/core/config/metier_registry.dart';

void main() {
  group('MetierRegistry & Trade Configurations Test', () {
    test('Chaque TypeAtelier renvoie sa propre configuration unique', () {
      for (final type in TypeAtelier.values) {
        final config = MetierRegistry.getByType(type);
        expect(config, isNotNull);
        expect(config.id, equals(type.id));
      }
    });

    test('Vérification des champs spécifiques Mécanique', () {
      final config = MetierRegistry.getByType(TypeAtelier.mecanique);
      final keys = config.champs.map((c) => c.key).toList();
      expect(keys, contains('vehicule'));
      expect(keys, isNot(contains('type_vetement')));
    });

    test('Vérification des champs spécifiques Menuiserie', () {
      final config = MetierRegistry.getByType(TypeAtelier.menuiserie);
      final keys = config.champs.map((c) => c.key).toList();
      expect(keys, contains('type_meuble'));
      expect(keys, isNot(contains('type_vetement')));
    });

    test('Vérification des champs spécifiques Cordonnerie', () {
      final config = MetierRegistry.getByType(TypeAtelier.cordonnerie);
      final keys = config.champs.map((c) => c.key).toList();
      expect(keys, contains('type_article'));
      expect(keys, isNot(contains('type_vetement')));
    });

    test('Vérification des champs spécifiques Maçonnerie', () {
      final config = MetierRegistry.getByType(TypeAtelier.maconnerie);
      final keys = config.champs.map((c) => c.key).toList();
      expect(keys, contains('type_ouvrage'));
      expect(keys, isNot(contains('type_vetement')));
    });

    test('Vérification des champs spécifiques Bijouterie', () {
      final config = MetierRegistry.getByType(TypeAtelier.bijouterie);
      final keys = config.champs.map((c) => c.key).toList();
      expect(keys, contains('type_bijou'));
      expect(keys, isNot(contains('type_vetement')));
    });

    test('Vérification des champs spécifiques Coiffure', () {
      final config = MetierRegistry.getByType(TypeAtelier.coiffure);
      final keys = config.champs.map((c) => c.key).toList();
      expect(keys, contains('type_prestation'));
      expect(keys, isNot(contains('type_vetement')));
    });

    test('getFieldLabel() mappe correctement les clés aux libellés lisibles',
        () {
      // Test Couture
      expect(
        MetierRegistry.getFieldLabel('couture', 'type_vetement'),
        equals('Type de vêtement'),
      );
      expect(
        MetierRegistry.getFieldLabel('couture', 'tissu'),
        equals('Tissu'),
      );
      expect(
        MetierRegistry.getFieldLabel('couture', 'couleur'),
        equals('Couleur / Motifs'),
      );

      // Test Mécanique
      expect(
        MetierRegistry.getFieldLabel('mecanique', 'vehicule'),
        equals('Véhicule'),
      );
      expect(
        MetierRegistry.getFieldLabel('mecanique', 'kilometrage'),
        equals('Kilométrage'),
      );

      // Test Menuiserie
      expect(
        MetierRegistry.getFieldLabel('menuiserie', 'type_meuble'),
        equals('Type d\'ouvrage / Meuble'),
      );

      // Test clé inexistante — fallback sur la clé
      expect(
        MetierRegistry.getFieldLabel('couture', 'cle_inexistante'),
        equals('cle_inexistante'),
      );
    });

    test('Chaque métier a au moins un champ défini', () {
      for (final type in TypeAtelier.values) {
        final config = MetierRegistry.getByType(type);
        expect(
          config.champs.isNotEmpty,
          isTrue,
          reason: '${config.nom} (${config.id}) doit avoir au moins un champ',
        );
      }
    });

    test('Chaque champ a une clé et un libellé non vides', () {
      for (final type in TypeAtelier.values) {
        final config = MetierRegistry.getByType(type);
        for (final champ in config.champs) {
          expect(
            champ.key.isNotEmpty,
            isTrue,
            reason: 'Clé vide dans ${config.nom}',
          );
          expect(
            champ.label.isNotEmpty,
            isTrue,
            reason: 'Libellé vide dans ${config.nom} pour ${champ.key}',
          );
        }
      }
    });
  });
}
