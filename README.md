# 🛠️ AtelierPro Mobile

> **La gestion simple pour les artisans. 🇳🇪**

**AtelierPro Mobile** est une application Flutter open source conçue pour aider les artisans à gérer leur atelier depuis leur téléphone : **clients, commandes, fiches métier, paiements, fabrication, modèles et stock**.

Le projet est développé avec une première cible au **Niger**, avec une approche adaptée aux réalités des petits ateliers : Android prioritaire, FCFA, téléphone, WhatsApp, connexion Internet parfois limitée et besoin de simplicité.

---

## 🎯 Le problème

Dans de nombreux petits ateliers, la gestion repose encore sur :

* 📒 des cahiers pour les clients ;
* 📝 des notes papier pour les commandes ;
* 🧠 la mémoire pour suivre les paiements ;
* 📱 WhatsApp pour communiquer ;
* 📦 peu de suivi du stock ;
* 🏭 peu de visibilité sur l'avancement des travaux.

AtelierPro cherche à transformer progressivement cette organisation en un **atelier numérique simple et pratique**.

### Le parcours principal

```text
Client
   ↓
Commande
   ↓
Fiche métier
   ↓
Paiement
   ↓
Fabrication
   ↓
Suivi
   ↓
Livraison
```

---

# 🚀 État actuel du projet

**Version : 1.0.0+1**

**Statut : prototype fonctionnel / stabilisation V1.1**

Le dépôt actuel contient déjà plusieurs briques qui dépassent la simple gestion de clients et commandes :

* authentification Firebase ;
* gestion d'atelier ;
* gestion des clients ;
* commandes ;
* fiches métier dynamiques ;
* 9 métiers artisanaux ;
* paiements manuels ;
* calcul du solde ;
* numérotation des commandes `CMD-XXXX` ;
* étapes de fabrication ;
* progression des commandes ;
* modèles de fabrication ;
* gestion du stock ;
* calendrier ;
* historique des modifications ;
* notifications de retard ;
* partage de bilan ;
* communication WhatsApp ;
* règles Firestore et Storage ;
* tests automatisés ;
* support Android et Web.

Le projet reste cependant en phase de **stabilisation et de validation terrain** avant une utilisation à grande échelle.

---

# ✨ Fonctionnalités disponibles

## 👤 Gestion des clients

Un atelier peut gérer son fichier client directement depuis l'application.

### Disponible

* Ajouter un client
* Modifier un client
* Supprimer un client
* Nom complet
* Numéro de téléphone
* Adresse
* Notes
* Photo
* Historique lié aux commandes

---

# 📦 Gestion des commandes

Chaque commande peut contenir notamment :

* Client
* Description
* Métier
* Fiche métier
* Prix total
* Acompte
* Solde restant
* Date de commande
* Date d'échéance
* Statut
* Numéro de commande
* Spécifications propres au métier
* Étapes de fabrication

### Numérotation

Les commandes utilisent une référence lisible :

```text
CMD-0001
CMD-0002
CMD-0003
...
CMD-0100
```

Cette numérotation est générée à partir d'un compteur propre à l'utilisateur.

### Statuts

Le système permet notamment de suivre le cycle d'une commande :

```text
En attente
    ↓
En cours
    ↓
Prête
    ↓
Livrée
```

avec également la possibilité de gérer les commandes annulées selon le workflow de l'application.

---

# 📋 Fiches métier dynamiques

L'une des fonctionnalités centrales d'AtelierPro est son architecture **multi-métiers**.

Le formulaire de commande peut afficher des champs différents selon le métier de l'atelier.

## Métiers actuellement supportés

| Métier                        | Exemple de données                      |
| ----------------------------- | --------------------------------------- |
| 👕 Couture / Confection       | mesures, vêtement, tissu, couleur       |
| 🪑 Menuiserie                 | ouvrage, dimensions, bois, finition     |
| 🚗 Mécanique                  | véhicule, kilométrage, panne            |
| 👞 Cordonnerie / Maroquinerie | article, matière, dimensions            |
| 🧱 Maçonnerie                 | ouvrage, travaux, dimensions            |
| 💍 Bijouterie                 | type de bijou, poids, pierre            |
| 💇 Coiffure                   | prestation, produits                    |
| 🔧 Métallerie / Soudure       | ouvrage métallique, dimensions, matière |
| 🧰 Autre                      | champs génériques                       |

### Architecture

Le métier est représenté par :

```dart
enum TypeAtelier
```

Les configurations sont centralisées dans le registre métier.

```text
TypeAtelier
     ↓
MetierRegistry
     ↓
Configuration du métier
     ↓
Champs dynamiques
     ↓
Commande
```

L'objectif est de pouvoir ajouter progressivement de nouveaux métiers sans modifier les écrans principaux.

---

# 🏭 Fabrication

AtelierPro commence également à intégrer la gestion du processus de fabrication.

Une commande peut conserver un instantané de ses étapes :

```text
Commande
   │
   ├── Découpe
   ├── Assemblage
   ├── Finition
   └── Livraison
```

La progression peut être calculée à partir des étapes terminées.

Exemple :

```text
1 étape terminée / 3

Progression : 33 %
```

Cela prépare AtelierPro à évoluer vers une véritable gestion de production adaptée aux ateliers.

---

# 🧩 Modèles de fabrication

Les ateliers peuvent définir des **modèles de fabrication** réutilisables.

Un modèle peut notamment contenir :

* Nom
* Type de produit
* Description
* Champs de mesures
* Matériaux par défaut
* Étapes de fabrication
* Prix indicatif
* Photo
* État actif/inactif

Les modèles sont synchronisés avec Firestore en temps réel.

---

# 📦 Gestion du stock

Une première gestion du stock est déjà présente.

### Disponible

* Ajouter un article
* Modifier un article
* Supprimer un article
* Quantité
* Détection de stock faible
* Suivi par atelier
* Mise à jour temps réel
* Consommation de matériaux

Le système peut également déduire des quantités lorsque des matériaux sont associés à une fabrication.

---

# 💰 Paiements

Les paiements peuvent être enregistrés manuellement.

Chaque paiement peut contenir :

* Montant
* Mode de paiement
* Date
* Commande associée
* Identifiant utilisateur

Le système permet de calculer :

```text
Prix total
    -
Paiements
    =
Solde restant
```

### Exemple

```text
Commande : 150 000 FCFA

Acompte : 50 000 FCFA

Reste : 100 000 FCFA
```

---

## 📱 Mobile Money

L'intégration directe avec les services Mobile Money **n'est pas encore activée**.

Elle pourra être étudiée ultérieurement selon les conditions techniques, commerciales et les API réellement disponibles.

Le projet pourra notamment explorer les services disponibles au Niger et dans la région.

---

# 📅 Calendrier et échéances

AtelierPro possède un écran calendrier permettant de visualiser les échéances des commandes.

Le système peut également détecter les commandes en retard.

Une commande non livrée dont l'échéance est dépassée peut être identifiée comme :

```text
⚠️ En retard
```

L'objectif est de réduire les oublis et les retards de livraison.

---

# 🔔 Notifications

Le projet contient également une base de notifications locales permettant notamment de préparer les rappels liés aux échéances.

L'objectif est d'aider l'artisan à ne pas oublier :

* les commandes à livrer ;
* les échéances proches ;
* les commandes en retard.

---

# 📊 Tableau de bord

Le dashboard fournit une vue synthétique de l'activité de l'atelier.

Il peut notamment afficher :

* chiffre d'affaires ;
* montant restant à encaisser ;
* nombre de clients ;
* nombre de commandes ;
* commandes ouvertes ;
* commandes en retard ;
* commandes à livrer prochainement ;
* paiements récents ;
* progression de l'activité.

Un **bilan de l'atelier peut également être partagé**.

---

# 📱 WhatsApp

AtelierPro utilise WhatsApp comme moyen de communication complémentaire avec les clients.

L'objectif est de faciliter l'envoi d'informations telles que :

* état de la commande ;
* montant restant ;
* commande prête ;
* informations de livraison.

AtelierPro ne cherche pas à remplacer WhatsApp mais à **préparer les informations nécessaires avant leur envoi**.

---

# 🏗️ Architecture technique

AtelierPro est construit avec **Flutter + Firebase**.

```text
                    AtelierPro
                         │
              ┌──────────┴──────────┐
              │                     │
             UI                 Providers
              │                     │
              └──────────┬──────────┘
                         │
                      Models
                         │
                  Core / Services
                         │
                         ▼
                      Firebase
              ┌──────────┼──────────┐
              ▼          ▼          ▼
          Auth       Firestore    Storage
```

L'architecture actuelle utilise principalement :

* Screens
* Widgets
* Providers
* Models
* Core
* Services
* Firebase

Une évolution progressive vers une architecture avec **Repositories** est prévue pour les prochaines versions.

---

# 🧰 Stack technique

| Technologie                 | Utilisation               |
| --------------------------- | ------------------------- |
| Flutter                     | Application               |
| Dart                        | Langage                   |
| Firebase Authentication     | Authentification          |
| Cloud Firestore             | Données                   |
| Firebase Storage            | Photos et fichiers        |
| Provider                    | Gestion d'état            |
| GoRouter                    | Navigation                |
| Flutter Local Notifications | Notifications             |
| Connectivity Plus           | Détection de connectivité |
| Shared Preferences          | Stockage local            |
| Flutter Dotenv              | Configuration locale      |
| Image Picker                | Photos                    |
| Share Plus                  | Partage                   |
| Google Sign-In              | Authentification Google   |

---

# 🗂️ Structure du projet

La structure actuelle comprend notamment :

```text
lib/
├── core/
│   ├── config/
│   ├── services/
│   └── theme/
│
├── models/
│
├── providers/
│
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── dashboard/
│   ├── clients/
│   ├── orders/
│   ├── mesures/
│   ├── modeles/
│   ├── stock/
│   ├── calendrier/
│   ├── historique/
│   ├── settings/
│   └── shell/
│
├── widgets/
│
└── firebase_options.dart

firebase/
├── firestore.rules
├── storage.rules
└── firestore.indexes.json

test/
├── firebase_options_test.dart
├── metier_registry_test.dart
├── phase3_4_5_6_validation_test.dart
├── security_rules_test.dart
└── widget_test.dart
```

---

# 🔥 Architecture Firestore

Les principales collections utilisées sont :

```text
ateliers/{userId}

clients/{documentId}

commandes/{documentId}

fiches/{documentId}

paiements/{documentId}

modeles/{documentId}

stock/{documentId}

historique_modifications/{documentId}

compteurs/{userId}
```

Les documents métier utilisent un champ :

```text
userId
```

pour rattacher les données à l'atelier de l'utilisateur.

---

## 🔐 Sécurité Firebase

La sécurité repose notamment sur :

* Firebase Authentication ;
* vérification de l'e-mail ;
* règles Firestore ;
* règles Firebase Storage ;
* contrôle de propriété par `userId` ;
* protection contre le changement de propriétaire ;
* séparation des données entre utilisateurs.

Les paiements et l'historique des modifications disposent également de règles spécifiques afin de préserver leur intégrité.

### Storage

Les fichiers sont organisés par utilisateur :

```text
logos/{userId}/
photos/{userId}/
commandes/{userId}/
modeles_etapes/{userId}/
```

Les uploads sont limités en taille par les règles Storage.

> ⚠️ Les règles doivent toujours être testées dans l'environnement Firebase avant une utilisation en production.

---

# 🧪 Tests

Le dépôt contient plusieurs tests automatisés.

Ils couvrent notamment :

### Métier

* présence des configurations ;
* unicité des configurations ;
* champs spécifiques à chaque métier ;
* libellés lisibles ;
* validation des champs.

### Commandes

* sérialisation ;
* spécifications métier ;
* numérotation `CMD-XXXX` ;
* étapes de fabrication ;
* progression.

### Paiements

* calcul du solde ;
* commande entièrement payée.

### Calendrier

* détection des échéances dépassées.

### Sécurité

* synchronisation des règles ;
* propriété des documents ;
* protection des collections ;
* protection Firebase Storage.

Lancer les tests :

```bash
flutter test
```

Analyser le projet :

```bash
flutter analyze
```

Formater le code :

```bash
dart format .
```

---

# 🤖 Intégration continue

Le dépôt contient également une configuration GitHub Actions :

```text
.github/workflows/dart.yml
```

Elle permet d'automatiser notamment l'analyse et les tests du projet.

---

# 🛠️ Installation

## Prérequis

Installer :

* Flutter SDK ;
* Dart ;
* Android Studio ;
* Git ;
* VS Code ou un autre IDE ;
* un appareil Android ou un émulateur.

Vérifier Flutter :

```bash
flutter doctor
```

---

# 📥 Cloner le dépôt

```bash
git clone https://github.com/mouslimyacouba/ATELIER-PRO-NEW-.git
```

Puis :

```bash
cd ATELIER-PRO-NEW-
```

---

# 📦 Installer les dépendances

```bash
flutter pub get
```

---

# 🔥 Configuration Firebase

AtelierPro utilise Firebase.

La configuration locale doit être fournie par le développeur ou configurée avec FlutterFire.

```bash
flutterfire configure
```

Les fichiers de configuration Firebase propres à l'environnement ne doivent pas être commités dans le dépôt.

---

# 🔑 Variables d'environnement

Le projet utilise un fichier :

```text
.env
```

Un modèle est fourni :

```text
.env.example
```

Créer la configuration locale à partir de ce modèle puis renseigner les valeurs nécessaires.

### Important

Ne jamais publier :

```text
.env
google-services.json
GoogleService-Info.plist
```

ni aucune autre donnée secrète.

Les fichiers sensibles sont exclus du dépôt via `.gitignore`.

---

# 🔐 Google Sign-In

Pour activer :

```text
Continuer avec Google
```

Google doit être activé dans Firebase Authentication.

Pour Android, les empreintes SHA-1 et SHA-256 de l'application doivent également être configurées dans Firebase.

---

# ▶️ Lancer l'application

Vérifier les appareils :

```bash
flutter devices
```

Puis :

```bash
flutter run
```

---

# 🌐 Support Web

Le dépôt contient également les fichiers nécessaires au support Flutter Web.

```text
web/
```

Le Web sert notamment aux tests et à la vérification de certaines fonctionnalités.

La cible principale du projet reste toutefois **Android**, correspondant au contexte initial d'utilisation.

---

# 📦 Générer l'APK

Pour construire une version release :

```bash
flutter build apk --release
```

Le fichier généré se trouve généralement dans :

```text
build/app/outputs/flutter-apk/app-release.apk
```

Pour une distribution Google Play, une configuration de signature et un build adapté au Play Store seront nécessaires.

---

# 🗺️ Roadmap

## ✅ V1 — Base fonctionnelle

* [x] Authentification
* [x] Vérification e-mail
* [x] Google Sign-In
* [x] Gestion de l'atelier
* [x] Gestion des clients
* [x] Gestion des commandes
* [x] Fiches métier dynamiques
* [x] 9 métiers
* [x] Paiements manuels
* [x] Calcul du solde
* [x] Numérotation `CMD-XXXX`
* [x] Étapes de fabrication
* [x] Progression de fabrication
* [x] Modèles de fabrication
* [x] Gestion du stock
* [x] Calendrier
* [x] Historique des modifications
* [x] Détection des retards
* [x] Notifications
* [x] Partage de bilan
* [x] Support WhatsApp
* [x] Firebase
* [x] Sécurité Firestore
* [x] Sécurité Storage
* [x] Tests automatisés
* [x] Licence MIT

---

# 🚧 V1.1 — Stabilisation et terrain

Objectif : préparer AtelierPro aux **premiers utilisateurs réels**.

### Fiabilité

* [ ] Tests Android sur plusieurs appareils
* [ ] Tests hors connexion / reconnexion
* [ ] Gestion complète des erreurs Firebase
* [ ] Amélioration des états loading / empty / error
* [ ] Validation complète des formulaires
* [ ] Tests de régression

### Commandes

* [ ] Amélioration du workflow de statut
* [ ] Amélioration des références de commande
* [ ] Reçus de commande
* [ ] Reçus de paiement
* [ ] Amélioration du partage WhatsApp

### Stock

* [ ] Historique des mouvements
* [ ] Entrées / sorties
* [ ] Seuil configurable
* [ ] Lien stock ↔ commande plus complet

### Sécurité

* [ ] Audit complet Firestore
* [ ] Audit Storage
* [ ] Tests de sécurité avec Firebase Emulator Suite
* [ ] Vérification des permissions par scénario

### Terrain

* [ ] Tests avec des artisans
* [ ] Collecte des retours
* [ ] Identification des fonctionnalités réellement utilisées
* [ ] Amélioration UX à partir des retours terrain

---

# 🚀 V2 — Assistant numérique d'atelier

La V2 doit faire évoluer AtelierPro d'un outil de gestion vers un **assistant numérique complet pour l'atelier**.

## 🏭 Production

* [ ] Workflow configurable par métier
* [ ] Étapes personnalisables
* [ ] Suivi de production
* [ ] Temps de fabrication
* [ ] Retards
* [ ] Historique des étapes
* [ ] Notifications avancées

## 💰 Gestion financière

* [ ] Coût des matériaux
* [ ] Coût de production
* [ ] Marge estimée
* [ ] Chiffre d'affaires par période
* [ ] Paiements en attente
* [ ] Dépenses
* [ ] Bilan financier

## 📦 Stock avancé

* [ ] Mouvements de stock
* [ ] Entrées
* [ ] Sorties
* [ ] Stock minimum
* [ ] Consommation par commande
* [ ] Coût des matériaux

## 🤝 Fournisseurs

* [ ] Liste des fournisseurs
* [ ] Contacts
* [ ] Produits
* [ ] Prix
* [ ] Historique des achats

## 💳 Paiements

* [ ] Références de transaction
* [ ] Reçus avancés
* [ ] Intégration Mobile Money
* [ ] Intégration de services de paiement selon les API disponibles

---

# 🏗️ Architecture cible

L'architecture pourra évoluer progressivement vers une séparation plus stricte des responsabilités :

```text
UI
 │
 ▼
Providers / State Management
 │
 ▼
Repositories
 │
 ▼
Services
 │
 ▼
Firebase
```

Objectif :

```text
Interface
   ≠
Logique métier
   ≠
Accès aux données
```

Structure cible :

```text
lib/
├── core/
├── models/
├── providers/
├── repositories/
├── services/
├── screens/
└── widgets/
```

Cette évolution sera réalisée progressivement afin de ne pas introduire une complexité inutile dans le prototype actuel.

---

# 🌍 Conçu pour le contexte nigérien

AtelierPro prend en compte plusieurs contraintes du terrain :

* 📱 Android prioritaire ;
* 📶 connectivité parfois limitée ;
* 💰 FCFA ;
* 📞 téléphone comme moyen de contact principal ;
* 📱 WhatsApp ;
* 💳 paiements électroniques en évolution ;
* 🏪 petits ateliers ;
* 👷 différents métiers artisanaux ;
* 🇳🇪 première cible au Niger.

L'objectif est de construire un outil **réellement utilisable dans un atelier**, et pas uniquement une démonstration technique.

---

# 🔌 Philosophie du projet

AtelierPro suit quelques principes :

### Simplicité

L'artisan doit pouvoir effectuer rapidement les opérations principales.

### Adaptabilité

Le système de fiches métier permet d'adapter les formulaires à différents ateliers.

### Progressivité

Les fonctionnalités complexes sont ajoutées progressivement au lieu de surcharger la première version.

### Sécurité

Les données d'un atelier doivent rester séparées de celles des autres utilisateurs.

### Terrain d'abord

Les décisions futures doivent être guidées par les retours des artisans et les usages réels.

---

# 🤝 Contribution

AtelierPro est un projet open source.

Les contributions sont les bienvenues.

## Installation

```bash
git clone https://github.com/mouslimyacouba/ATELIER-PRO-NEW-.git
cd ATELIER-PRO-NEW-
flutter pub get
```

Créer une branche :

```bash
git checkout -b feature/ma-fonctionnalite
```

Développer, tester et formater :

```bash
flutter analyze
flutter test
dart format .
```

Puis créer une Pull Request.

---

# 💡 Domaines de contribution

Les contributeurs peuvent aider sur :

* nouveaux métiers ;
* templates de fiches ;
* UX/UI ;
* accessibilité ;
* tests Flutter ;
* sécurité Firebase ;
* architecture ;
* performances ;
* mode hors connexion ;
* documentation ;
* traduction ;
* Mobile Money ;
* stock ;
* production ;
* fonctionnalités adaptées aux artisans africains.

---

# 📄 Licence

AtelierPro Mobile est distribué sous licence :

**MIT**

Voir :

```text
LICENSE
```

---

# 📌 Statut actuel

```text
Prototype fonctionnel
        ↓
Stabilisation V1.1
        ↓
Tests terrain
        ↓
Premiers artisans
        ↓
Retours utilisateurs
        ↓
Amélioration
        ↓
V2 — Assistant numérique d'atelier
```

Le projet n'est pas présenté comme un produit terminé.

La priorité actuelle est de **fiabiliser l'existant, tester AtelierPro avec des artisans et améliorer le produit à partir de leurs besoins réels**.

---

# 👨‍💻 Auteur

**Mouslim Yacouba**

Développeur autodidacte et porteur du projet AtelierPro.

AtelierPro est développé avec l'objectif de contribuer progressivement à la **digitalisation des petits ateliers et artisans au Niger**.

---

# ⭐ Soutenir AtelierPro

Vous pouvez soutenir le projet en :

* ⭐ donnant une Star au dépôt ;
* 🐛 signalant un bug ;
* 💡 proposant une fonctionnalité ;
* 🤝 contribuant au code ;
* 🧪 testant l'application ;
* 👷 partageant le projet avec un artisan ;
* 📣 faisant connaître le projet.

---

> **AtelierPro — Du cahier à l'atelier numérique. 🇳🇪**
