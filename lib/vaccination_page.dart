// ignore_for_file: unused_import, unused_field, use_build_context_synchronously, prefer_final_fields, curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import 'dart:async';

class VaccinationPage extends StatefulWidget {
  const VaccinationPage({super.key});

  @override
  _VaccinationPageState createState() => _VaccinationPageState();
}

class _VaccinationPageState extends State<VaccinationPage> {
  final NotificationService _notificationService = NotificationService();
  final PageController _pageController = PageController();
  final DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(minutes: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage == 3) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _navigateToAddVaccinePage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddVaccinePage()),
    );
  }

  Widget _buildAwarenessCard() {
    return SizedBox(
      height: 200.0,
      child: PageView(
        controller: _pageController,
        children: [
          _buildImageCard('lib/assets/vaccine1.jpg'),
          _buildImageCard('lib/assets/vaccine2.jpg'),
          _buildImageCard('lib/assets/vaccine3.jpg'),
        ],
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildVaccineList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('vaccines').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Aucun vaccin pour le moment.'));
        }
        final vaccines = snapshot.data!.docs;
        return ListView.builder(
          itemCount: vaccines.length,
          itemBuilder: (context, index) {
            final vaccineData = vaccines[index].data() as Map<String, dynamic>;
            final name = vaccineData['name'] ?? 'Inconnu';
            final nextReminderDate = DateTime.parse(vaccineData['nextReminderDate']);
            final docId = vaccines[index].id;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16.0),
                title: Text(name),
                subtitle: Text('Prochain rappel: ${nextReminderDate.toLocal()}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditVaccinePage(vaccineId: docId),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await FirebaseFirestore.instance.collection('vaccines').doc(docId).delete();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.info, color: Colors.green),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Détails du Vaccin'),
                            content: Text(vaccineData['notes'] ?? 'Pas de détails'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Fermer'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vos Vaccins'),
        backgroundColor: Colors.green.withOpacity(0.5),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAwarenessCard(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Découvrez nos recommandations pour les vaccins. Assurez-vous que vos animaux sont protégés.',
              style: TextStyle(fontSize: 16.0, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _buildVaccineList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddVaccinePage,
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddVaccinePage extends StatefulWidget {
  const AddVaccinePage({super.key});

  @override
  _AddVaccinePageState createState() => _AddVaccinePageState();
}

class _AddVaccinePageState extends State<AddVaccinePage> {
  final TextEditingController _vaccineNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _numberOfAnimalsController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final NotificationService _notificationService = NotificationService();
  String? _selectedAnimalType;
  String? _customVaccineName;

  final List<String> _vaccineNames = [
    'Vaccin contre la grippe aviaire',
    'Vaccin contre la fièvre aphteuse',
    'Vaccin contre la myxomatose',
    'Vaccin contre la brucellose',
    'Vaccin contre la parvovirose',
    'Vaccin contre la leptospirose',
  ];

  final List<String> _animalTypes = [
    'Bovins',
    'Caprins',
    'Ovins',
    'Porcins',
    'Equins',
    'Canins',
    'Félins',
    'Aviaires',
  ];

  void _addVaccine() async {
    final String name = _customVaccineName?.isNotEmpty == true ? _customVaccineName! : _vaccineNameController.text.trim();
    final String notes = _notesController.text.trim();
    final int numberOfAnimals = int.tryParse(_numberOfAnimalsController.text) ?? 1;

    if (name.isEmpty || _selectedAnimalType == null) return;

    final CollectionReference vaccines = FirebaseFirestore.instance.collection('vaccines');

    // Assurez-vous que les données ne sont pas déjà présentes
    final existingVaccines = await vaccines.where('name', isEqualTo: name).get();
    if (existingVaccines.docs.isNotEmpty) {
      // Logique pour éviter l'ajout de doublons ou afficher un message à l'utilisateur
      return;
    }

    for (int i = 0; i < numberOfAnimals; i++) {
      await vaccines.add({
        'name': name,
        'animalType': _selectedAnimalType,
        'lastDoseDate': DateTime.now().toIso8601String(),
        'nextReminderDate': _selectedDate.toIso8601String(),
        'notes': notes,
      });
    }

    _notificationService.scheduleNotification(_selectedDate);

    _vaccineNameController.clear();
    _notesController.clear();
    _numberOfAnimalsController.clear();
    setState(() {
      _customVaccineName = null;
      _selectedAnimalType = null;
    });
    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajouter un Vaccin'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<String>(
              value: _customVaccineName == null ? null : 'Autre',
              decoration: const InputDecoration(
                labelText: 'Nom du Vaccin',
                border: OutlineInputBorder(),
              ),
              items: [
                ..._vaccineNames.map(
                  (name) => DropdownMenuItem<String>(
                    value: name,
                    child: Text(name),
                  ),
                ),
                const DropdownMenuItem<String>(
                  value: 'Autre',
                  child: Text('Autre'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  if (value == 'Autre') {
                    _customVaccineName = '';
                  } else {
                    _customVaccineName = value;
                  }
                });
              },
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le champ DropdownButtonFormField
            if (_customVaccineName == 'Autre')
              TextField(
                controller: _vaccineNameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du Vaccin',
                  border: OutlineInputBorder(),
                ),
              ),
            const SizedBox(height: 16.0), // Ajout d'espace après le TextField
            DropdownButtonFormField<String>(
              value: _selectedAnimalType,
              decoration: const InputDecoration(
                labelText: 'Type d\'Animal',
                border: OutlineInputBorder(),
              ),
              items: _animalTypes.map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                ),
              ).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAnimalType = value;
                });
              },
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le champ DropdownButtonFormField
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le TextField
            TextField(
              controller: _numberOfAnimalsController,
              decoration: const InputDecoration(
                labelText: 'Nombre d\'Animaux',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le TextField
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Sélectionner la Date'),
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le ElevatedButton
            ElevatedButton(
              onPressed: _addVaccine,
              child: const Text('Ajouter le Vaccin'),
            ),
          ],
        ),
      ),
    );
  }
}

class EditVaccinePage extends StatefulWidget {
  final String vaccineId;

  const EditVaccinePage({super.key, required this.vaccineId});

  @override
  _EditVaccinePageState createState() => _EditVaccinePageState();
}

class _EditVaccinePageState extends State<EditVaccinePage> {
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _numberOfAnimalsController;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _notesController = TextEditingController();
    _numberOfAnimalsController = TextEditingController();
    _loadVaccineData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _numberOfAnimalsController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccineData() async {
    final doc = await FirebaseFirestore.instance.collection('vaccines').doc(widget.vaccineId).get();
    if (doc.exists) {
      final data = doc.data()!;
      _nameController.text = data['name'];
      _notesController.text = data['notes'] ?? '';
      _numberOfAnimalsController.text = data['numberOfAnimals']?.toString() ?? '1';
      _selectedDate = DateTime.parse(data['nextReminderDate']);
    }
  }

  void _updateVaccine() async {
    final String name = _nameController.text.trim();
    final String notes = _notesController.text.trim();
    final int numberOfAnimals = int.tryParse(_numberOfAnimalsController.text) ?? 1;

    if (name.isEmpty) return;

    await FirebaseFirestore.instance.collection('vaccines').doc(widget.vaccineId).update({
      'name': name,
      'notes': notes,
      'numberOfAnimals': numberOfAnimals,
      'nextReminderDate': _selectedDate.toIso8601String(),
    });

    Navigator.pop(context);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modifier un Vaccin'),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du Vaccin',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le TextField
            TextField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le TextField
            TextField(
              controller: _numberOfAnimalsController,
              decoration: const InputDecoration(
                labelText: 'Nombre d\'Animaux',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le TextField
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Sélectionner la Date'),
            ),
            const SizedBox(height: 16.0), // Ajout d'espace après le ElevatedButton
            ElevatedButton(
              onPressed: _updateVaccine,
              child: const Text('Mettre à Jour le Vaccin'),
            ),
          ],
        ),
      ),
    );
  }
}
