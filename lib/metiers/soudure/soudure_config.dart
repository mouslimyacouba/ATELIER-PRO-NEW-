import '../../core/config/metier_config.dart';

const soudureConfig = MetierConfig(
  id: 'soudure',
  nom: 'Métallerie / Soudure',
  champs: [
    ChampMetier(
      key: 'type_ouvrage',
      label: 'Type d\'ouvrage métallique',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Porte métallique', 'Fenêtre métallique', 'Portail', 'Grille de sécurité', 'Table / Chaise en fer', 'Étagère métallique', 'Lit métallique', 'Réparation métallique', 'Autre'],
    ),
    ChampMetier(
      key: 'dimensions',
      label: 'Dimensions (Largeur x Hauteur)',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'type_metal',
      label: 'Type de métal / profilé',
      type: TypeChampMetier.select,
      options: ['Tube carré', 'Tube rectangulaire', 'Cornière', 'Tôle', 'Fer rond / plat'],
    ),
    ChampMetier(
      key: 'epaisseur',
      label: 'Épaisseur',
      type: TypeChampMetier.text,
    ),
  ],
  materiaux: [
    'Tube carré et rectangulaire',
    'Cornière',
    'Tôle métallique',
    'Fer rond et fer plat',
    'Électrodes de soudure',
    'Disques de meuleuse',
    'Charnières, serrures et poignées',
    'Peinture antirouille',
    'Vis et boulons',
  ],
  etapes: [
    'Prise de mesures & Devis',
    'Découpe des profilés',
    'Assemblage & Pointage',
    'Soudure définitive',
    'Meulage & Finition des cordons',
    'Application de la peinture antirouille',
    'Pose des accessoires (charnières/serrure)',
    'Contrôle final & Livraison',
  ],
);
