import '../../core/config/metier_config.dart';

const menuiserieConfig = MetierConfig(
  id: 'menuiserie',
  nom: 'Menuiserie',
  champs: [
    ChampMetier(
      key: 'type_meuble',
      label: 'Type d\'ouvrage / Meuble',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Table', 'Chaise', 'Armoire', 'Lit', 'Porte', 'Fenêtre', 'Étagère', 'Autre'],
    ),
    ChampMetier(
      key: 'bois',
      label: 'Type de bois / Matériau principal',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'dimensions',
      label: 'Dimensions (L x l x h cm)',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'finition',
      label: 'Finition souhaitée',
      type: TypeChampMetier.select,
      options: ['Vernis clair', 'Vernis foncé', 'Peinture', 'Brut poncé', 'Huilé', 'Laqué'],
    ),
  ],
  materiaux: [
    'Bois d\'œuvre (Iroko, Teak, etc.)',
    'Panneaux contreplaqué / MDF',
    'Colle à bois',
    'Vis & Clous',
    'Charnières / Quincaillerie',
    'Vernis / Peinture',
    'Papier de verre',
  ],
  etapes: [
    'Prise de cotes & Plan',
    'Débit et découpe des pièces',
    'Rabotage & Usinage',
    'Assemblage à blanc & Collages',
    'Ponçage & Finition / Vernis',
    'Livraison & Pose chez le client',
  ],
);
