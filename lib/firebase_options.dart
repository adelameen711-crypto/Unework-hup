// ⚠️ هذا الملف يتم إنشاؤه تلقائياً بواسطة FlutterFire CLI.
// لا تقم بتعديله يدوياً.

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
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC5jrPdbbTd27GiYA83ppRPHQn7X5v9Tso',
    appId: '1:393820747026:web:3dfdaa22d4267206762fcb',
    messagingSenderId: '393820747026',
    projectId: 'unework-hub-253cb',
    authDomain: 'unework-hub-253cb.firebaseapp.com',
    storageBucket: 'unework-hub-253cb.firebasestorage.app',
    measurementId: 'G-2H53C0WDC0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDDp98_TCNvI9SwMFRnWQEcnZTsElvbQOY',
    appId: '1:393820747026:android:7a4385029cd26779762fcb',
    messagingSenderId: '393820747026',
    projectId: 'unework-hub-253cb',
    storageBucket: 'unework-hub-253cb.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA4RG-hqDcJofaWlyTDKnivy1ui2fWFWSU',
    appId: '1:393820747026:ios:804f1048a8920d9e762fcb',
    messagingSenderId: '393820747026',
    projectId: 'unework-hub-253cb',
    storageBucket: 'unework-hub-253cb.firebasestorage.app',
    iosBundleId: 'com.example.uneworkHub',
  );
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA4RG-hqDcJofaWlyTDKnivy1ui2fWFWSU',
    appId: '1:393820747026:ios:804f1048a8920d9e762fcb',
    messagingSenderId: '393820747026',
    projectId: 'unework-hub-253cb',
    storageBucket: 'unework-hub-253cb.firebasestorage.app',
    iosBundleId: 'com.example.uneworkHub',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC5jrPdbbTd27GiYA83ppRPHQn7X5v9Tso',
    appId: '1:393820747026:web:3e08e52d48249d2e762fcb',
    messagingSenderId: '393820747026',
    projectId: 'unework-hub-253cb',
    authDomain: 'unework-hub-253cb.firebaseapp.com',
    storageBucket: 'unework-hub-253cb.firebasestorage.app',
    measurementId: 'G-9QRW0MKHDQ',
  );
  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey123456789',
    appId: '1:123456789:web:abcdef123456',
    messagingSenderId: '123456789',
    projectId: 'unework-hub',
    authDomain: 'unework-hub.firebaseapp.com',
    storageBucket: 'unework-hub.appspot.com',
    measurementId: 'G-ABCDEFGH',
  );
}
