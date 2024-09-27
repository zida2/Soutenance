// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _prenomsController = TextEditingController();
  bool _isEntrepreneur = false;
  String? _selectedCountry;
  String? _selectedCity;
  String? _gender;
  bool _isLoading = false;
  String? _errorMessage;
  bool _showConfirmation = false;
  String _confirmationMessage = '';
  File? _avatarImage;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _countries = [
    'Burkina Faso',
    'Ghana',
    'Ivory Coast',
    'Mali',
    'Nigeria'
  ];

  final Map<String, List<String>> _cities = {
    'Burkina Faso': [
      'Ouagadougou',
      'Bobo-Dioulasso',
      'Koudougou',
      'Ouahigouya',
      'Banfora',
      'Fada N\'gourma',
      'Manga',
      'Ziniaré',
      'Tenkodogo',
      'Dédougou'
    ],
    'Ghana': ['Accra', 'Kumasi', 'Tamale', 'Takoradi', 'Ashaiman'],
    'Ivory Coast': ['Abidjan', 'Bouaké', 'Daloa', 'San Pedro', 'Yamoussoukro'],
    'Mali': ['Bamako', 'Sikasso', 'Kayes', 'Mopti', 'Koulikoro'],
    'Nigeria': ['Lagos', 'Abuja', 'Kano', 'Ibadan', 'Benin City'],
  };

  Future<void> _pickAvatarImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _avatarImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Les mots de passe ne correspondent pas.';
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        String? avatarUrl;
        if (_avatarImage != null) {
          final storageRef = FirebaseStorage.instance.ref().child('avatars/${userCredential.user!.uid}');
          await storageRef.putFile(_avatarImage!);
          avatarUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'nom': _nameController.text,
          'prenoms': _prenomsController.text,
          'email': _emailController.text,
          'isEntrepreneur': _isEntrepreneur,
          'country': _selectedCountry,
          'city': _selectedCity,
          'gender': _gender,
          'avatarUrl': avatarUrl,
        });

        setState(() {
          _isLoading = false;
          _showConfirmation = true;
          _confirmationMessage = 'Inscription réussie ! Bienvenue, ${_nameController.text}.';
        });

        _clearForm();

        // Navigate to home page after successful registration
        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Une erreur inattendue est survenue.';
        });
      }
    }
  }

  void _clearForm() {
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _nameController.clear();
    _prenomsController.clear();
    setState(() {
      _isEntrepreneur = false;
      _selectedCountry = null;
      _selectedCity = null;
      _gender = null;
      _avatarImage = null;
    });
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _pickAvatarImage,
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        backgroundImage: _avatarImage != null ? FileImage(_avatarImage!) : null,
        child: _avatarImage == null
            ? Icon(
                Icons.add_a_photo,
                size: 40,
                color: Colors.grey[700],
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inscription'),
        backgroundColor: const Color(0xFF66BB6A), // Vert clair
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE8F5E9), // Vert très clair
              Color(0xFFC8E6C9), // Vert clair
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              _buildAvatar(),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildTextField(_nameController, 'Nom', Icons.person),
                    const SizedBox(height: 10),
                    _buildTextField(_prenomsController, 'Prénoms', Icons.person_outline),
                    const SizedBox(height: 10),
                    _buildTextField(_emailController, 'Email', Icons.email, inputType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    _buildPasswordTextField(_passwordController, 'Mot de passe'),
                    const SizedBox(height: 10),
                    _buildPasswordTextField(_confirmPasswordController, 'Confirmer le mot de passe'),
                    const SizedBox(height: 10),
                    _buildDropdownField('Pays', _countries, _selectedCountry, (newValue) {
                      setState(() {
                        _selectedCountry = newValue;
                        _selectedCity = null;
                      });
                    }),
                    const SizedBox(height: 10),
                    if (_selectedCountry != null)
                      _buildDropdownField('Ville', _cities[_selectedCountry!]!, _selectedCity, (newValue) {
                        setState(() {
                          _selectedCity = newValue;
                        });
                      }),
                    const SizedBox(height: 10),
                    _buildGenderField(),
                    const SizedBox(height: 10),
                    _buildEntrepreneurField(),
                    const SizedBox(height: 20),
                    _buildRegisterButton(),
                    if (_isLoading)
                      const CircularProgressIndicator(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      ),
                    if (_showConfirmation)
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          _confirmationMessage,
                          style: const TextStyle(color: Colors.green, fontSize: 16),
                        ),
                      ),
                    const SizedBox(height: 20),
                    _buildLoginButton(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildSocialLoginButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType inputType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordTextField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      obscureText: label == 'Mot de passe' ? _obscurePassword : _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            label == 'Mot de passe'
                ? (_obscurePassword ? Icons.visibility_off : Icons.visibility)
                : (_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
          ),
          onPressed: () {
            setState(() {
              if (label == 'Mot de passe') {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String? selectedItem, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedItem,
      onChanged: onChanged,
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.location_city),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Ce champ est requis';
        }
        return null;
      },
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('Sexe'),
        Row(
          children: <Widget>[
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Homme'),
                value: 'Homme',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
            ),
            Expanded(
              child: RadioListTile<String>(
                title: const Text('Femme'),
                value: 'Femme',
                groupValue: _gender,
                onChanged: (value) {
                  setState(() {
                    _gender = value;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEntrepreneurField() {
    return CheckboxListTile(
      title: const Text('Êtes-vous un entrepreneur ?'),
      value: _isEntrepreneur,
      onChanged: (bool? value) {
        setState(() {
          _isEntrepreneur = value ?? false;
        });
      },
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _registerUser,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: const Text(
        'S\'inscrire',
        style: TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildLoginButton() {
    return TextButton(
      onPressed: () {
        Navigator.of(context).pushReplacementNamed('/login');
      },
      child: const Text(
        'Vous avez déjà un compte ? Connectez-vous ici',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: <Widget>[
        const Text(
          'Ou continuer avec',
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildSocialButton(
              icon: Icons.facebook,
              label: 'Facebook',
              backgroundColor: const Color(0xFF1877F2),
              onPressed: _signInWithFacebook,
            ),
            const SizedBox(width: 20),
            _buildSocialButton(
              icon: Icons.email,
              label: 'Google',
              backgroundColor: Colors.white,
              iconColor: Colors.red,
              textColor: Colors.black,
              onPressed: _signInWithGoogle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(150, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      icon: Icon(icon, color: iconColor ?? Colors.white),
      label: Text(label, style: TextStyle(color: textColor ?? Colors.white)),
    );
  }

  Future<void> _signInWithGoogle() async {
    try {
      // Google sign-in logic here
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion avec Google.';
      });
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      // Facebook sign-in logic here
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur de connexion avec Facebook.';
      });
    }
  }
}