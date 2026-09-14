import '../../core/config/metier_config.dart';

const cordonnerieConfig = MetierConfig(
  id: 'cordonnerie',
  nom: 'Cordonnerie / Maroquinerie',
  champs: [
    ChampMetier(
      key: 'type_article',
      label: 'Type d\'article',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Chaussures', 'Bottes / Bottines', 'Sac à main', 'Ceinture', 'Portefeuille', 'Veste en cuir', 'Autre'],
    ),
    ChampMetier(
      key: 'matiere',
      label: 'Matière / Cuir',
      type: TypeChampMetier.select,
      options: ['Cuir lisses', 'Daim / Velours', 'Simili / Synthétique', 'Toile', 'Cuir exotique'],
    ),
    ChampMetier(
      key: 'type_intervention',
      label: 'Nature de l\'intervention',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Réparation / Ressemelage', 'Fabrication sur-mesure', 'Teinture / Rénovation', 'Changement fermeture/boucle'],
    ),
    ChampMetier(
      key: 'pointure_taille',
      label: 'Pointure / Dimensions',
      type: TypeChampMetier.text,
    ),
  ],
  materiaux: [
    'Cuir / Peausserie',
    'Semelles (caoutchouc, cuir)',
    'Colle forte / Cordonnerie',
    'Fil poissé renforcé',
    'Boucles & Rivets metal',
    'Teinture & Cirage professionnel',
  ],
  etapes: [
    'Réception & Diagnostic de l\'article',
    'Démontage / Préparation de la matière',
    'Découpe des pièces & Couture',
    'Pose de semelle / Pièces métalliques',
    'Bichonnage, Teinture & Cirage',
    'Remise au client',
  ],
);
