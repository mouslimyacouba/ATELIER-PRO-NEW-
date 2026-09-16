import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Erreur levée lorsqu'une configuration Firebase est incomplète.
class FirebaseConfigurationException implements Exception {
  const FirebaseConfigurationException(this.missingVariables);

  final List<String> missingVariables;

  String get message =>
      'Configuration Firebase incomplète. Renseigne ces variables '
      'd’environnement : ${missingVariables.join(', ')}. '
      'Consulte .env.example pour les obtenir depuis Firebase Console.';

  @override
  String toString() => message;
}

/// Options Firebase chargées depuis l'environnement de l'application.
///
/// Les valeurs ne sont volontairement pas remplacées par des valeurs factices :
/// une configuration absente doit être corrigée avant toute connexion Firebase.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions ne sont pas configurées pour cette plateforme.',
        );
    }
  }

  static FirebaseOptions get web => _options(
        apiKeyVariable: 'FIREBASE_WEB_API_KEY',
        appIdVariable: 'FIREBASE_WEB_APP_ID',
        includeAuthDomain: true,
      );

  static FirebaseOptions get android => _options(
        apiKeyVariable: 'FIREBASE_ANDROID_API_KEY',
        appIdVariable: 'FIREBASE_ANDROID_APP_ID',
      );

  static FirebaseOptions get ios => _options(
        apiKeyVariable: 'FIREBASE_IOS_API_KEY',
        appIdVariable: 'FIREBASE_IOS_APP_ID',
        iosBundleId: 'com.zinderdigital.atelierpro_mobile',
      );

  static FirebaseOptions _options({
    required String apiKeyVariable,
    required String appIdVariable,
    bool includeAuthDomain = false,
    String? iosBundleId,
  }) {
    final missingVariables = <String>[];
    final apiKey = _readRequired(apiKeyVariable, missingVariables);
    final appId = _readRequired(appIdVariable, missingVariables);
    final messagingSenderId = _readRequired(
      'FIREBASE_MESSAGING_SENDER_ID',
      missingVariables,
    );
    final projectId = _readRequired('FIREBASE_PROJECT_ID', missingVariables);
    final storageBucket = _readRequired(
      'FIREBASE_STORAGE_BUCKET',
      missingVariables,
    );

    if (missingVariables.isNotEmpty) {
      throw FirebaseConfigurationException(missingVariables);
    }

    return FirebaseOptions(
      apiKey: apiKey!,
      appId: appId!,
      messagingSenderId: messagingSenderId!,
      projectId: projectId!,
      storageBucket: storageBucket!,
      authDomain: includeAuthDomain ? '$projectId.firebaseapp.com' : null,
      iosBundleId: iosBundleId,
      measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID']?.trim(),
    );
  }

  static String? _readRequired(String variable, List<String> missingVariables) {
    final value = dotenv.env[variable]?.trim();
    if (value == null || value.isEmpty) {
      missingVariables.add(variable);
      return null;
    }
    return value;
  }
}
