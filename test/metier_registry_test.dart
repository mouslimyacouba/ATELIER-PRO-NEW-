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
  });
}
