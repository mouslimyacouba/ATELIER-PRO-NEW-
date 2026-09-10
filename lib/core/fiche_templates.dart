import '../models/champ_fiche.dart';
import '../models/fiche_template.dart';
import '../models/type_atelier.dart';

/// Templates de fiche par métier, en dur dans le code (pas en base) — reste
/// simple à modifier et suffisant au stade prototype. Pour ajouter un 9e
/// métier plus tard : ajouter une valeur à [TypeAtelier] et une entrée ici,
/// rien d'autre à toucher (voir note en fin de fichier).
final Map<TypeAtelier, FicheTemplate> ficheTemplates = {
  TypeAtelier.couture: const FicheTemplate(
    typeAtelier: TypeAtelier.couture,
    nomFiche: 'Fiche de mesures',
    champs: [
      ChampFiche(id: 'tour_poitrine', label: 'Tour de poitrine', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(id: 'tour_taille', label: 'Tour de taille', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(id: 'tour_bassin', label: 'Tour de bassin', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(id: 'longueur_manche', label: 'Longueur manche', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(
        id: 'longueur_robe_pantalon',
        label: 'Longueur robe/pantalon',
        typeChamp: TypeChamp.nombre,
        unite: 'cm',
      ),
    ],
  ),
  TypeAtelier.menuiserie: const FicheTemplate(
    typeAtelier: TypeAtelier.menuiserie,
    nomFiche: 'Fiche meuble',
    champs: [
      ChampFiche(
        id: 'type_meuble',
        label: 'Type de meuble',
        typeChamp: TypeChamp.liste,
        obligatoire: true,
        options: ['Armoire', 'Lit', 'Table', 'Chaise', 'Porte', 'Fenêtre', 'Autre'],
      ),
      ChampFiche(id: 'longueur', label: 'Longueur', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(id: 'largeur', label: 'Largeur', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(id: 'hauteur', label: 'Hauteur', typeChamp: TypeChamp.nombre, unite: 'cm'),
      ChampFiche(
        id: 'essence_bois',
        label: 'Essence de bois',
        typeChamp: TypeChamp.liste,
        options: ['Acajou', 'Iroko', 'Contreplaqué', 'Autre'],
      ),
      ChampFiche(id: 'finition', label: 'Finition souhaitée', typeChamp: TypeChamp.texte),
    ],
  ),
  TypeAtelier.mecanique: const FicheTemplate(
    typeAtelier: TypeAtelier.mecanique,
    nomFiche: 'Fiche véhicule',
    champs: [
      ChampFiche(id: 'marque_modele', label: 'Marque / Modèle', typeChamp: TypeChamp.texte, obligatoire: true),
      ChampFiche(id: 'immatriculation', label: 'Immatriculation', typeChamp: TypeChamp.texte),
      ChampFiche(id: 'kilometrage', label: 'Kilométrage', typeChamp: TypeChamp.nombre, unite: 'km'),
      ChampFiche(
        id: 'type_panne',
        label: 'Type de panne',
        typeChamp: TypeChamp.liste,
        options: ['Moteur', 'Freinage', 'Électrique', 'Carrosserie', 'Suspension', 'Autre'],
      ),
      ChampFiche(id: 'description_panne', label: 'Description de la panne', typeChamp: TypeChamp.texte),
    ],
  ),
  TypeAtelier.maconnerie: const FicheTemplate(
    typeAtelier: TypeAtelier.maconnerie,
    nomFiche: 'Fiche chantier',
    champs: [
      ChampFiche(
        id: 'type_travaux',
        label: 'Type de travaux',
        typeChamp: TypeChamp.liste,
        obligatoire: true,
        options: ['Construction', 'Rénovation', 'Peinture', 'Carrelage', 'Plomberie', 'Autre'],
      ),
      ChampFiche(id: 'surface', label: 'Surface', typeChamp: TypeChamp.nombre, unite: 'm²'),
      ChampFiche(id: 'materiaux_prevus', label: 'Matériaux prévus', typeChamp: TypeChamp.texte),
    ],
  ),
  TypeAtelier.bijouterie: const FicheTemplate(
    typeAtelier: TypeAtelier.bijouterie,
    nomFiche: 'Fiche bijou',
    champs: [
      ChampFiche(
        id: 'type_bijou',
        label: 'Type de bijou',
        typeChamp: TypeChamp.liste,
        options: ['Bague', 'Collier', 'Bracelet', 'Boucles d\'oreilles', 'Autre'],
      ),
      ChampFiche(id: 'poids_metal', label: 'Poids métal', typeChamp: TypeChamp.nombre, unite: 'g'),
      ChampFiche(id: 'type_pierre', label: 'Type de pierre', typeChamp: TypeChamp.texte),
      ChampFiche(id: 'taille', label: 'Taille (bagues)', typeChamp: TypeChamp.texte),
    ],
  ),
  TypeAtelier.coiffure: const FicheTemplate(
    typeAtelier: TypeAtelier.coiffure,
    nomFiche: 'Fiche prestation',
    champs: [
      ChampFiche(
        id: 'type_prestation',
        label: 'Type de prestation',
        typeChamp: TypeChamp.liste,
        obligatoire: true,
        options: ['Coupe', 'Tresses', 'Défrisage', 'Coloration', 'Soin', 'Autre'],
      ),
      ChampFiche(id: 'produits_utilises', label: 'Produits utilisés', typeChamp: TypeChamp.texte),
    ],
  ),
  TypeAtelier.autre: const FicheTemplate(
    typeAtelier: TypeAtelier.autre,
    nomFiche: 'Fiche client',
    champs: [
      ChampFiche(id: 'champ_1', label: 'Champ 1', typeChamp: TypeChamp.texte),
      ChampFiche(id: 'champ_2', label: 'Champ 2', typeChamp: TypeChamp.texte),
      ChampFiche(id: 'champ_3', label: 'Champ 3', typeChamp: TypeChamp.texte),
    ],
  ),
};

/// Note extensibilité — ajouter un 9e métier (ex: "Électronique") :
/// 1. Ajouter `electronique` à l'enum `TypeAtelier` (+ son `dbValue`).
/// 2. Ajouter une entrée `TypeAtelier.electronique: FicheTemplate(...)` ici.
/// Aucun écran (formulaire, liste, dashboard) n'a besoin d'être modifié :
/// tout est piloté par ce fichier de configuration.
