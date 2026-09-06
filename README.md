# AtelierPro Mobile

Application mobile **open source** (Flutter) de gestion d'atelier pour artisans nigériens
(couture, menuiserie, mécanique, cordonnerie, maçonnerie, bijouterie, coiffure...) :
clients, commandes, fiches métier, paiements.

> ⚠️ Projet **indépendant** de NiyaJobs et de l'AtelierPro web (PWA, qui reste sur Supabase).
> Base de code séparée, variables d'environnement séparées (`.env` local ici).
> **Backend : Firebase** (Auth + Cloud Firestore + Storage), projet `atelier-pro-1a9e8`.
> Le paiement mobile money (iPayMoney) **n'est pas encore intégré** — les paiements se
> saisissent manuellement pour l'instant depuis chaque commande.

## Stack

- **Flutter** (Dart) — cross-platform, compile en APK Android natif, portable vers iOS plus tard
- **Firebase** — Auth (email/mot de passe), Cloud Firestore (données), Storage (photos/logos)
- **provider** — gestion d'état
- **go_router** — navigation déclarative

## Prérequis

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) installé (`flutter doctor` doit être vert)
2. [Android Studio](https://developer.android.com/studio) avec le plugin Flutter/Dart installé
3. Le projet Firebase **atelier-pro-1a9e8** existant

## Mise en route

```bash
# 1. Installer les dépendances
flutter pub get

# 2. Générer les dossiers de plateforme (android/, ios/) si pas déjà fait
flutter create . --platforms=android,ios --org com.zinderdigital

# 3. Configurer les variables d'environnement
cp .env.example .env
# puis éditer .env avec les vraies clés Firebase (voir section "Configuration Firebase" ci-dessous)

# 4. Lancer sur un émulateur ou un téléphone branché en USB (débogage activé)
flutter run
```

## Configuration Firebase (obligatoire avant le premier lancement)

### 1. Base Firestore
Si pas déjà fait : Firebase Console > Firestore Database > **Créer une base de données**
(mode production).

### 2. Règles de sécurité
- Firestore Database > **Règles** > coller le contenu de `firebase/firestore.rules` > Publier
- Storage > **Règles** > coller le contenu de `firebase/storage.rules` > Publier
  (créer Storage d'abord si pas encore fait : Storage > Commencer)

### 3. Index composites
Firestore a besoin d'index composites pour certaines requêtes (filtre + tri sur des champs
différents). Deux options :
- **Simple** : lancer l'app et utiliser chaque écran une fois (Clients, Commandes, Fiches) ;
  Firestore affichera une erreur avec un lien direct "Créer l'index" dans les logs — cliquer dessus
- **Via CLI** : `firebase deploy --only firestore:indexes` avec `firebase/firestore.indexes.json`

### 4. Vraies clés dans `.env`
⚠️ Le fichier `firebase_options.dart` fourni contient des **valeurs factices** (placeholders,
pas de vraies clés). Va chercher les vraies valeurs dans Firebase Console > ⚙️ Paramètres du
projet > tes applications enregistrées ("atelier pro" et "Atelier pro" `</>`), clique sur
l'icône de config de chacune pour voir le `firebaseConfig`, et remplis `.env` en conséquence
(voir `.env.example` pour la liste exacte des variables).

### 5. Fichiers de config natifs (Android/iOS)
En plus de `.env`, Android a besoin de `google-services.json` (Firebase Console > Paramètres
du projet > app Android > télécharger `google-services.json` > le placer dans `android/app/`).
Pour iOS : `GoogleService-Info.plist` dans `ios/Runner/` (si une app iOS est enregistrée côté
Firebase — sinon, ajouter une app iOS d'abord).

**Le plus simple pour tout ça en une fois** : lancer `flutterfire configure` (CLI FlutterFire)
depuis la racine du projet, qui télécharge les bons fichiers natifs ET régénère
`firebase_options.dart` avec de vraies valeurs — dans ce cas, garder le fichier généré par la
CLI plutôt que celui founi ici, ou fusionner manuellement les deux approches.

## Générer l'APK

```bash
flutter build apk --release
# L'APK se trouve dans : build/app/outputs/flutter-apk/app-release.apk
```

Pour l'ouvrir directement dans **Android Studio** : `File > Open`, sélectionner le dossier
`atelierpro_mobile`, laisser Android Studio synchroniser Gradle, puis `Build > Build Bundle(s) / APK(s) > Build APK(s)`.

## Fiches multi-secteurs

L'app n'est pas limitée à la couture. Le métier de l'atelier (`ateliers.specialite`) pilote
dynamiquement les champs proposés dans les fiches : mesures pour un couturier, fiche véhicule
pour un mécanicien, fiche chantier pour un maçon, etc.

- `lib/models/type_atelier.dart` — les métiers supportés
- `lib/models/champ_fiche.dart` / `fiche_template.dart` — modèle générique de champ/template
- `lib/core/fiche_templates.dart` — configuration des 8 templates (couture, menuiserie,
  mécanique, cordonnerie, maçonnerie, bijouterie, coiffure, autre)
- `lib/screens/mesures/mesures_screen.dart` — formulaire et liste entièrement dynamiques

**Ajouter un 9e métier** : ajouter une valeur à `TypeAtelier` (+ son `dbValue`) et une
entrée dans `ficheTemplates`. Aucun écran n'a besoin d'être modifié.

⚠️ Changer le métier d'un atelier ne modifie pas les fiches déjà créées (elles gardent
les données saisies sous l'ancien template) — seuls les nouveaux formulaires changent.

## Structure du projet

```
lib/
  core/            # thème, routeur, storage, appels WhatsApp
  models/          # Atelier, Client, Commande, Paiement, FicheMesure
  providers/       # état applicatif (auth, atelier, clients, commandes, fiches)
  screens/
    auth/
    onboarding/
    dashboard/
    clients/
    orders/          # commandes
    mesures/         # fiches métier
    settings/
  widgets/         # composants réutilisables
  firebase_options.dart
firebase/
  firestore.rules       # règles de sécurité Firestore (à coller dans la Console)
  storage.rules          # règles de sécurité Storage (à coller dans la Console)
  firestore.indexes.json # index composites nécessaires
```

## Schéma de données (Firestore)

```
ateliers/{userId}   : nomAtelier, telephone, ville, specialite, logoUrl, createdAt, updatedAt
                       (doc ID = uid de l'utilisateur, relation 1-pour-1 directe)
clients/{autoId}    : userId, nomComplet, telephone, adresse, notes, photoUrl, createdAt, updatedAt
commandes/{autoId}  : userId, clientId, clientNom(dénormalisé), ficheId, description,
                       statut, dateCommande, dateEcheance, prixTotal, acompte, createdAt, updatedAt
fiches/{autoId}     : userId, clientId, titre, mesures(map), notes, createdAt, updatedAt
paiements/{autoId}  : userId, commandeId, montant, mode, datePaiement, createdAt
```

Pas de sous-collections : tout est en collections de premier niveau avec un champ `userId`
pour le filtrage — plus simple à requêter que des sous-collections imbriquées, au prix d'un
`where('userId', isEqualTo: ...)` sur chaque requête (déjà en place dans tous les providers).

**Différences importantes par rapport à la version Postgres/Supabase précédente :**
- Pas de suppression en cascade automatique : chaque provider supprime manuellement les
  documents liés avant de supprimer le document parent (voir `deleteClient`, `deleteOrder`,
  `deleteAtelier`)
- Pas de jointures : le nom du client est dupliqué (`clientNom`) sur chaque commande au moment
  de sa création, pour éviter une requête supplémentaire à chaque affichage de liste
- `solde` n'est plus une colonne calculée côté base — c'est un getter Dart (`order.remaining`),
  inchangé depuis la version Supabase

## Roadmap paiement mobile money

L'intégration iPayMoney (Airtel Money, Wave, Moov Flooz, Zamani Cash, Nita, Amanata) reste à
faire, indépendamment du backend (Firebase ou Supabase).

## Licence

MIT — voir [LICENSE](./LICENSE).
