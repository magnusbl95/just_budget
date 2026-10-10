import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

class FirebaseBootstrap {
  static Future<FirebaseApp?> initialize() async {
    final options = DefaultFirebaseOptions.currentPlatform;

    if (options.apiKey.isEmpty ||
        options.appId.isEmpty ||
        options.messagingSenderId.isEmpty ||
        options.projectId.isEmpty) {
      return null;
    }

    return Firebase.initializeApp(options: options);
  }
}
