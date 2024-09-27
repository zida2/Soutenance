import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'add_publication_page.dart';
import 'add_story_page.dart';
import 'user_profile_page.dart' as profile;
import 'vaccination_page.dart' as vaccination;
import 'home_page.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  _ServicesPageState createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const ServicesPageContent(),
    const vaccination.VaccinationPage(),
    const HomePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AnimalCare',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const profile.UserProfilePage(userId: 'some_user_id'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddPublicationPage(
                    authorName: 'Utilisateur',
                    authorId: 'some_user_id',
                    title: '',
                    content: '',
                    onTap: () {},
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.network_wifi, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.vaccines, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

class ServicesPageContent extends StatefulWidget {
  const ServicesPageContent({super.key});

  @override
  _ServicesPageContentState createState() => _ServicesPageContentState();
}

class _ServicesPageContentState extends State<ServicesPageContent> {
  final Map<String, bool> _expandedComments = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stories',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontFamily: 'Graffiti',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => const AddStoryPage()));
                    },
                    child: const Icon(Icons.add, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Erreur: ${snapshot.error}'));
                        }

                        final users = snapshot.data?.docs ?? [];
                        if (users.isEmpty) {
                          return const Center(child: Text('Aucun utilisateur trouvé.'));
                        }

                        return ListView(
                          scrollDirection: Axis.horizontal,
                          children: users.map((user) {
                            final userData = user.data() as Map<String, dynamic>;
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(40),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.network(
                                        userData['photoUrl'] ??
                                            'https://via.placeholder.com/150',
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return const Icon(Icons.error);
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(userData['name'] ?? 'Nom inconnu',
                                      style: const TextStyle(fontSize: 16)),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('publications').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erreur: ${snapshot.error}'));
              }

              final publications = snapshot.data?.docs ?? [];
              if (publications.isEmpty) {
                return const Center(child: Text('Aucune publication trouvée.'));
              }

              return ListView.builder(
                itemCount: publications.length,
                itemBuilder: (context, index) {
                  final publication = publications[index].data() as Map<String, dynamic>;
                  final title = publication['title'] ?? 'No Title';
                  final content = publication['content'] ?? 'No Content';
                  final timestamp = publication['date'] as Timestamp?;
                  final date = timestamp?.toDate() ?? DateTime.now();
                  final formattedDate =
                      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
                  final likes = publication['likes'] ?? 0;
                  final comments = publication['comments'] != null
                      ? List<Map<String, dynamic>>.from(publication['comments'])
                      : [];

                  final authorPhotoUrl =
                      publication['authorPhotoUrl'] ?? 'https://via.placeholder.com/150';
                  final authorName = publication['authorName'] ?? 'Auteur inconnu';

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with user's profile picture and name
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: NetworkImage(authorPhotoUrl),
                                radius: 25,
                              ),
                               const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  authorName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Content of the publication
                        if (publication['image'] != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              publication['image'] ?? 'https://via.placeholder.com/150',
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.error);
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            title,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(content),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('Publié le: $formattedDate'),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.thumb_up_alt_outlined),
                                onPressed: () {
                                  // Logique pour aimer la publication
                                },
                              ),
                              Text('$likes j\'aime'),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.share),
                                onPressed: () {
                                  // Logique pour partager la publication
                                },
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ExpansionPanelList(
                            elevation: 1,
                            expandedHeaderPadding: const EdgeInsets.all(0),
                            expansionCallback: (int panelIndex, bool isExpanded) {
                              setState(() {
                                _expandedComments[publication['id']] =
                                    !(_expandedComments[publication['id']] ?? false);
                              });
                            },
                            children: [
                              ExpansionPanel(
                                headerBuilder: (BuildContext context, bool isExpanded) {
                                  return ListTile(
                                    title: Text('${comments.length} commentaires'),
                                  );
                                },
                                body: Column(
                                  children: [
                                    for (var comment in comments)
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundImage: NetworkImage(comment['authorPhotoUrl']),
                                        ),
                                        title: Text(comment['authorName']),
                                        subtitle: Text(comment['content']),
                                      ),
                                  ],
                                ),
                                isExpanded:
                                    _expandedComments[publication['id']] ?? false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
