enum TypeChamp { texte, nombre, liste, date }

class ChampFiche {
  final String id; // clé unique dans la map `donnees` (mesures jsonb)
  final String label;
  final TypeChamp typeChamp;
  final String? unite; // ex: "cm", "kg", "m²"
  final List<String>? options; // pour typeChamp == liste
  final bool obligatoire;

  const ChampFiche({
    required this.id,
    required this.label,
    required this.typeChamp,
    this.unite,
    this.options,
    this.obligatoire = false,
  });
}
