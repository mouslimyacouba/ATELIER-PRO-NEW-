# 📱 Configuration Android - AtelierPro

## ✅ Fichiers de Configuration Présents

- ✅ `android/app/google-services.json` - Configuration Firebase Android
- ✅ `android/app/build.gradle.kts` - Configuration build Android
- ✅ `.env` - Variables d'environnement
- ✅ `lib/firebase_options.dart` - Options Firebase

## 🔧 Configuration Requise pour Build Android

### 1️⃣ Installer Java JDK

**Windows** :
```bash
# Via Chocolatey (recommandé)
choco install openjdk

# Ou télécharger depuis :
# https://www.oracle.com/java/technologies/downloads/
```

**Vérifier l'installation** :
```bash
java -version
javac -version
```

**Définir JAVA_HOME** :
```powershell
# Ajouter à Environment Variables
setx JAVA_HOME "C:\Program Files\Java\jdk-17"
```

### 2️⃣ Configuration Android SDK

**Vérifier ANDROID_HOME** :
```bash
echo %ANDROID_HOME%
# Devrait afficher : C:\Users\[user]\AppData\Local\Android\sdk
```

**Si absent** :
```powershell
setx ANDROID_HOME "C:\Users\%USERNAME%\AppData\Local\Android\sdk"
```

### 3️⃣ Vérifier la Clé SHA-1 de Debug

```bash
# Depuis le dossier android/
cd android
./gradlew.bat signingReport

# Regarder la ligne SHA1 pour androiddebugkey
```

### 4️⃣ Ajouter la SHA-1 à Firebase Console

1. Aller sur https://console.firebase.google.com
2. Sélectionner projet "atelier-pro-1a9e8"
3. Paramètres → Vos apps → Android app
4. Dans "Certificats SHA-1" → **Ajouter** votre SHA-1 trouvé à l'étape 3

### 5️⃣ Vérifier google-services.json

```bash
# Le fichier doit être à :
android/app/google-services.json

# Vérifier qu'il contient :
# - project_id: "atelier-pro-1a9e8"
# - package_name: "com.zinderdigital.atelierpro_mobile"
# - API Key
```

### 6️⃣ Build Android

```bash
# Test build debug
flutter build apk --debug

# Build release (si vous avez configuré la clé release)
flutter build apk --release
```

## 🆘 Troubleshooting Android

### ❌ Error: JAVA_HOME is not set

**Solution** :
1. Installer Java JDK
2. Définir JAVA_HOME dans Environment Variables
3. Redémarrer le terminal

### ❌ Erreur : "Gradle build failed"

```bash
# Nettoyer et reconstruire
flutter clean
flutter pub get
flutter build apk --debug -v
```

### ❌ Erreur : "Failed to resolve: com.google.gms:google-services"

**Solution** : Vérifier que `google-services.json` existe et est valide

### ❌ Erreur Firebase : "MissingPluginException"

```bash
# Reconstruire l'app
flutter clean
flutter pub get
flutter run  # ou flutter build apk
```

## 📋 Checklist Android

- [x] `.env` présent avec clés Firebase
- [x] `google-services.json` présent
- [x] `firebase_options.dart` créé
- [ ] Java JDK installé
- [ ] JAVA_HOME défini
- [ ] ANDROID_HOME défini
- [ ] SHA-1 debug trouvé avec `gradlew signingReport`
- [ ] SHA-1 ajouté dans Firebase Console
- [ ] Build debug test réussi
- [ ] Test sur émulateur/appareil

## 🚀 Build & Run Android

### Test Debug sur Émulateur

```bash
# Lancer émulateur
emulator -avd Pixel_5_API_30

# Ou lancer via Android Studio : AVD Manager

# Builder et run
flutter run

# Ou
flutter run -d emulator-5554
```

### Test Debug sur Appareil Physique

```bash
# Activer le débogage USB sur l'appareil
# Paramètres → À propos → Appuyer 7x sur "Numéro de build"
# → Paramètres → Options pour développeurs → USB Debugging ON

# Connecter l'appareil via USB

# Lister les appareils
flutter devices

# Run
flutter run -d [device-id]
```

### Build Release APK

```bash
# Compiler en release
flutter build apk --release

# APK générée à :
# build/app/outputs/apk/release/app-release.apk (66 MB)

# Installer sur appareil
adb install -r build/app/outputs/apk/release/app-release.apk
```

## 📱 Configuration Google Sign-In Android

Le fichier `google-services.json` contient déjà :

```json
{
  "oauth_client": [
    {
      "client_id": "569744918009-ogjta19p0d90pvtnu6qtst34vr4sftk6.apps.googleusercontent.com",
      "android_info": {
        "package_name": "com.zinderdigital.atelierpro_mobile",
        "certificate_hash": "d0d0b2d528059c09cb31d5693a479a962768d8ec"  ← SHA-1 à vérifier
      }
    }
  ]
}
```

⚠️ **Important** : Le `certificate_hash` doit correspondre à votre SHA-1 debug.

## 🔐 Clés de Signature

### Debug (pour développement)

- **Alias** : androiddebugkey
- **Keystore** : `~/.android/debug.keystore`
- **Mot de passe** : android
- **Validité** : Illimitée

### Release (pour production)

- **Fichier** : `android/upload-keystore.jks`
- **Alias** : upload
- **Passwords** : Voir `android/key.properties`

## 📊 Informations Build

| Item | Value |
|------|-------|
| **Package Name** | com.zinderdigital.atelierpro_mobile |
| **Version** | 1.0.0 |
| **Min SDK** | 21 (Android 5.0) |
| **Target SDK** | 34 (Android 14) |
| **Build Type** | Debug / Release |
| **Project ID** | atelier-pro-1a9e8 |

## 🎯 Next Steps

1. **Installer Java JDK** ← PRIORITÉ
2. **Définir JAVA_HOME**
3. **Exécuter `gradlew signingReport`**
4. **Ajouter SHA-1 à Firebase**
5. **Test build debug**
6. **Déployer sur appareil**

## 📞 Support

Si vous rencontrez des problèmes :

```bash
# Voir les logs détaillés
flutter run -v

# Ou
flutter build apk --debug -v
```

---

**Note** : La clé release (`upload-keystore.jks`) est déjà configurée pour les builds production (voir `android/key.properties`).

