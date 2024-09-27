// ignore_for_file: unused_local_variable, use_build_context_synchronously, no_leading_underscores_for_local_identifiers, unused_import

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class GestationTrackingPage extends StatefulWidget {
  const GestationTrackingPage({super.key});

  @override
  _GestationTrackingPageState createState() => _GestationTrackingPageState();
}

class _GestationTrackingPageState extends State<GestationTrackingPage> {
  String? selectedType;
  String? selectedAnimal;
  final TextEditingController _remarksController = TextEditingController();
  final List<String> _animalTypes = [
    'Bovin', 'Ovin', 'Caprin', 'Porcin', 'Équin', 'Volaille', 'Rongeur'
  ];
  final Map<String, List<String>> _animalNames = {
    'Bovin': ['Vache', 'Taureau', 'Veau'],
    'Ovin': ['Mouton', 'Bélier', 'Agneau'],
    'Caprin': ['Chèvre', 'Boucle', 'Chevreau'],
    'Porcin': ['Cochon', 'Truie', 'Porcelet'],
    'Équin': ['Cheval', 'Jument', 'Poulain'],
    'Volaille': ['Poule', 'Pintade', 'Oie'],
    'Rongeur': ['Hamster', 'Cobaye', 'Lapin'],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de la Gestation'),
        backgroundColor: Colors.lightGreen, // Changer la couleur de l'AppBar en vert clair
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Sélectionnez un type d'animal",
                border: OutlineInputBorder(),
              ),
              value: selectedType,
              items: _animalTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue;
                  selectedAnimal = null; // Réinitialiser l'animal sélectionné
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: "Sélectionnez un animal",
                border: OutlineInputBorder(),
              ),
              value: selectedAnimal,
              items: selectedType != null
                  ? _animalNames[selectedType!]!.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()
                  : [],
              onChanged: (newValue) {
                setState(() {
                  selectedAnimal = newValue;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarques',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _addPregnancyData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen, // Changer la couleur du bouton en vert clair
                foregroundColor: Colors.white, // Couleur du texte
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Enregistrer les données'),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('animals')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Aucun animal enregistré.'));
                }
                final animals = snapshot.data!.docs.where((animal) {
                  final animalData = animal.data() as Map<String, dynamic>;
                  final type = animalData['type'] ?? 'Inconnu';
                  return selectedType == null || selectedType == type;
                }).toList();

                if (animals.isEmpty) {
                  return const Center(
                      child: Text('Aucun animal trouvé pour ce type.'));
                }

                return ListView.builder(
                  itemCount: animals.length,
                  itemBuilder: (context, index) {
                    final animal = animals[index];
                    final animalData = animal.data() as Map<String, dynamic>;
                    final name = animalData['name'] ?? 'Inconnu';
                    final type = animalData['type'] ?? 'Inconnu';
                    final lastPregnancyDate =
                        animalData['lastPregnancyDate'] as Timestamp?;

                    // Calcul de la date estimée de mise bas
                    DateTime? estimatedBirthDate;
                    if (lastPregnancyDate != null) {
                      DateTime lastPregnancy = lastPregnancyDate.toDate();
                      int gestationPeriodDays =
                          _getGestationPeriodDays(type);
                      estimatedBirthDate = lastPregnancy
                          .add(Duration(days: gestationPeriodDays));
                    }

                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: const BorderSide(color: Colors.lightGreen, width: 2),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(name,
                            style: const TextStyle(color: Colors.lightGreen, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Type: $type'),
                            Text(
                              'Date estimée de mise bas: ${estimatedBirthDate != null ? DateFormat('yyyy-MM-dd').format(estimatedBirthDate) : 'Non disponible'}',
                              style: TextStyle(
                                color: estimatedBirthDate != null &&
                                        estimatedBirthDate.isBefore(
                                            DateTime.now()
                                                .add(const Duration(days: 7)))
                                    ? Colors.red
                                    : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.lightGreen),
                              onPressed: () {
                                _showEditDialog(animal);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteAnimalData(animal.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  int _getGestationPeriodDays(String type) {
    switch (type.toLowerCase()) {
      case 'bovin':
        return 280; // jours
      case 'ovin':
        return 150; // jours
      case 'caprin':
        return 150; // jours
      case 'porcin':
        return 114; // jours
      case 'équin':
        return 340; // jours
      case 'volaille':
        return 21; // jours (pour les poulets)
      case 'rongeur':
        return 21; // jours (pour certains rongeurs)
      default:
        return 0; // Type inconnu
    }
  }

  void _addPregnancyData() async {
    if (selectedAnimal == null || selectedType == null) {
      // Affiche une erreur si des champs requis sont manquants
      _showErrorDialog('Erreur', 'Veuillez sélectionner un type d\'animal et un animal.');
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('animals').add({
        'name': selectedAnimal,
        'type': selectedType,
        'remarks': _remarksController.text,
        'lastPregnancyDate': Timestamp.now(), // Enregistre la date actuelle
      });
      // Réinitialiser les champs après l'enregistrement
      setState(() {
        selectedType = null;
        selectedAnimal = null;
        _remarksController.clear();
      });
      _showSuccessDialog('Succès', 'Les données ont été enregistrées.');
    } catch (e) {
      _showErrorDialog('Erreur', 'Une erreur est survenue lors de l\'enregistrement des données.');
    }
  }

  void _deleteAnimalData(String id) async {
    try {
      await FirebaseFirestore.instance.collection('animals').doc(id).delete();
      _showSuccessDialog('Succès', 'L\'animal a été supprimé.');
    } catch (e) {
      _showErrorDialog('Erreur', 'Une erreur est survenue lors de la suppression de l\'animal.');
    }
  }

  void _showEditDialog(DocumentSnapshot animal) {
    final Map<String, dynamic> animalData = animal.data() as Map<String, dynamic>;

    TextEditingController nameController = TextEditingController(text: animalData['name']);
    TextEditingController remarksController = TextEditingController(text: animalData['remarks']);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Éditer les informations de l\'animal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nom de l\'animal'),
              ),
              TextField(
                controller: remarksController,
                decoration: const InputDecoration(labelText: 'Remarques'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                _updateAnimalData(animal.id, nameController.text, remarksController.text);
                Navigator.of(context).pop();
              },
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }

  void _updateAnimalData(String id, String name, String remarks) async {
    try {
      await FirebaseFirestore.instance.collection('animals').doc(id).update({
        'name': name,
        'remarks': remarks,
      });
      _showSuccessDialog('Succès', 'Les informations de l\'animal ont été mises à jour.');
    } catch (e) {
      _showErrorDialog('Erreur', 'Une erreur est survenue lors de la mise à jour des informations de l\'animal.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
