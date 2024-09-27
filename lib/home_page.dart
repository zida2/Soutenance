// ignore_for_file: unused_element, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_page.dart' as chat_page;
import 'user_profile_page.dart';

void main() {
  runApp(const AnimalCareApp(name: '',));
}

class AnimalCareApp extends StatelessWidget {
  const AnimalCareApp({super.key, required String name});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AnimalCare',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          titleLarge: const TextStyle(
              fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          bodyMedium: TextStyle(fontSize: 16, color: Colors.grey[800]),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.green, // Couleur des boutons
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const RootPage(),
        '/settings': (context) => const UserProfilePage(userId: ''),
        '/contactOptimization': (context) => const ContactOptimizationPage(),
        '/training': (context) => const TrainingPage(),
        '/maintenance': (context) => const GestationTrackingPage(),
        '/vaccination': (context) => const VaccinationPage(),
        '/home': (context) => const HomePage(),
        // Ajoutez d'autres routes si nécessaire
      },
    );
  }
}

class RootPage extends StatefulWidget {
  const RootPage({super.key});

  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn) {
      return const HomePage();
    } else {
      return const Center(
        child: Text('Vous n\'êtes pas connecté.'),
      );
    }
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
        ],
      ),
      drawer: const CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Optimisation des Contacts'),
              ContactOptimizationCard(onTap: () {
                Navigator.pushNamed(context, '/contactOptimization');
              }),
              const SectionHeader(title: 'Formations'),
              TrainingCard(onTap: () {
                Navigator.pushNamed(context, '/training');
              }),
              const SectionHeader(title: 'Entretien des Animaux'),
              MaintenanceCard(onTap: () {
                Navigator.pushNamed(context, '/maintenance');
              }),
              const SectionHeader(title: 'Carnet de Vaccination'),
              VaccinationCard(onTap: () {
                Navigator.pushNamed(context, '/vaccination');
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class ContactOptimizationCard extends StatelessWidget {
  final VoidCallback onTap;

  const ContactOptimizationCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.contact_phone, color: Colors.blue),
        title: const Text('Optimiser les contacts avec les clients'),
        subtitle: const Text('Gestion des rendez-vous et des communications.'),
        onTap: onTap,
      ),
    );
  }
}

class TrainingCard extends StatelessWidget {
  final VoidCallback onTap;

  const TrainingCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.school, color: Colors.orange),
        title: const Text('Formations pour les Éleveurs'),
        subtitle: const Text('Accédez à des formations et des conseils.'),
        onTap: onTap,
      ),
    );
  }
}

class MaintenanceCard extends StatelessWidget {
  final VoidCallback onTap;

  const MaintenanceCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.medical_services, color: Colors.green),
        title: const Text('Entretien des Animaux'),
        subtitle: const Text('Suivi des soins et de la santé des animaux.'),
        onTap: onTap,
      ),
    );
  }
}

class VaccinationCard extends StatelessWidget {
  final VoidCallback onTap;

  const VaccinationCard({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 5,
      child: ListTile(
        leading: const Icon(Icons.health_and_safety, color: Colors.red),
        title: const Text('Carnet de Vaccination'),
        subtitle: const Text('Gestion des vaccinations et des rappels.'),
        onTap: onTap,
      ),
    );
  }
}

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const UserAccountsDrawerHeader(
            accountName: Text("Nom d'utilisateur"),
            accountEmail: Text("email@example.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                "U",
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.green,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Accueil'),
            onTap: () {
              Navigator.pushNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
    );
  }
}

class ContactOptimizationPage extends StatelessWidget {
  const ContactOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimisation des Contacts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final users = snapshot.data!.docs;
          return ListView(
            children: users.map((user) {
              final userName = user['nom'];
              return ListTile(
                title: Text(userName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => chat_page.ChatPage(userId: user.id, currentUserId: '', contactId: '', contactName: '', userName: null, userPhotoUrl: '', contactPhotoUrl: '',),
                    ),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Formations'),
      ),
      body: const Center(
        child: Text('Page de formations'),
      ),
    );
  }
}

class GestationTrackingPage extends StatelessWidget {
  const GestationTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entretien des Animaux'),
      ),
      body: const Center(
        child: Text('Page de suivi des gestations et des soins'),
      ),
    );
  }
}

class VaccinationPage extends StatelessWidget {
  const VaccinationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carnet de Vaccination'),
      ),
      body: const Center(
        child: Text('Page de gestion des vaccinations'),
      ),
    );
  }
}
