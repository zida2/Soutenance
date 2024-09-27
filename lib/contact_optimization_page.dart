import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';
import 'user_profile_page.dart'; // Assurez-vous d'avoir une page de profil

class ContactOptimizationPage extends StatelessWidget {
  const ContactOptimizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Optimisation des Contacts'),
        backgroundColor: Colors.lightGreen,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé.'));
          }
          final users = snapshot.data!.docs;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index].data() as Map<String, dynamic>;
              final name = user['nom'] ?? 'Nom non disponible';
              final email = user['email'] ?? 'Email non disponible';
              final userId = user['userId'] ?? '';
              final userPhotoUrl = user['photoUrl'] ?? 'https://via.placeholder.com/150';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 5,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12.0),
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(userPhotoUrl),
                    radius: 30,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.green.shade800,
                    ),
                  ),
                  subtitle: Text(
                    email,
                    style: TextStyle(
                      color: Colors.green.shade600,
                    ),
                  ),
                  trailing: Wrap(
                    spacing: 12, // Espace entre les icônes
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.chat),
                        color: Colors.lightGreen,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                userId: userId,
                                userName: name,
                                userPhotoUrl: userPhotoUrl,
                                contactId: '', // Ajouter un contactId si nécessaire
                                currentUserId: '',
                                contactName: '', 
                                contactPhotoUrl: '', // Passer les données de l'utilisateur si nécessaire
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.account_circle),
                        color: Colors.lightGreen,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserProfilePage(
                                userId: userId,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Action à réaliser lors du clic sur l'élément de la liste
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action à réaliser lors du clic sur le bouton flottant
        },
        backgroundColor: Colors.lightGreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
