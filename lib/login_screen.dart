import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';// Assurez-vous d'importer ServicePage ici
import 'package:soutenance2/home_page.dart';
// Importez le fichier service_page.dart

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Arrière-plan dégradé avec moins de densité
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green.shade300, Colors.green.shade50], // Couleurs du dégradé ajustées
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          // Image circulaire en haut
          Positioned(
            top: size.height * 0.1, // Ajuste la position de l'image
            left: size.width * 0.2,
            child: Container(
              width: size.width * 0.6, // Redimensionne l'image
              height: size.width * 0.6, // Redimensionne l'image
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white, // Couleur de fond du cercle
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4), // Ombre plus dense pour l'arrière
                    spreadRadius: 4,
                    blurRadius: 16,
                    offset: const Offset(0, 8), // Décalage de l'ombre
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: size.width * 0.55,
                  height: size.width * 0.55,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage('lib/assets/chevre.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Contenu principal ajusté juste en dessous de l'image
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: <Widget>[
                  SizedBox(height: size.height * 0.4), // Ajuste la position en fonction de la hauteur de l'image
                  _buildLoginForm(),
                  const SizedBox(height: 20.0), // Espacement réduit avant le bouton
                  _buildSignInWithGoogleButton(),
                  const SizedBox(height: 20.0), // Espacement entre le bouton et le lien de création de compte
                  _buildSignUpLink(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir une adresse email valide.';
              }
              return null;
            },
          ),
          const SizedBox(height: 12.0), // Réduit l'espace entre les champs
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.0),
                borderSide: const BorderSide(color: Colors.black),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              filled: true,
              fillColor: Colors.white,
              labelStyle: const TextStyle(color: Colors.black),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez saisir un mot de passe.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0), // Espacement réduit avant le bouton
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signInWithEmailAndPassword();
                    }
                  },
                  child: const Text('Se connecter', style: TextStyle(color: Colors.white)),
                ),
        ],
      ),
    );
  }

  Widget _buildSignInWithGoogleButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      icon: const Icon(FontAwesomeIcons.google, color: Colors.blue),
      onPressed: _signInWithGoogle,
      label: const Text('Se connecter avec Google', style: TextStyle(color: Colors.black)),
    );
  }

  Widget _buildSignUpLink(BuildContext context) {
    return TextButton(
      onPressed: () {
        Navigator.pushNamed(context, '/register');
      },
      child: const Text(
        'Créer un compte',
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  Future<void> _signInWithEmailAndPassword() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = userCredential.user;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('nom')) {
          String name = doc.get('nom');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AnimalCareApp(name: name), // Remplacez HomePage par ServicePage
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L\'utilisateur n\'a pas de champ "nom"')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // L'utilisateur a annulé la connexion
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data()!.containsKey('nom')) {
          String name = doc.get('nom');
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => AnimalCareApp(name: name), // Remplacez HomePage par ServicePage
              ),
            );
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('L\'utilisateur n\'a pas de champ "nom"')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de connexion: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
