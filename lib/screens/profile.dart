// Imports
import 'package:flutter/material.dart'; // composants d'ui
import 'package:firebase_auth/firebase_auth.dart'; // authentification Firebase
import 'package:flutter/services.dart'; // Pour valider et formater les entrées user
import 'package:firebase_database/firebase_database.dart'; // BD Firebase
import 'package:naji_app/screens/login_page.dart';

// La page de profil de l'user
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key}); // Const

  @override
  _ProfilePageState createState() =>
      _ProfilePageState(); // Création de l'état de la page
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire
  final DatabaseReference _database = FirebaseDatabase.instance
      .ref(); // Référence à la base de données Firebase
  final TextEditingController _loginController =
      TextEditingController(); // Contrôleur pour le champ du login
  final TextEditingController _passwordController =
      TextEditingController(); // Contrôleur pour le mot de passe
  final TextEditingController _birthdayController =
      TextEditingController(); // Contrôleur pour la date de naissance
  final TextEditingController _addressController =
      TextEditingController(); // Contrôleur pour l'adresse
  final TextEditingController _postalCodeController =
      TextEditingController(); // Contrôleur pour le code postal
  final TextEditingController _cityController =
      TextEditingController(); // Contrôleur pour la ville
  bool _isLoading = false; // Variable pour savoir si on charge des données

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Charger le profil de l'user quand la page s'affiche
  }

  // Fonction pour charger les informations de l'user depuis Firebase
  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true); // Afficher un indicateur de chargement
    try {
      final user =
          FirebaseAuth.instance.currentUser; // Récupérer l'user connecté
      if (user != null) {
        // Si l'user est bien connecté
        final snapshot = await _database
            .child('users/${user.uid}')
            .get(); // Récupérer les données de l'user depuis Firebase
        if (snapshot.exists) {
          // Si les données existent
          final data = Map<String, dynamic>.from(
              snapshot.value as Map); // Convertir les données en Map
          setState(() {
            // infos user
            _loginController.text = user.email ?? ''; //login
            _passwordController.text = ''; // mdp masque
            _birthdayController.text =
                data['birthday'] ?? ''; //date de naissance
            _addressController.text = data['address'] ?? ''; // l'adresse
            _postalCodeController.text = data['postalCode'] ?? ''; // ode postal
            _cityController.text = data['city'] ?? ''; //ville
          });
        }
      }
    } catch (e) {
      debugPrint(
          'Error loading profile: $e'); // Afficher une erreur si le chargement échoue
    } finally {
      setState(() => _isLoading =
          false); // Cacher l'indicateur de chargement une fois terminé
    }
  }

  // fct pour sauvegarder les modifs du profil dans Firebase
  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Vérifier si le formulaire est valide
      setState(() => _isLoading = true); // Afficher l'indicateur de chargement
      try {
        final user =
            FirebaseAuth.instance.currentUser; // Récupérer l'user connecté
        if (user != null) {
          // Mettre à jour les informations dans Firebase
          await _database.child('users/${user.uid}').update({
            'birthday':
                _birthdayController.text, // Mettre à jour la date de naissance
            'address': _addressController.text, // Mettre à jour l'adresse
            'postalCode':
                _postalCodeController.text, // Mettre à jour le code postal
            'city': _cityController.text, // Mettre à jour la ville
          });

          // message de succès
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil mis à jour avec succès')),
          );
        }
      } catch (e) {
        // else il yaa message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour')),
        );
      } finally {
        setState(() => _isLoading =
            false); // Cacher l'indicateur de chargement après la mise à jour
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // déconnexion
            onPressed: () async {
              // Déconnexion & redirection page de login
              await FirebaseAuth.instance.signOut();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Afficher un indicateur de chargement si _isLoading est true
          : Padding(
              padding:
                  const EdgeInsets.all(16.0), // Espacement autour des champs
              child: Form(
                key: _formKey, // Lier le formulaire à la clé
                child: ListView(
                  children: [
                    // email (login)
                    TextFormField(
                      controller: _loginController,
                      readOnly: true, // readonly non modifiable
                      decoration: const InputDecoration(labelText: 'Login'),
                    ),
                    //  le mot de passe (masqué)
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true, // Masquer mdp
                      readOnly: true, //  non modifiable
                      decoration:
                          const InputDecoration(labelText: 'Mot de passe'),
                    ),
                    // date de naissance
                    TextFormField(
                      controller: _birthdayController,
                      decoration:
                          const InputDecoration(labelText: 'Anniversaire'),
                    ),
                    // adresse
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(labelText: 'Adresse'),
                    ),
                    // Champ pour le code postal (avec validation numérique)
                    TextFormField(
                      controller: _postalCodeController,
                      keyboardType: TextInputType.number, // 100% chiffres
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ], // seulement les chiffres
                      decoration:
                          const InputDecoration(labelText: 'Code postal'),
                    ),
                    // ville
                    TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Ville'),
                    ),
                    const SizedBox(height: 20), // Espacement avant le bouton
                    // save button
                    ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Valider'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    // Libérer les ressources des contrôleurs de texte lorsque la page est détruite
    _loginController.dispose();
    _passwordController.dispose();
    _birthdayController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
