// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // N'oubliez pas d'ajouter cette dépendance dans votre pubspec.yaml

class TrainingPage extends StatelessWidget {
  const TrainingPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Exemple de liste de formations
    final List<TrainingPost> posts = [
      TrainingPost(
        title: 'Formation sur l\'élevage des bovins',
        description: 'Apprenez les meilleures pratiques pour l\'élevage des bovins.',
        videoUrl: 'https://example.com/video1',
        articleUrl: 'https://example.com/article1',
        imageUrl: 'https://example.com/image1.jpg',
        tips: 'Conseil: Assurez-vous d\'avoir un bon abri pour les bovins.',
      ),
      TrainingPost(
        title: 'Formation sur l\'alimentation des animaux',
        description: 'Découvrez les besoins nutritionnels des animaux.',
        videoUrl: 'https://example.com/video2',
        articleUrl: 'https://example.com/article2',
        imageUrl: 'https://example.com/image2.jpg',
        tips: 'Conseil: Utilisez des aliments riches en protéines pour les jeunes animaux.',
      ),
      // Ajoutez d'autres formations ici
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formations'),
        backgroundColor: Colors.green[600],
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du post
                Image.network(post.imageUrl, fit: BoxFit.cover),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    post.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(post.description),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Conseil: ${post.tips}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ButtonBar(
                  children: [
                    TextButton(
                      onPressed: () => _launchURL(post.videoUrl),
                      child: const Text('Voir la vidéo'),
                    ),
                    TextButton(
                      onPressed: () => _launchURL(post.articleUrl),
                      child: const Text('Lire l\'article'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible de lancer $url';
    }
  }
}

class TrainingPost {
  final String title;
  final String description;
  final String videoUrl;
  final String articleUrl;
  final String imageUrl;
  final String tips;

  TrainingPost({
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.articleUrl,
    required this.imageUrl,
    required this.tips,
  });
}
