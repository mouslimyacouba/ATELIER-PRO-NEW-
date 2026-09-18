# Guide Création Indices Firestore Composites — AtelierPro

## 📋 Sommaire

1. [Index Requis](#index-requis)
2. [Instructions Firebase Console](#instructions-firebase-console)
3. [Vérification Index Actifs](#vérification-index-actifs)
4. [Dépannage](#dépannage)

---

## 📊 Index Requis

Après l'optimisation du 18 Sept 2026, **3 indices composites sont nécessaires** pour le tri serveur :

### Index 1: `commandes`
```
Collection:  commandes
Champs:      userId (Ascending)
             createdAt (Descending)
Status:      À créer
```
**Utilisé par :** `OrdersProvider.load(userId)` → triées par date récente
**Impact :** ~3000 requêtes/jour réduites en temps réponse

### Index 2: `paiements`
```
Collection:  paiements
Champs:      userId (Ascending)
             datePaiement (Descending)
Status:      À créer
```
**Utilisé par :** `OrdersProvider.load(userId)` → paiements triés par date récente
**Impact :** ~1500 requêtes/jour réduites en temps réponse

### Index 3: `clients`
```
Collection:  clients
Champs:      userId (Ascending)
             createdAt (Descending)
Status:      À créer
```
**Utilisé par :** `ClientsProvider.load(userId)` → clients triés par date récente
**Impact:** ~2000 requêtes/jour réduites en temps réponse

### Index 4 (Déjà existe) : `modeles`
```
Collection:  modeles
Champs:      userId (Ascending)
             createdAt (Descending)
Status:      ✅ Créé (commit 7c66f69)
```

---

## 🚀 Instructions Firebase Console

### Accès

1. **Ouvrir Firebase Console**
   ```
   Naviguer vers : https://console.firebase.google.com
   Sélectionner projet : atelier-pro-1a9e8
   ```

2. **Aller à Firestore Database**
   ```
   Firebase Console
   → [Sidebar] Firestore Database
   → [Tab] Indexes (à côté de "Data")
   ```

3. **Fenêtre Indexes**
   ```
   ┌─────────────────────────────────────────┐
   │ Cloud Firestore                         │
   ├─────────────────────────────────────────┤
   │ [Databases] [Backups] [Indexes]         │
   │                                         │
   │ Composite Indexes                       │
   │ ┌─────────────────────────────────────┐ │
   │ │ modeles                             │ │
   │ │ userId ↑ createdAt ↓               │ │
   │ │ Status: Enabled (✅)                │ │
   │ └─────────────────────────────────────┘ │
   └─────────────────────────────────────────┘
   ```

---

### Créer Index `commandes`

#### Étape 1 : Cliquer "Create Index"

Dans la fenêtre Indexes, cliquer sur le bouton `[+ Create Index]` en haut à droite.

#### Étape 2 : Remplir le formulaire

**Form : Create Composite Index**

```
Collection ID: [commandes_______________]
Query scope:   (Automatic — laisser vide)

Champs:
├─ Field 1:
│  ├─ Field Name:  [userId________________]
│  ├─ Direction:   ↑ Ascending (sélectionné)
│  └─ [X] Remove
│
└─ Field 2:
   ├─ Field Name:  [createdAt__________]
   ├─ Direction:   ↓ Descending (sélectionné)
   └─ [X] Remove

[+ Add field]
```

**Validation:**
- Collection ID : `commandes` ✓
- Field 1 : `userId` (↑) ✓
- Field 2 : `createdAt` (↓) ✓
- Aucun 3e champ

#### Étape 3 : Créer

Cliquer `[Create Index]` → Attendre confirmation

**Écran de confirmation:**
```
Creating index on commandes...
(userId ↑, createdAt ↓)

Estimated time: 2-5 minutes
```

---

### Créer Index `paiements`

#### Étape 1 : Cliquer "Create Index" (nouveau)

#### Étape 2 : Remplir le formulaire

**Form : Create Composite Index**

```
Collection ID: [paiements_____________]

Champs:
├─ Field 1:
│  ├─ Field Name:  [userId________________]
│  ├─ Direction:   ↑ Ascending
│  └─ [X] Remove
│
└─ Field 2:
   ├─ Field Name:  [datePaiement_______]
   ├─ Direction:   ↓ Descending
   └─ [X] Remove

[+ Add field]
```

**Validation:**
- Collection ID : `paiements` ✓
- Field 1 : `userId` (↑) ✓
- Field 2 : `datePaiement` (↓) ✓

#### Étape 3 : Créer

Cliquer `[Create Index]`

---

### Créer Index `clients`

#### Étape 1 : Cliquer "Create Index" (nouveau)

#### Étape 2 : Remplir le formulaire

**Form : Create Composite Index**

```
Collection ID: [clients_______________]

Champs:
├─ Field 1:
│  ├─ Field Name:  [userId________________]
│  ├─ Direction:   ↑ Ascending
│  └─ [X] Remove
│
└─ Field 2:
   ├─ Field Name:  [createdAt__________]
   ├─ Direction:   ↓ Descending
   └─ [X] Remove

[+ Add field]
```

**Validation:**
- Collection ID : `clients` ✓
- Field 1 : `userId` (↑) ✓
- Field 2 : `createdAt` (↓) ✓

#### Étape 3 : Créer

Cliquer `[Create Index]`

---

## ✅ Vérification Index Actifs

### Après création (attendre 5-10 min)

**Onglet Indexes → Composite Indexes :**

```
┌─────────────────────────────────────────────────┐
│ Composite Indexes                               │
├─────────────────────────────────────────────────┤
│                                                 │
│ ✅ modeles                                      │
│    userId ↑ createdAt ↓                         │
│    Status: Enabled                              │
│                                                 │
│ ✅ commandes                                    │
│    userId ↑ createdAt ↓                         │
│    Status: Enabled                              │
│                                                 │
│ ✅ paiements                                    │
│    userId ↑ datePaiement ↓                      │
│    Status: Enabled                              │
│                                                 │
│ ✅ clients                                      │
│    userId ↑ createdAt ↓                         │
│    Status: Enabled                              │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Status Attendus

| Index | Status | Temps |
|-------|--------|-------|
| `modeles` | ✅ Enabled | Instant (existant) |
| `commandes` | ⏳ Building | 2-5 min |
| `paiements` | ⏳ Building | 2-5 min |
| `clients` | ⏳ Building | 2-5 min |

**Une fois tous les 4 statuts = ✅ Enabled** → Indices prêts pour production

---

## 🔍 Vérification Fonctionnelle

### Test 1 : Vérifier que `DashboardScreen` charge sans erreur

**Après activation indices :**

1. Relancer l'app (Flutter Web ou Android)
2. Naviguer vers Dashboard
3. Observer console logs : **aucun message d'erreur** `failed-precondition`

**Logs attendus :**
```
[OrdersProvider] Stream émis : 127 commandes chargées
[ClientsProvider] Stream émis : 42 clients chargés
[FichesMesuresProvider] Stream émis : 89 fiches chargées
```

### Test 2 : Vérifier tri serveur

**Dans Firebase Console → Firestore Database → Data :**

1. Ouvrir collection `commandes`
2. Sélectionner filtrer par `userId = <votre_user_id>`
3. **Vérifier que les documents arrivent déjà triés par `createdAt` DESC**

**Avant index :** Tri côté client (pas trié)  
**Après index :** Trié immédiatement par Firestore ✓

---

## 🐛 Dépannage

### Erreur 1: "failed-precondition: The query requires an index"

**Cause :** Index composite manquant

**Solution :**
1. Vérifier nom collection exact (casse-sensible)
2. Vérifier noms champs exacts dans la query vs index
3. Vérifier directions (Ascending/Descending) correctes
4. Attendre 5-10 min après création (index en cours de build)
5. Rafraîchir navigateur + relancer app

**Commande vérification (Firebase CLI):**
```bash
firebase firestore:indexes --project=atelier-pro-1a9e8
```

### Erreur 2: "Cannot create index on collection (permission denied)"

**Cause :** Authentification manquante ou insuffisante sur Firebase Console

**Solution :**
1. Vérifier connecté avec compte Google (owner du projet)
2. Vérifier rôle IAM : `Editor` minimum requis
3. Se reconnecter : Firebase Console → Profil → Sign Out → Sign In

### Erreur 3: Index toujours "Building" après 30 min

**Cause :** Rare — grande quantité de données, ou problème serveur

**Solution :**
1. Attendre 1h
2. Si toujours "Building" : supprimer et recréer
3. Contacter support Firebase si bloqué

**Supprimer index (⚠️ à faire que si bloqué) :**
```
Firebase Console → Firestore → Indexes → [Index Name] → [⋮ Menu] → Delete
```

---

## 📝 Checklist Déploiement

Avant de considérer le déploiement optimisation complète :

- [ ] Index `modeles` : ✅ Enabled
- [ ] Index `commandes` : ✅ Enabled  
- [ ] Index `paiements` : ✅ Enabled
- [ ] Index `clients` : ✅ Enabled
- [ ] Dashboard charge sans erreur `failed-precondition`
- [ ] Performance Dashboard mesurée (moins de CPU, tri plus rapide)
- [ ] Code changements (orderBy, caches) compilent sans erreur
- [ ] Commit push vers GitHub avec message : "perf: indices Firestore activés"

---

## 🔗 Ressources

- [Firebase Firestore Indexes](https://firebase.google.com/docs/firestore/query-data/index-overview)
- [Composite Indexes Firestore](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase CLI Indexes](https://firebase.google.com/docs/cli#manage_indexes)
- [Query Performance Best Practices](https://firebase.google.com/docs/firestore/best-practices)

---

## 📞 Support

**Si indices ne se créent pas :**
1. Vérifier quota Firebase (Cloud Firestore indexes quota)
2. Vérifier plan billing : indices composites = FREE tier ✓
3. Contact : Firebase Support (console.firebase.google.com/support)

**Généré :** 18 Sept 2026  
**Project :** atelier-pro-1a9e8  
**Status :** ✅ Instructions complètes, en attente création manuelle
