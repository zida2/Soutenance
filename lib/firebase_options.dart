import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'AIzaSyBozwHwfGcAuiraVs8reOoMA-UapAs1wRU',
      appId: 'your-app-id',
      messagingSenderId: 'your-messaging-sender-id',
      projectId: 'soutenance-ca2f1',
      databaseURL: 'your-database-url', // Ajoutez cela si vous utilisez la base de données en temps réel
      storageBucket: 'your-storage-bucket',
    );
  }
}
