import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:naji_app/services/cart_service.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  final DatabaseReference database =
      FirebaseDatabase.instance.ref(); // Référence à la bd Firebase
  Map<String, dynamic>? itemData; // stocker les données de l'article

  @override
  void initState() {
    super.initState();
    _loadItemData(); // la fctt pour charger les données de l'articlequand la page est initialisée
  }

  // charger les données de Firebase
  Future<void> _loadItemData() async {
    final snapshot = await database
        .child('clothingItems/${widget.itemId}')
        .get(); // Récupérer les données de l'article avec l'ID spécifique
    if (snapshot.exists) {
      setState(() {
        itemData = Map<String, dynamic>.from(
            snapshot.value as Map); // Si les données existent, les stocker
      });
    }
  }

  // ajout l'article au panier
  void _addToCart(BuildContext context) {
    if (itemData != null) {
      CartService.addItem(itemData!); // Ajouter l'article au panier
      ScaffoldMessenger.of(context).showSnackBar(
        // Afficher un message de confirmation que l'article a été ajouté
        const SnackBar(content: Text('Article ajouté au panier!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (itemData == null) {
      // Si les données de l'article ne sont pas encore chargées, afficher un indicateur de chargement
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(itemData!['title'] ??
            'Détail article'), // Afficher le titre de l'article
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16.0), // Ajouter de l'espace autour du contenu
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Alignement du texte à gauche
          children: [
            // Afficher l'image de l'article
            Image.network(
              itemData![
                  'imageUrl'], // Utilisation de l'URL de l'image de l'article
              fit: BoxFit.cover, // Adapter l'image à l'espace disponible
              errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported,
                  size:
                      100), // Afficher une icône si l'image ne peut pas être chargée
            ),
            const SizedBox(
                height:
                    16.0), // Ajouter un espacement entre l'image et le texte
            // Afficher les informations sur l'article (catégorie, taille, marque, prix)
            Text('Catégorie: ${itemData!['category']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8.0),
            Text('Taille: ${itemData!['size']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8.0),
            Text('Marque: ${itemData!['brand']}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8.0),
            Text('Prix: ${itemData!['price']} MAD',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16.0), // Espacement avant les boutons
            // Les boutons de retour et d'ajout au panier
            Row(
              mainAxisAlignment: MainAxisAlignment
                  .spaceBetween, // Espacer les boutons de chaque côté
              children: [
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context), // Retourner à la page précédente
                  child: const Text('Retour'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _addToCart(context), // Ajouter l'article au panier
                  child: const Text('Ajouter au panier'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
