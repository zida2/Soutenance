import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'package:logger/logger.dart';
import 'firebase_options.dart';
import 'home_page.dart'; // Assurez-vous que cette importation est correcte
import 'chat_page.dart';
import 'splash_screen.dart';
import 'service_page.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i("Firebase initialized successfully");
  } catch (e) {
    logger.e("Failed to initialize Firebase: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AnimalCare',
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const AnimalCareApp(name: ''), // Assurez-vous que ce constructeur est correct
        '/chat': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
          return ChatPage(
            userId: args?['userId'] ?? '',
            userName: args?['userName'] ?? '',
            userPhotoUrl: args?['userPhotoUrl'] ?? '',
            contactId: args?['contactId'] ?? '',
            currentUserId: args?['currentUserId'] ?? '',
            contactName: args?['contactName'] ?? '',
            contactPhotoUrl: args?['contactPhotoUrl'] ?? '',
          );
        },
        '/service': (context) => const ServicesPage(),
      },
    );
  }
}
     