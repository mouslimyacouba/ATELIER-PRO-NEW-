import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Options Firebase par défaut générées / configurées.
/// Les clés peuvent être surchargées via le fichier .env ou via `flutterfire configure`.
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

  static FirebaseOptions get web => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? 'AIzaSyDummyWebApiKeyForAtelierPro',
        appId: dotenv.env['FIREBASE_WEB_APP_ID'] ?? '1:1234567890:web:abcdef',
        messagingSenderId: '569744918009',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'atelier-pro-1a9e8',
        authDomain: '${dotenv.env['FIREBASE_PROJECT_ID'] ?? 'atelier-pro-1a9e8'}.firebaseapp.com',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'atelier-pro-1a9e8.firebasestorage.app',
        measurementId: dotenv.env['FIREBASE_WEB_MEASUREMENT_ID'],
      );

  static FirebaseOptions get android => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? 'AIzaSyDummyAndroidApiKeyForAtelierPro',
        appId: dotenv.env['FIREBASE_ANDROID_APP_ID'] ?? '1:1234567890:android:abcdef',
        messagingSenderId: '569744918009',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'atelier-pro-1a9e8',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'atelier-pro-1a9e8.firebasestorage.app',
      );

  static FirebaseOptions get ios => FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? 'AIzaSyDummyIosApiKeyForAtelierPro',
        appId: dotenv.env['FIREBASE_IOS_APP_ID'] ?? '1:1234567890:ios:abcdef',
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '569744918009',
        projectId: dotenv.env['FIREBASE_PROJECT_ID'] ?? 'atelier-pro-1a9e8',
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? 'atelier-pro-1a9e8.firebasestorage.app',
        iosBundleId: 'com.zinderdigital.atelierpro_mobile',
      );
}
