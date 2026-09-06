import 'champ_fiche.dart';
import 'type_atelier.dart';

class FicheTemplate {
  final TypeAtelier typeAtelier;
  final String nomFiche; // ex: "Fiche de mesures", "Fiche véhicule"
  final List<ChampFiche> champs;

  const FicheTemplate({
    required this.typeAtelier,
    required this.nomFiche,
    required this.champs,
  });
}
