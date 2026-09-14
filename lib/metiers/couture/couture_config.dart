import '../../core/config/metier_config.dart';

const coutureConfig = MetierConfig(
  id: 'couture',
  nom: 'Couture',
  champs: [
    ChampMetier(
      key: 'type_vetement',
      label: 'Type de vêtement',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Boubou', 'Costume', 'Robe', 'Chemise', 'Pantalon', 'Jupe'],
    ),
    ChampMetier(
      key: 'tissu',
      label: 'Tissu',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'couleur',
      label: 'Couleur / Motifs',
      type: TypeChampMetier.text,
    ),
  ],
  materiaux: [
    'Tissu',
    'Fil',
    'Boutons',
    'Fermeture éclair',
    'Doublure',
    'Élastique',
  ],
  etapes: [
    'Prise de mesures',
    'Découpe du tissu',
    'Assemblage / Bâti',
    'Couture et finitions',
    'Repassage',
    'Livraison au client',
  ],
);
