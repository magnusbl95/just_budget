import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Firebase is configured for web. Run FlutterFire configure for other platforms.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDs1uZ2OURLGmPfMkvsLZTSYWDcml3SjfI',
    appId: '1:621819917509:web:8c84e71430903196b3acac',
    messagingSenderId: '621819917509',
    projectId: 'just-budget-21ae5',
    authDomain: 'just-budget-21ae5.firebaseapp.com',
    storageBucket: 'just-budget-21ae5.firebasestorage.app',
    measurementId: 'G-RFY7Y330RS',
  );
}
