import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ItemDetail extends StatefulWidget {
  const ItemDetail({super.key});

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _sizeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageUrlController =
      TextEditingController(); // New controller for image URL
  final TextEditingController _categoryController =
      TextEditingController(); // New controller for category
  final TextEditingController _descriptionController =
      TextEditingController(); // New controller for description

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Variables for categories
  List<String> _categories = [];
  String? _selectedCategory;
  bool _isLoadingCategories = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  // Fetch categories from Firebase
  void _fetchCategories() async {
    try {
      final snapshot = await _database.child('categories/clothing').get();

      if (snapshot.exists) {
        final List<dynamic> categoriesList = snapshot.value as List<dynamic>;

        setState(() {
          _categories =
              categoriesList.map((category) => category.toString()).toList();
          _isLoadingCategories = false;
        });
      } else {
        setState(() {
          _categories = [];
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des catégories : $e");
      setState(() {
        _categories = [];
        _isLoadingCategories = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Fonction pour ajouter un vêtement dans Firebase Realtime Database
  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Générer une nouvelle clé unique pour l'article
        DatabaseReference newItemRef = _database.child('clothingItems').push();

        // Ajouter l'article à la base de données
        await newItemRef.set({
          'title': _titleController.text,
          'size': _sizeController.text,
          'brand': _brandController.text,
          'price': double.parse(_priceController.text),
          'imageUrl': _imageUrlController.text,
          'category': _categoryController.text,
          'description': _descriptionController.text,
          'timestamp': ServerValue.timestamp,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vêtement ajouté avec succès !")),
        );

        // Réinitialiser le formulaire
        _formKey.currentState!.reset();
        _clearControllers();
      } catch (e) {
        print("Erreur lors de l'ajout : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout du vêtement : $e")),
        );
      }
    }
  }

  void _clearControllers() {
    _titleController.clear();
    _sizeController.clear();
    _brandController.clear();
    _priceController.clear();
    _imageUrlController.clear();
    _categoryController.clear();
    _descriptionController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un vêtement')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Titre
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titre'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer un titre'
                    : null,
              ),
              const SizedBox(height: 16),

              // Catégorie
              // Catégorie (Dropdown dynamique)
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                      value: _selectedCategory,
                      hint: const Text('Sélectionnez une catégorie'),
                      items: _categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                      validator: (value) => value == null
                          ? 'Veuillez sélectionner une catégorie'
                          : null,
                    ),
              const SizedBox(height: 16),

              // Taille
              TextFormField(
                controller: _sizeController,
                decoration: const InputDecoration(labelText: 'Taille'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer une taille'
                    : null,
              ),
              const SizedBox(height: 16),

              // Marque
              TextFormField(
                controller: _brandController,
                decoration: const InputDecoration(labelText: 'Marque'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Veuillez entrer une marque'
                    : null,
              ),
              const SizedBox(height: 16),

              // Prix
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Veuillez entrer un prix';
                  if (double.tryParse(value) == null)
                    return 'Entrez un prix valide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL de l'image
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL de l\'image'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Veuillez entrer une URL d\'image';
                  // Optional: Add URL validation
                  if (!value.startsWith('http') && !value.startsWith('https')) {
                    return 'Entrez une URL valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bouton pour valider l'ajout
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Valider'),
              ),

              // Aperçu de l'image si une URL est saisie
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.network(
                    _imageUrlController.text,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Impossible de charger l\'image'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
