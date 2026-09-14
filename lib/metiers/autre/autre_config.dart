import '../../core/config/metier_config.dart';

const autreConfig = MetierConfig(
  id: 'autre',
  nom: 'Autre artisanat / Général',
  champs: [
    ChampMetier(
      key: 'nom_prestation',
      label: 'Intitulé du besoin / Travail',
      type: TypeChampMetier.text,
      obligatoire: true,
    ),
    ChampMetier(
      key: 'specifications',
      label: 'Détails & Instructions particulières',
      type: TypeChampMetier.multiline,
    ),
  ],
  materiaux: [
    'Matériaux fournis par le client',
    'Consommables généraux',
  ],
  etapes: [
    'Analyse du besoin & Validation devis',
    'Préparation des matériaux & Outils',
    'Réalisation du travail',
    'Contrôle qualité final',
    'Remise / Livraison au client',
  ],
);
