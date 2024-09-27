// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AddStoryPage extends StatefulWidget {
  const AddStoryPage({super.key});

  @override
  _AddStoryPageState createState() => _AddStoryPageState();
}

class _AddStoryPageState extends State<AddStoryPage> {
  final _descriptionController = TextEditingController();
  File? _selectedFile;
  Uint8List? _selectedFileData;
  final ImagePicker _picker = ImagePicker();
  bool _isVideo = false;

  Future<void> _pickMedia() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        if (kIsWeb) {
          // For web, use Uint8List to hold the file data
          pickedFile.readAsBytes().then((data) {
            setState(() {
              _selectedFileData = data;
            });
          });
        } else {
          // For mobile, use File
          _selectedFile = File(pickedFile.path);
        }
        _isVideo = pickedFile.path.endsWith('.mp4');
      });
    }
  }

  Future<void> _uploadStory() async {
    if ((_selectedFile == null && _selectedFileData == null) || _descriptionController.text.isEmpty) {
      return;
    }

    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final storageRef = FirebaseStorage.instance.ref().child('stories/$fileName');

    try {
      if (kIsWeb) {
        // Handle web upload
        if (_selectedFileData != null) {
          final uploadTask = storageRef.putData(_selectedFileData!);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance.collection('stories').add({
            'imageUrl': downloadUrl,
            'description': _descriptionController.text,
            'authorId': 'currentUserId',
            'authorName': 'currentUserName',
            'date': Timestamp.now(),
            'type': _isVideo ? 'video' : 'image',
          });
        }
      } else {
        // Handle mobile upload
        if (_selectedFile != null) {
          final uploadTask = storageRef.putFile(_selectedFile!);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();

          await FirebaseFirestore.instance.collection('stories').add({
            'imageUrl': downloadUrl,
            'description': _descriptionController.text,
            'authorId': 'currentUserId',
            'authorName': 'currentUserName',
            'date': Timestamp.now(),
            'type': _isVideo ? 'video' : 'image',
          });
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error uploading story: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Story'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: _pickMedia,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightGreen.shade200, Colors.lightGreen.shade500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickMedia,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    height: 200,
                    width: double.infinity,
                    child: kIsWeb
                        ? _selectedFileData != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  _selectedFileData!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              )
                        : _selectedFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _selectedFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Colors.grey[400],
                                ),
                              ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _uploadStory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
