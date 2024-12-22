import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire
  final _emailController = TextEditingController(); // Contrôleur pour l'email
  final _passwordController =
      TextEditingController(); // Contrôleur pour le mot de passe
  bool _isLoading = false; // Variable pour gérer l'état de chargement

  @override
  void initState() {
    super.initState();
    // Vérifier si l'utilisateur est déjà connecté
    _checkIfUserIsLoggedIn();
  }

  // Fonction pour vérifier si l'utilisateur est déjà connecté
  Future<void> _checkIfUserIsLoggedIn() async {
    final user = FirebaseAuth
        .instance.currentUser; // Récupérer l'utilisateur actuellement connecté
    if (user != null) {
      // Si l'utilisateur est connecté
      // Rediriger directement vers la page d'accueil
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  // Fonction pour effectuer la connexion
  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      // Vérifier la validité du formulaire
      setState(() =>
          _isLoading = true); // Afficher le chargement pendant la connexion

      try {
        print(
            'Tentative de connexion avec: ${_emailController.text}'); // Message de débogage

        // Connexion de l'utilisateur avec son email et son mot de passe
        final userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        print(
            'Connexion réussie: ${userCredential.user?.uid}'); // Message de débogage pour la réussite

        // Affichage d'un message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connexion réussie!')),
        );

        // Rediriger vers la page d'accueil après une connexion réussie
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        print(
            'Erreur Firebase Auth: ${e.code}'); // Message de débogage pour l'erreur
        String message;
        if (e.code == 'user-not-found') {
          // Cas où l'utilisateur n'est pas trouvé
          message = 'Aucun utilisateur trouvé avec cet email.';
        } else if (e.code == 'wrong-password') {
          // Cas où le mot de passe est incorrect
          message = 'Mot de passe incorrect.';
        } else {
          message = 'Erreur de connexion: ${e.code}'; // Autres erreurs
        }

        // Affichage du message d'erreur à l'utilisateur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } finally {
        setState(() => _isLoading =
            false); // Masquer le chargement après la tentative de connexion
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Syna World'), // Titre de la barre d'applications
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Marge autour du formulaire
        child: Form(
          key: _formKey, // Clé pour le formulaire
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Centrer les éléments
            children: [
              // Champ pour l'email
              TextFormField(
                controller: _emailController, // Contrôleur pour l'email
                decoration: const InputDecoration(
                  labelText: 'Email', // Label du champ
                  border: OutlineInputBorder(), // Bordure du champ
                ),
                validator: (value) {
                  // Validation de l'email
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre email'; // Message d'erreur si vide
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16), // Espacement entre les champs
              // Champ pour le mot de passe
              TextFormField(
                controller:
                    _passwordController, // Contrôleur pour le mot de passe
                obscureText: true, // Masquer le mot de passe
                decoration: const InputDecoration(
                  labelText: 'Mot de passe', // Label du champ
                  border: OutlineInputBorder(), // Bordure du champ
                ),
                validator: (value) {
                  // Validation du mot de passe
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre mot de passe'; // Message d'erreur si vide
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24), // Espacement avant le bouton
              // Bouton de connexion ou indicateur de chargement
              _isLoading
                  ? const CircularProgressIndicator() // Afficher un cercle de chargement
                  : ElevatedButton(
                      onPressed: _signIn, // Appeler la fonction de connexion
                      child: const Text('Se connecter'), // Texte du bouton
                    ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose(); // Libérer le contrôleur de l'email
    _passwordController.dispose(); // Libérer le contrôleur du mot de passe
    super.dispose();
  }
}
