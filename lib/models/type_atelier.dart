/// Les différents métiers artisanaux supportés. La valeur `dbValue` est ce
/// qui est stocké dans `ateliers.specialite` (colonne texte libre existante,
/// aucune migration de schéma nécessaire) — `fromDbValue` retombe sur
/// [autre] pour toute valeur inconnue ou ancienne (rétrocompatibilité avec
/// les libellés utilisés avant cette généralisation, ex: "Sérigraphie",
/// "Maroquinerie").
enum TypeAtelier {
  couture,
  menuiserie,
  mecanique,
  maconnerie,
  bijouterie,
  coiffure,
  autre;

  String get dbValue {
    switch (this) {
      case TypeAtelier.couture:
        return 'Couture / Confection';
      case TypeAtelier.menuiserie:
        return 'Menuiserie';
      case TypeAtelier.mecanique:
        return 'Mécanique (auto/moto)';
      case TypeAtelier.maconnerie:
        return 'Maçonnerie';
      case TypeAtelier.bijouterie:
        return 'Bijouterie';
      case TypeAtelier.coiffure:
        return 'Coiffure';
      case TypeAtelier.autre:
        return 'Autre';
    }
  }

  static TypeAtelier fromDbValue(String? value) {
    if (value == null) return TypeAtelier.autre;
    return TypeAtelier.values.firstWhere(
      (t) => t.dbValue == value,
      orElse: () => TypeAtelier.autre,
    );
  }
}
