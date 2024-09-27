// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ChatPage extends StatefulWidget {
  final String currentUserId;
  final String contactId;
  final String contactName;
  final String contactPhotoUrl;

  const ChatPage({
    super.key,
    required this.currentUserId,
    required this.contactId,
    required this.contactName,
    required this.contactPhotoUrl, required String userId, required String userPhotoUrl, required userName,
  });

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController messageController = TextEditingController();
  final CollectionReference chats = FirebaseFirestore.instance.collection('chats');
  final ScrollController scrollController = ScrollController();
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool isRecording = false;
  String? chatId;

  @override
  void initState() {
    super.initState();
    _recorder.openRecorder();
    _initializeChat();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }

  // Initialiser ou obtenir l'ID de chat entre les deux utilisateurs
  Future<void> _initializeChat() async {
    final chatDoc = await chats
        .where('participants', arrayContains: widget.currentUserId)
        .where('participants', arrayContains: widget.contactId)
        .limit(1)
        .get();

    if (chatDoc.docs.isNotEmpty) {
      setState(() {
        chatId = chatDoc.docs.first.id;
      });
    } else {
      final newChat = await chats.add({
        'participants': [widget.currentUserId, widget.contactId],
        'created_at': FieldValue.serverTimestamp(),
      });
      setState(() {
        chatId = newChat.id;
      });
    }
  }

  Future<void> sendMessage(String message) async {
    if (message.isEmpty || chatId == null) return;

    await chats.doc(chatId).collection('messages').add({
      'userId': widget.currentUserId,
      'userName': widget.currentUserId, // Mettre le nom de l'utilisateur
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    messageController.clear();
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  Future<void> startRecording() async {
    await _recorder.startRecorder();
    setState(() {
      isRecording = true;
    });
  }

  Future<void> stopRecording() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

    final result = await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
    });

    // Envoyer le fichier audio à Firebase Storage
    File audioFile = File(path);
    await audioFile.writeAsBytes(await File(result!).readAsBytes());

    final audioUrl = await _uploadFileToStorage(audioFile);

    // Enregistrer l'URL audio dans Firestore
    await _sendFileMessage(audioUrl, 'audio');
  }

  Future<String> _uploadFileToStorage(File file) async {
    final storageRef = FirebaseStorage.instance.ref().child('chat_audios/${file.path.split('/').last}');
    final uploadTask = await storageRef.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _sendFileMessage(String fileUrl, String fileType) async {
    if (chatId == null) return;

    await chats.doc(chatId).collection('messages').add({
      'userId': widget.currentUserId,
      'userName': widget.currentUserId, // Nom de l'utilisateur
      'fileUrl': fileUrl,
      'fileType': fileType,
      'timestamp': FieldValue.serverTimestamp(),
    });

    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(widget.contactPhotoUrl),
        ),
        title: Text('Chat avec ${widget.contactName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Ouvrir les paramètres
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: chats.doc(chatId).collection('messages').orderBy('timestamp').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text('Aucun message pour le moment.'));
                      }
                      final messages = snapshot.data!.docs;
                      return ListView.builder(
                        controller: scrollController,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final messageData = messages[index].data() as Map<String, dynamic>;
                          final message = messageData['message'] ?? '';
                          final senderId = messageData['userId'] ?? '';
                          final isMe = senderId == widget.currentUserId;

                          if (messageData.containsKey('fileUrl')) {
                            final fileType = messageData['fileType'];
                            final fileUrl = messageData['fileUrl'];

                            if (fileType == 'audio') {
                              return ListTile(
                                title: Align(
                                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                                  child: IconButton(
                                    icon: const Icon(Icons.play_arrow),
                                    onPressed: () {
                                      // Lire l'audio ici
                                    },
                                  ),
                                ),
                              );
                            }
                            // Pour les autres types de fichiers comme les images
                          }

                          return ListTile(
                            title: Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.blue : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(message),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: const InputDecoration(
                      hintText: 'Tapez votre message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(messageController.text),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: () async {
                  // Ajouter la fonctionnalité pour envoyer des fichiers (comme des images)
                  // Par exemple, en utilisant image_picker pour sélectionner une image et l'uploader.
                },
              ),
              IconButton(
                icon: Icon(isRecording ? Icons.stop : Icons.mic),
                onPressed: () {
                  if (isRecording) {
                    stopRecording();
                  } else {
                    startRecording();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
