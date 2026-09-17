import 'metier_config.dart';
import '../../models/type_atelier.dart';
import '../../metiers/couture/couture_config.dart';
import '../../metiers/mecanique/mecanique_config.dart';
import '../../metiers/menuiserie/menuiserie_config.dart';
import '../../metiers/cordonnerie/cordonnerie_config.dart';
import '../../metiers/maconnerie/maconnerie_config.dart';
import '../../metiers/bijouterie/bijouterie_config.dart';
import '../../metiers/coiffure/coiffure_config.dart';
import '../../metiers/soudure/soudure_config.dart';
import '../../metiers/autre/autre_config.dart';

class MetierRegistry {
  static const Map<String, MetierConfig> metiers = {
    'couture': coutureConfig,
    'mecanique': mecaniqueConfig,
    'menuiserie': menuiserieConfig,
    'cordonnerie': cordonnerieConfig,
    'maconnerie': maconnerieConfig,
    'bijouterie': bijouterieConfig,
    'coiffure': coiffureConfig,
    'soudure': soudureConfig,
    'autre': autreConfig,
  };

  static MetierConfig getById(String? id) {
    if (id == null) return autreConfig;
    return metiers[id] ?? autreConfig;
  }

  static MetierConfig getByType(TypeAtelier type) {
    return metiers[type.id] ?? autreConfig;
  }

  /// Récupère le libellé (label) d'un champ à partir de sa clé (key)
  /// et de la config du métier. Si pas trouvé, retourne la clé.
  static String getFieldLabel(String metierKey, String fieldKey) {
    final config = getById(metierKey);
    try {
      return config.champs.firstWhere((c) => c.key == fieldKey).label;
    } catch (_) {
      return fieldKey;
    }
  }
}
