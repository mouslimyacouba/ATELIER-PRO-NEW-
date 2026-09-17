import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Centralise l'upload de photos vers Firebase Storage.
///
/// ⚠️ Deux pré-requis côté Firebase Console, sans quoi TOUT upload échoue :
///   1. Storage > "Commencer" doit avoir été cliqué au moins une fois — le
///      bucket ne se crée pas tout seul, contrairement à ce qu'on pourrait
///      penser (même situation que Firestore Database au tout début).
///   2. Storage > Rules doit contenir le contenu de firebase/storage.rules
///      (les règles par défaut bloquent tout : "allow read, write: if false").
/// Sans ces deux étapes, `putFile()` échoue silencieusement dans certains
/// cas, et l'erreur qui remonte ensuite ([firebase_storage/object-not-found]
/// sur le getDownloadURL() qui suit) est trompeuse — elle ne dit pas "bucket
/// manquant", juste "objet introuvable".
class StorageService {
  static final _storage = FirebaseStorage.instance;
  static final _auth = FirebaseAuth.instance;
  static final _picker = ImagePicker();
  static const _privateBuckets = {'photos', 'commandes', 'modeles_etapes'};
  static const _knownBuckets = {'logos', ..._privateBuckets};

  /// Ouvre le sélecteur d'image (galerie), compresse légèrement, et retourne
  /// le fichier choisi. Retourne null si l'utilisateur annule.
  static Future<File?> pickImage(
      {ImageSource source = ImageSource.gallery}) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  /// Upload un fichier vers `bucket/userId/key.ext` (ex: bucket "logos" ou
  /// "photos" — de simples dossiers de premier niveau dans Firebase Storage,
  /// pas de vrais "buckets" séparés comme chez Supabase) et retourne l'URL
  /// de téléchargement. `key` distingue les fichiers d'un même utilisateur
  /// (ex: l'id du client pour une photo client, ou "logo" pour l'atelier).
  static Future<String> upload({
    required String bucket,
    required String userId,
    required String key,
    required File file,
  }) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      throw Exception('Utilisateur non connecté.');
    }
    if (currentUserId != userId) {
      throw Exception('Atelier non autorisé pour cet envoi.');
    }
    if (!_knownBuckets.contains(bucket)) {
      throw ArgumentError.value(
          bucket, 'bucket', 'Dossier de stockage non autorisé.');
    }
    if (key.isEmpty || key.contains('/') || key.contains('\\')) {
      throw ArgumentError.value(key, 'key', 'Clé de fichier invalide.');
    }

    if (!await file.exists()) {
      throw Exception(
          'Le fichier image sélectionné est introuvable sur l\'appareil.');
    }

    // Extension nettoyée : certains chemins retournés par le sélecteur
    // d'image peuvent contenir des paramètres après l'extension — on ne
    // garde que des caractères alphanumériques pour éviter un chemin
    // Firebase Storage invalide.
    final rawExt = file.path.contains('.') ? file.path.split('.').last : 'jpg';
    final ext = rawExt.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final safeExt = ext.isEmpty ? 'jpg' : ext;

    final ref = _storage.ref('$bucket/$userId/$key.$safeExt');

    late final TaskSnapshot snapshot;
    try {
      snapshot = await ref.putFile(file);
    } on FirebaseException catch (e) {
      // Erreur la plus fréquente à ce stade : règles Storage non publiées
      // (unauthorized) ou bucket jamais initialisé — voir note en tête de
      // fichier. On enrichit le message pour orienter le diagnostic.
      if (e.code == 'unauthorized' || e.code == 'unknown') {
        throw Exception(
          'Envoi refusé (${e.code}). Vérifie que Storage est bien activé et que '
          'les règles de sécurité (firebase/storage.rules) sont publiées côté Firebase Console.',
        );
      }
      rethrow;
    }

    if (snapshot.state != TaskState.success) {
      throw Exception(
          'L\'envoi ne s\'est pas terminé correctement (état: ${snapshot.state}).');
    }

    return await ref.getDownloadURL();
  }
}
