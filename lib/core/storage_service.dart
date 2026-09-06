import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Centralise l'upload de photos vers Firebase Storage.
class StorageService {
  static final _storage = FirebaseStorage.instance;
  static final _picker = ImagePicker();

  /// Ouvre le sélecteur d'image (galerie) et retourne l'image choisie sous forme de [XFile].
  static Future<XFile?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      return picked;
    } catch (e) {
      debugPrint('Erreur pickImage: $e');
      return null;
    }
  }

  /// Upload une image vers `bucket/userId/key.ext`.
  /// Utilise putData pour une compatibilité maximale (Web/Mobile).
  static Future<String> upload({
    required String bucket,
    required String userId,
    required String key,
    required XFile file,
  }) async {
    try {
      final name = file.name;
      final ext = name.contains('.') ? name.split('.').last : 'jpg';
      final ref = _storage.ref().child(bucket).child(userId).child('$key.$ext');

      final Uint8List bytes = await file.readAsBytes();

      // Utilisation de putData qui est supporté sur toutes les plateformes (Web inclu)
      // On spécifie le contentType pour éviter les problèmes d'affichage/téléchargement
      final uploadTask = await ref.putData(
        bytes,
        SettableMetadata(contentType: 'image/${ext == "jpg" ? "jpeg" : ext}'),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Erreur StorageService.upload: $e');
      rethrow;
    }
  }
}
