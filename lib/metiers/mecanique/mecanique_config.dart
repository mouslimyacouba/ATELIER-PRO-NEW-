import '../../core/config/metier_config.dart';

const mecaniqueConfig = MetierConfig(
  id: 'mecanique',
  nom: 'Mécanique',
  champs: [
    ChampMetier(
      key: 'vehicule',
      label: 'Véhicule',
      type: TypeChampMetier.text,
      obligatoire: true,
    ),
    ChampMetier(
      key: 'marque_modele',
      label: 'Marque / Modèle',
      type: TypeChampMetier.text,
    ),
    ChampMetier(
      key: 'kilometrage',
      label: 'Kilométrage',
      type: TypeChampMetier.number,
    ),
  ],
  materiaux: [
    'Huile moteur',
    'Liquide de frein',
    'Filtre à huile',
    'Filtre à air',
    'Plaquettes de frein',
    'Liquide de refroidissement',
  ],
  etapes: [
    'Diagnostic complet',
    'Commande / Réception pièces',
    'Réparation / Montage',
    'Test de sécurité',
    'Nettoyage',
    'Remise au client',
  ],
);
