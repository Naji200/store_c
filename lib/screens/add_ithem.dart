import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

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

  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _sizeController.dispose();
    _brandController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  /// Fonction pour sélectionner une image
  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image sélectionnée avec succès !")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Aucune image sélectionnée.")),
        );
      }
    } catch (e) {
      print("Erreur lors de la sélection de l'image : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Erreur lors de la sélection de l'image.")),
      );
    }
  }

  /// Fonction pour ajouter un vêtement dans Firestore
  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('clothingItems').add({
          'title': _titleController.text,
          'size': _sizeController.text,
          'brand': _brandController.text,
          'price': double.parse(_priceController.text),
          'imageUrl':
              '', // Remplacez par la logique de téléchargement d'image si nécessaire
          'timestamp': FieldValue.serverTimestamp(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vêtement ajouté avec succès !")),
        );

        // Réinitialiser le formulaire
        _formKey.currentState!.reset();
        setState(() {
          _selectedImage = null;
        });
      } catch (e) {
        print("Erreur lors de l'ajout : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'ajout du vêtement.")),
        );
      }
    }
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

              // Bouton pour sélectionner une image
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Sélectionner une image'),
              ),
              const SizedBox(height: 16),

              // Image sélectionnée
              if (_selectedImage != null)
                Column(
                  children: [
                    Image.file(_selectedImage!, width: 150, height: 150),
                  ],
                ),
              const SizedBox(height: 20),

              // Bouton pour valider l'ajout
              ElevatedButton(
                onPressed: _addItem,
                child: const Text('Valider'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
