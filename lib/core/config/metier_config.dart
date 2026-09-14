/// Types de champs dynamiques pris en charge par le moteur générique.
enum TypeChampMetier {
  text,
  number,
  select,
  date,
  multiline,
  boolean,
}

/// Représentation d'un champ personnalisé propre à un métier.
class ChampMetier {
  final String key;
  final String label;
  final TypeChampMetier type;
  final bool obligatoire;
  final List<String> options;

  const ChampMetier({
    required this.key,
    required this.label,
    this.type = TypeChampMetier.text,
    this.obligatoire = false,
    this.options = const [],
  });
}

/// Contrat universel définissant les spécificités d'un métier (Couture, Mécanique, etc.)
class MetierConfig {
  final String id;
  final String nom;
  final List<ChampMetier> champs;
  final List<String> materiaux;
  final List<String> etapes;

  const MetierConfig({
    required this.id,
    required this.nom,
    this.champs = const [],
    this.materiaux = const [],
    this.etapes = const [],
  });
}
