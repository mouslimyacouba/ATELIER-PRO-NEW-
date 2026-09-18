# 🛠️ AtelierPro Mobile

> **Application mobile open source de gestion d'atelier pour les artisans nigériens.**

AtelierPro est une application mobile développée avec **Flutter** pour aider les artisans à gérer simplement leur activité : clients, commandes, fiches métier, paiements et suivi des travaux.

L'application est pensée pour différents métiers : **couture, menuiserie, mécanique, cordonnerie, maçonnerie, bijouterie, coiffure**, et d'autres métiers pourront être ajoutés progressivement.

---

## 🎯 Pourquoi AtelierPro ?

De nombreux petits ateliers utilisent encore principalement :

* 📒 des cahiers pour enregistrer les clients ;
* 📝 des notes papier pour les commandes ;
* 🧠 la mémoire pour suivre les paiements ;
* 📱 WhatsApp pour communiquer avec les clients ;
* 🧾 peu ou pas d'historique numérique.

AtelierPro cherche à proposer une solution **simple, accessible et adaptée au fonctionnement réel des ateliers au Niger**.

L'objectif n'est pas de créer un logiciel de gestion complexe.

L'objectif est de permettre à un artisan de faire rapidement :

> **Client → Commande → Fiche métier → Paiement → Fabrication → Livraison**

---

# 🚀 Fonctionnalités actuelles — V1

## 👤 Gestion des clients

* Ajouter un client
* Modifier un client
* Supprimer un client
* Numéro de téléphone
* Adresse
* Notes
* Photo du client
* Historique associé aux commandes

---

## 📦 Gestion des commandes

Une commande peut contenir :

* Client
* Description
* Fiche métier associée
* Prix total
* Acompte
* Solde restant
* Date de commande
* Date d'échéance
* Statut de la commande

### Statuts actuels

* Nouveau
* Confirmé
* En fabrication
* Prêt
* Livré
* Annulé

Le solde est calculé côté Dart à partir du montant total et des paiements enregistrés.

---

## 📋 Fiches métier dynamiques

AtelierPro n'est pas limité à un seul secteur.

Le métier de l'atelier détermine automatiquement les champs proposés dans les fiches.

### 👕 Couture

Exemples :

* Tour de poitrine
* Tour de taille
* Tour de hanche
* Longueur
* Épaule
* Manche
* Notes

### 🚗 Mécanique

Exemples :

* Marque
* Modèle
* Immatriculation
* Kilométrage
* Problème
* Diagnostic

### 🪑 Menuiserie

Exemples :

* Type de meuble
* Dimensions
* Matière
* Couleur
* Quantité
* Notes

Le même principe est utilisé pour les autres métiers.

---

## 💰 Gestion des paiements

Les paiements peuvent actuellement être enregistrés manuellement depuis une commande.

Informations enregistrées :

* Montant
* Mode de paiement
* Date
* Commande associée

### ⚠️ Mobile Money

L'intégration directe avec les services Mobile Money n'est **pas encore disponible**.

L'intégration future pourra notamment concerner :

* Airtel Money
* Moov Money
* Wave
* Zamani Cash
* Nita
* Amanata
* autres services selon leur disponibilité et leurs API

---

## 📱 WhatsApp

AtelierPro peut faciliter la communication avec les clients via WhatsApp.

L'objectif est notamment de permettre à l'artisan de transmettre rapidement :

* l'état d'une commande ;
* le montant restant ;
* la disponibilité d'une commande ;
* des informations de livraison.

---

# 🧩 Architecture technique

AtelierPro Mobile utilise une architecture Flutter connectée à Firebase.

```text
Flutter
   │
   ├── Screens
   │
   ├── Widgets
   │
   ├── Providers
   │
   ├── Models
   │
   └── Core
          │
          ▼
       Firebase
          │
     ┌────┼────────────┐
     ▼    ▼            ▼
   Auth Firestore    Storage
```

## Stack

| Technologie             | Utilisation          |
| ----------------------- | -------------------- |
| Flutter                 | Application mobile   |
| Dart                    | Langage              |
| Firebase Authentication | Authentification     |
| Cloud Firestore         | Base de données      |
| Firebase Storage        | Photos et fichiers   |
| Provider                | Gestion d'état       |
| GoRouter                | Navigation           |
| WhatsApp                | Communication client |

---

# 🗂️ Structure du projet

```text
lib/
├── core/
│   ├── theme/
│   ├── router/
│   ├── storage/
│   └── services/
│
├── models/
│   ├── atelier.dart
│   ├── client.dart
│   ├── commande.dart
│   ├── paiement.dart
│   ├── fiche_mesure.dart
│   ├── type_atelier.dart
│   ├── champ_fiche.dart
│   └── fiche_template.dart
│
├── providers/
│   ├── auth_provider.dart
│   ├── atelier_provider.dart
│   ├── clients_provider.dart
│   ├── commandes_provider.dart
│   └── fiches_provider.dart
│
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── dashboard/
│   ├── clients/
│   ├── orders/
│   ├── mesures/
│   └── settings/
│
├── widgets/
│
└── firebase_options.dart

firebase/
├── firestore.rules
├── storage.rules
└── firestore.indexes.json
```

---

# 🔥 Architecture Firestore

Les données sont organisées dans des collections de premier niveau.

```text
ateliers/{userId}
clients/{autoId}
commandes/{autoId}
fiches/{autoId}
paiements/{autoId}
```

Chaque document utilisateur contient un champ :

```text
userId
```

permettant de filtrer les données appartenant à l'utilisateur connecté.

---

## Atelier

```text
ateliers/{userId}

{
  nomAtelier,
  telephone,
  ville,
  specialite,
  logoUrl,
  createdAt,
  updatedAt
}
```

L'identifiant du document correspond directement au `uid` Firebase de l'utilisateur.

---

## Client

```text
clients/{autoId}

{
  userId,
  nomComplet,
  telephone,
  adresse,
  notes,
  photoUrl,
  createdAt,
  updatedAt
}
```

---

## Commande

```text
commandes/{autoId}

{
  userId,
  clientId,
  clientNom,
  ficheId,
  description,
  statut,
  dateCommande,
  dateEcheance,
  prixTotal,
  acompte,
  createdAt,
  updatedAt
}
```

Le champ `clientNom` est volontairement dénormalisé afin d'éviter une requête supplémentaire lors de l'affichage des commandes.

---

## Fiche métier

```text
fiches/{autoId}

{
  userId,
  clientId,
  titre,
  mesures,
  notes,
  createdAt,
  updatedAt
}
```

Le champ `mesures` est une `Map` permettant de stocker des champs différents selon le métier.

---

## Paiement

```text
paiements/{autoId}

{
  userId,
  commandeId,
  montant,
  mode,
  datePaiement,
  createdAt
}
```

---

# 🧠 Système de fiches multi-métiers

Le système de fiches est conçu pour être extensible.

Les principaux fichiers sont :

```text
lib/models/type_atelier.dart
lib/models/champ_fiche.dart
lib/models/fiche_template.dart
lib/core/fiche_templates.dart
```

Pour ajouter un nouveau métier :

1. Ajouter le type dans `TypeAtelier`
2. Ajouter sa valeur `dbValue`
3. Ajouter son template dans `ficheTemplates`

Aucun écran principal ne doit être modifié.

### Exemple

```dart
TypeAtelier.maconnerie
```

peut être associé à :

```text
fiche chantier
├── Type de chantier
├── Dimensions
├── Matériaux
├── Quantité
├── Budget
└── Notes
```

---

# 🔐 Sécurité

La sécurité repose sur :

* Firebase Authentication
* règles Firestore
* règles Firebase Storage
* filtrage par `userId`

Chaque utilisateur doit uniquement pouvoir accéder à ses propres données.

Les règles de sécurité sont disponibles ici :

```text
firebase/firestore.rules
firebase/storage.rules
```

⚠️ Avant de publier une version destinée à de vrais utilisateurs, les règles Firebase doivent être auditées et testées.

---

# 🛠️ Installation

## Prérequis

Installer :

* Flutter SDK
* Android Studio
* plugin Flutter
* plugin Dart
* Git
* un émulateur Android ou un téléphone Android

Vérifier l'installation :

```bash
flutter doctor
```

Tous les éléments importants doivent être correctement configurés.

---

# 📥 Cloner le projet

```bash
git clone https://github.com/mouslimyacouba/atelierpro_mobile.git
```

Puis :

```bash
cd atelierpro_mobile
```

---

# 📦 Installer les dépendances

```bash
flutter pub get
```

---

# 📱 Générer les plateformes

Si les dossiers Android/iOS ne sont pas présents :

```bash
flutter create . --platforms=android,ios --org com.zinderdigital
```

---

# 🔥 Configuration Firebase

AtelierPro utilise le projet Firebase :

```text
atelier-pro-1a9e8
```

Avant le premier lancement, Firebase doit être correctement configuré.

## Option recommandée

Installer FlutterFire CLI puis lancer :

```bash
flutterfire configure
```

Cette commande permet de configurer les applications Firebase et de générer les fichiers nécessaires.

---

## Android

Le fichier :

```text
android/app/google-services.json
```

doit correspondre à l'application Android enregistrée dans Firebase.

---

## iOS

Pour une future version iOS :

```text
ios/Runner/GoogleService-Info.plist
```

devra être correctement configuré.

---

# 🔑 Variables d'environnement

Créer le fichier `.env` à partir du modèle :

```bash
cp .env.example .env
```

Puis renseigner les valeurs nécessaires.

⚠️ **Ne jamais publier les vraies clés ou secrets dans GitHub.**

Le fichier `.env` doit rester dans `.gitignore`.

### Configuration locale

Les variables Firebase doivent être renseignées dans un fichier `.env` à la racine du projet avec les noms présents dans `.env.example`.

```bash
flutter pub get
flutter analyze
flutter test
```

Si une variable obligatoire manque, l'application affiche l'écran
**Configuration Firebase requise** et ne se connecte pas avec des valeurs
factices. Les tests unitaires peuvent tout de même être exécutés sans
identifiants Firebase. Lors de la préparation de cette configuration,
`flutter test` passe avec 15 tests et `flutter analyze` s'exécute mais retourne
les 65 diagnostics de lint déjà présents dans le code ; ces diagnostics sont
indépendants de Firebase. Les valeurs Firebase réelles ne doivent jamais être
ajoutées au dépôt.

---

# 🔐 Google Sign-In

Pour utiliser :

> **Continuer avec Google**

il faut activer Google comme fournisseur dans :

```text
Firebase Console
→ Authentication
→ Sign-in method
→ Google
```

Pour Android, les empreintes SHA-1 et SHA-256 doivent également être configurées.

Depuis Android :

```bash
cd android
./gradlew signingReport
```

Ajouter les empreintes correspondantes dans Firebase.

Après modification, télécharger à nouveau :

```text
google-services.json
```

---

# 🗄️ Firestore

Créer la base Firestore depuis Firebase Console.

Les règles sont disponibles dans :

```text
firebase/firestore.rules
```

Les index sont disponibles dans :

```text
firebase/firestore.indexes.json
```

Ils peuvent être déployés avec Firebase CLI :

```bash
firebase deploy --only firestore:indexes
```

---

# ▶️ Lancer l'application

Avec un téléphone Android connecté :

```bash
flutter devices
```

Puis :

```bash
flutter run
```

---

# 📦 Générer l'APK

Pour créer une version release :

```bash
flutter build apk --release
```

L'APK sera disponible dans :

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

# 🗺️ Roadmap

## V1 — Base fonctionnelle

* [x] Authentification
* [x] Gestion de l'atelier
* [x] Gestion des clients
* [x] Gestion des commandes
* [x] Fiches métier dynamiques
* [x] Paiements manuels
* [x] Calcul du solde
* [x] Firebase
* [x] Architecture multi-métiers
* [x] Support WhatsApp
* [x] Licence MIT

---

# 🚧 V1.1 — Stabilisation

Objectif : rendre l'application suffisamment fiable pour les premiers artisans.

* [ ] Audit des règles Firestore
* [ ] Amélioration des messages d'erreur
* [ ] États loading / empty / error
* [ ] Validation complète des formulaires
* [ ] Recherche clients
* [ ] Recherche commandes
* [ ] Références de commande
* [ ] Reçus de paiement
* [ ] Amélioration WhatsApp
* [ ] Notifications et rappels
* [ ] Amélioration UX Android
* [ ] Tests sur appareils Android réels
* [ ] Tests hors connexion / reconnexion
* [ ] Tests de sécurité Firebase

---

# 🚀 V2 — Gestion de production

La V2 doit faire évoluer AtelierPro d'un simple outil de gestion vers un véritable **assistant numérique d'atelier**.

## Production

* [ ] Étapes de fabrication
* [ ] Progression des commandes
* [ ] Workflows par métier
* [ ] Historique des étapes
* [ ] Date de livraison
* [ ] Notifications de retard

## Gestion financière

* [ ] Coût des matériaux
* [ ] Coût estimé de production
* [ ] Bénéfice estimé
* [ ] Chiffre d'affaires
* [ ] Paiements en attente
* [ ] Historique financier

## Stock

* [ ] Produits
* [ ] Quantités
* [ ] Entrées
* [ ] Sorties
* [ ] Stock faible
* [ ] Consommation par commande

## Fournisseurs

* [ ] Liste des fournisseurs
* [ ] Contacts
* [ ] Produits
* [ ] Prix
* [ ] Historique des achats

## Paiements

* [ ] Amélioration des modes de paiement
* [ ] Références de transaction
* [ ] Intégration Mobile Money
* [ ] Intégration iPayMoney lorsque les conditions techniques seront disponibles

---

# 🏗️ Architecture cible V2

L'architecture évoluera progressivement vers :

```text
UI
 │
 ▼
Providers
 │
 ▼
Repositories
 │
 ▼
Firebase
```

Les repositories permettront de séparer progressivement :

* l'interface utilisateur ;
* la gestion d'état ;
* la logique métier ;
* l'accès aux données.

Structure cible :

```text
lib/
├── core/
├── models/
├── providers/
├── repositories/
├── screens/
├── widgets/
└── services/
```

---

# 🌍 Pour les artisans nigériens

AtelierPro est conçu avec plusieurs contraintes du contexte local :

* 📱 priorité à Android ;
* 📶 prise en compte des connexions Internet limitées ;
* 💰 utilisation du FCFA ;
* 📞 importance du téléphone et de WhatsApp ;
* 💳 prise en compte progressive du Mobile Money ;
* 🧾 simplicité des reçus et commandes ;
* 🏪 adaptation à plusieurs types d'ateliers ;
* 🇳🇪 développement avec une première cible au Niger.

L'objectif est de construire une application utile **sur le terrain**, pas seulement une démonstration technique.

---

# 🤝 Contribution

AtelierPro est un projet open source.

Les contributions sont les bienvenues.

Pour contribuer :

```bash
git clone https://github.com/mouslimyacouba/atelierpro_mobile.git
cd atelierpro_mobile
flutter pub get
```

Créer ensuite une branche :

```bash
git checkout -b feature/ma-fonctionnalite
```

Effectuer les modifications, tester l'application puis créer une Pull Request.

---

# 💡 Idées de contribution

Les contributeurs peuvent notamment aider sur :

* nouveaux métiers ;
* templates de fiches ;
* amélioration UX ;
* tests Flutter ;
* accessibilité ;
* optimisation des performances ;
* sécurité Firebase ;
* traduction ;
* documentation ;
* intégration Mobile Money ;
* fonctionnalités adaptées aux artisans africains.

---

# 📄 Licence

Ce projet est distribué sous licence **MIT**.

Voir le fichier :

```text
LICENSE
```

---

# 📌 Statut du projet

**AtelierPro Mobile est actuellement en développement.**

La priorité actuelle est de stabiliser la V1, la tester avec de vrais artisans et recueillir leurs retours avant de développer les fonctionnalités majeures de la V2.

```text
V1
  ↓
Stabilisation
  ↓
Premiers artisans
  ↓
Retours terrain
  ↓
V1.1
  ↓
Production
  ↓
V2
```

---

# 👨‍💻 Auteur

**Mouslim Yacouba**

Développeur autodidacte et porteur du projet AtelierPro.

Projet développé avec l'objectif de contribuer à la **digitalisation des petits ateliers et artisans au Niger**.

---

## ⭐ Soutenir le projet

Si AtelierPro est utile ou intéressant :

* ⭐ Star le repository
* 🐛 Signaler un problème
* 💡 Proposer une fonctionnalité
* 🤝 Contribuer au code
* 📣 Partager le projet avec des artisans

**AtelierPro — Du cahier à l'atelier numérique. 🇳🇪**
