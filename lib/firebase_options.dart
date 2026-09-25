import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError('Web no está configurado en este archivo.');
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions no están configuradas para esta plataforma.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCL_Mryy-wg9sUA8-Ybm7tOEWAJeZ6XcFM',
    appId: '1:711659145200:android:6ade88359f5f15ed75ff35',
    messagingSenderId: '711659145200',
    projectId: 'yava-app-global',
    storageBucket: 'TU_STORAGE_BUCKET_AQUÍ',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'TU_API_KEY_IOS_AQUÍ',
    appId: 'TU_APP_ID_IOS_AQUÍ',
    messagingSenderId: 'TU_SENDER_ID_AQUÍ',
    projectId: 'ID_DE_TU_PROYECTO',
    storageBucket: 'TU_STORAGE_BUCKET_AQUÍ',
    iosBundleId: 'com.example.tu_app',
  );
}
