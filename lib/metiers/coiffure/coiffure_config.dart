import '../../core/config/metier_config.dart';

const coiffureConfig = MetierConfig(
  id: 'coiffure',
  nom: 'Coiffure & Esthétique',
  champs: [
    ChampMetier(
      key: 'type_prestation',
      label: 'Type de prestation',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: [
        'Tresses / Nattes / Locks',
        'Coupe & Barbe (Homme)',
        'Coiffure événement / Mariage',
        'Coloration / Défrisage',
        'Pose perruque / Tissage',
        'Soin capillaire profond',
        'Autre'
      ],
    ),
    ChampMetier(
      key: 'longeur_nature',
      label: 'Nature / Longueur des cheveux',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'meches_fournies',
      label: 'Origine des mèches / Rajouts',
      type: TypeChampMetier.select,
      options: ['Fournies par le salon', 'Apportées par le client', 'Sans rajouts'],
    ),
  ],
  materiaux: [
    'Paquets de mèches / Tissage',
    'Shampooing & Après-shampooing',
    'Huiles capillaires (Karité, Argan)',
    'Gel / Wax / Laque fixante',
    'Produits de coloration / Décoloration',
  ],
  etapes: [
    'Accueil & Shampoing préparatoire',
    'Démêlage & Séchage',
    'Réalisation de la prestation (Tresses/Coupe)',
    'Coiffage, Fixation & Finition',
    'Conseils d\'entretien à la cliente',
  ],
);
