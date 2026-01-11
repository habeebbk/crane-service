// File: lib/firebase_options.dart
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for android - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDa9M_oNsMuR8MGvDyIfkF_5wJBjhJPYaU',
    appId: '1:972725040452:web:b8fc9dd52932e80e725311',
    messagingSenderId: '972725040452',
    projectId: 'crane-service-77f75',
    authDomain: 'crane-service-77f75.firebaseapp.com',
    storageBucket: 'crane-service-77f75.firebasestorage.app',
    measurementId: 'G-76YQED66CY',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDa9M_oNsMuR8MGvDyIfkF_5wJBjhJPYaU',
    appId:
        '1:972725040452:web:b8fc9dd52932e80e725311', // Reusing Web App ID as placeholder
    messagingSenderId: '972725040452',
    projectId: 'crane-service-77f75',
    authDomain: 'crane-service-77f75.firebaseapp.com',
    storageBucket: 'crane-service-77f75.firebasestorage.app',
    measurementId: 'G-76YQED66CY',
  );
}
