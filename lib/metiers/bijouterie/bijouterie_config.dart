import '../../core/config/metier_config.dart';

const bijouterieConfig = MetierConfig(
  id: 'bijouterie',
  nom: 'Bijouterie',
  champs: [
    ChampMetier(
      key: 'type_bijou',
      label: 'Type de bijou',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Bague / Alliance', 'Collier / Chapelet', 'Bracelet', 'Boucles d\'oreilles', 'Pendentif', 'Ensemble / Parure', 'Autre'],
    ),
    ChampMetier(
      key: 'metal',
      label: 'Métal précieux / Alliage',
      type: TypeChampMetier.select,
      obligatoire: true,
      options: ['Or 18 carats', 'Or 24 carats', 'Argent 925', 'Plaqué or', 'Bronze / Cuivre'],
    ),
    ChampMetier(
      key: 'poids_grammes',
      label: 'Poids estimé (en grammes)',
      type: TypeChampMetier.number,
    ),
    ChampMetier(
      key: 'pierres',
      label: 'Pierres / Sertissage (optionnel)',
      type: TypeChampMetier.text,
    ),
  ],
  materiaux: [
    'Métal brut (Or, Argent)',
    'Pierres fines / Ornements',
    'Alliage de soudure',
    'Pâte à polir',
    'Écrin / Emballage',
  ],
  etapes: [
    'Validation du dessin & Pesée initiale',
    'Fonte du métal & Laminage/Tréfilage',
    'Façonnage du bijou & Soudures',
    'Sertissage des pierres',
    'Polissage & Lavage ultrason',
    'Pesée finale & Remise en écrin',
  ],
);
