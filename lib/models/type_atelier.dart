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
  cordonnerie,
  maconnerie,
  bijouterie,
  coiffure,
  soudure,
  autre;

  String get id => name;

  String get dbValue {
    switch (this) {
      case TypeAtelier.couture:
        return 'Couture / Confection';
      case TypeAtelier.menuiserie:
        return 'Menuiserie';
      case TypeAtelier.mecanique:
        return 'Mécanique (auto/moto)';
      case TypeAtelier.cordonnerie:
        return 'Cordonnerie / Maroquinerie';
      case TypeAtelier.maconnerie:
        return 'Maçonnerie';
      case TypeAtelier.bijouterie:
        return 'Bijouterie';
      case TypeAtelier.coiffure:
        return 'Coiffure';
      case TypeAtelier.soudure:
        return 'Métallerie / Soudure';
      case TypeAtelier.autre:
        return 'Autre';
    }
  }

  static TypeAtelier fromDbValue(String? value) {
    if (value == null || value.trim().isEmpty) return TypeAtelier.autre;
    final valLower = value.toLowerCase();
    if (valLower.contains('couture') || valLower.contains('confection')) return TypeAtelier.couture;
    if (valLower.contains('menuis')) return TypeAtelier.menuiserie;
    if (valLower.contains('mecanique') || valLower.contains('mécanique') || valLower.contains('garage')) return TypeAtelier.mecanique;
    if (valLower.contains('cordonnerie') || valLower.contains('maroquinerie')) return TypeAtelier.cordonnerie;
    if (valLower.contains('maconnerie') || valLower.contains('maçonnerie')) return TypeAtelier.maconnerie;
    if (valLower.contains('bijou')) return TypeAtelier.bijouterie;
    if (valLower.contains('coiff')) return TypeAtelier.coiffure;
    if (valLower.contains('soudure') || valLower.contains('metallerie') || valLower.contains('métallerie') || valLower.contains('soudeur')) return TypeAtelier.soudure;
    return TypeAtelier.values.firstWhere(
      (t) => t.dbValue == value,
      orElse: () => TypeAtelier.autre,
    );
  }
}

