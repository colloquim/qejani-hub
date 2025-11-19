// firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Web (Windows testing)
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAk6zKsuqbKqouql0m7xx_MhKD62Bs71sc',
    authDomain: 'qejani-hub-dev-2025.firebaseapp.com',
    projectId: 'qejani-hub-dev-2025',
    storageBucket: 'qejani-hub-dev-2025.firebasestorage.app',
    messagingSenderId: '516945597826',
    appId: '1:516945597826:web:2c35e858b2c0634a52ab9b',
    measurementId: 'G-0V5GW5N88Q',
  );

  // Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAk6zKsuqbKqouql0m7xx_MhKD62Bs71sc',
    appId: '1:516945597826:android:15cceba32293e81d52ab9b',
    messagingSenderId: '516945597826',
    projectId: 'qejani-hub-dev-2025',
    storageBucket: 'qejani-hub-dev-2025.firebasestorage.app',
  );

  // iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAk6zKsuqbKqouql0m7xx_MhKD62Bs71sc',
    appId: '1:516945597826:ios:5b91b55fc6f6756452ab9b',
    messagingSenderId: '516945597826',
    projectId: 'qejani-hub-dev-2025',
    storageBucket: 'qejani-hub-dev-2025.firebasestorage.app',
    iosBundleId: 'com.example.qejaniHub',
  );
}
