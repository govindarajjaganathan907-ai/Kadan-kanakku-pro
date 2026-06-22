// File generated normally by the FlutterFire CLI:
//   flutterfire configure
//
// This is a PLACEHOLDER. Replace each value below with the config from
// your own Firebase project (Project Settings > General > Your apps).
// Run `flutterfire configure` in the project root to auto-generate this
// file correctly for Android/iOS/web.

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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'YOUR_WEB_API_KEY',
    appId: 'YOUR_WEB_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'kadan-kanakku-pro',
    storageBucket: 'kadan-kanakku-pro.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'YOUR_ANDROID_API_KEY',
    appId: 'YOUR_ANDROID_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'kadan-kanakku-pro',
    storageBucket: 'kadan-kanakku-pro.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId: 'kadan-kanakku-pro',
    storageBucket: 'kadan-kanakku-pro.appspot.com',
    iosBundleId: 'com.yourcompany.kadankanakkupro',
  );
}
