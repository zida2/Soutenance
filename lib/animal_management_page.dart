// ignore: file_names
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AnimalManagementPage extends StatelessWidget {
  const AnimalManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Animaux'),
        backgroundColor: Colors.green[600],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB2FF59), // Vert clair
              Color(0xFF76FF03), // Vert un peu plus foncé
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('animals').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Une erreur s\'est produite.'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('Aucun animal trouvé.'));
            }

            var animals = snapshot.data!.docs;

            return ListView.builder(
              itemCount: animals.length,
              itemBuilder: (context, index) {
                var animal = animals[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 3,
                  child: ListTile(
                    title: Text(animal['name']),
                    subtitle: Text('Espèce: ${animal['species']}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AnimalDetailPage(animalId: animal.id),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class AnimalDetailPage extends StatelessWidget {
  final String animalId;

  const AnimalDetailPage({super.key, required this.animalId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'Animal'),
        backgroundColor: Colors.green[600],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFB2FF59), // Vert clair
              Color(0xFF76FF03), // Vert un peu plus foncé
            ],
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('animals').doc(animalId).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Une erreur s\'est produite.'));
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Aucun détail trouvé pour cet animal.'));
            }

            var animal = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nom: ${animal['name']}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Espèce: ${animal['species']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  // Ajouter d'autres informations et options pour l'édition
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
