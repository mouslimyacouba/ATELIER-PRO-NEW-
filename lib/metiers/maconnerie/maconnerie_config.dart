import '../../core/config/metier_config.dart';

const maconnerieConfig = MetierConfig(
  id: 'maconnerie',
  nom: 'Maçonnerie',
  champs: [
    ChampMetier(
      key: 'type_ouvrage',
      label: 'Type d\'ouvrage',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Mur de clôture', 'Fondations', 'Dalle en béton', 'Chambre / Extension', 'Bâtiment complet', 'Crépissage / Enduit', 'Autre'],
    ),
    ChampMetier(
      key: 'surface_volume',
      label: 'Surface / Dimensions (ex: 50 m²)',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'type_materiaux',
      label: 'Blocs / Matériaux principaux',
      type: TypeChampMetier.select,
      options: ['Parpaings (15/20)', 'Briques terre cuite', 'Béton armé', 'BTS (Terre stabilisée)', 'Pierres'],
    ),
  ],
  materiaux: [
    'Sacs de Ciment (CPJ 42.5)',
    'Sable de rivière',
    'Gravier',
    'Fers à béton (8, 10, 12 mm)',
    'Parpaings / Briques',
    'Planches de coffrage',
  ],
  etapes: [
    'Visite du site & Métré',
    'Commandes de matériaux & Préparation du sol',
    'Fouilles & Fondations',
    'Élévation des murs / Coulage béton',
    'Crépissage & Enduits de finition',
    'Nettoyage & Livraison du chantier',
  ],
);
