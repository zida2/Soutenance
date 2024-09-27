// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();  
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    final userSnapshot = await userDoc.get();
    if (userSnapshot.exists) {
      final userData = userSnapshot.data()!;
      _nameController.text = userData['name'] ?? '';
      _bioController.text = userData['bio'] ?? '';
    }
  }

  Future<void> _updateUserData() async {
    final userDoc = FirebaseFirestore.instance.collection('users').doc(widget.userId);
    await userDoc.update({
      'name': _nameController.text,
      'bio': _bioController.text,
    });
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                // Ajoutez la logique pour changer la photo de profil ici
              },
              child: CircleAvatar(
                radius: 50,
                backgroundImage: const  NetworkImage('URL de la photo de profil'), // Modifiez selon votre besoin
                child: _isEditing
                    ? const  Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const  InputDecoration(
                      labelText: 'Nom',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    _nameController.text,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  )
                : Text(
                    _bioController.text,
                    style: const TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isEditing ? _updateUserData : () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: Icon(_isEditing ? Icons.save : Icons.edit),
              label: Text(_isEditing ? 'Enregistrer' : 'Modifier le Profil'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen, 
                foregroundColor: Colors.lightGreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
