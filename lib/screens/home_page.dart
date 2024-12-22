import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:naji_app/screens/add_ithem.dart';
import 'package:naji_app/screens/itemdetails.dart';
import 'package:naji_app/services/cart_service.dart';

import 'bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _clothingItems = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  Map<String, dynamic>? itemData;

  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
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

    // Add a listener to update items in real-time
    _database.child('clothingItems').onChildAdded.listen((event) {
      if (mounted) {
        setState(() {
          final newItem =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          newItem['id'] = event.snapshot.key;
          _clothingItems.add(newItem);
        });
      }
    });

    // Listener for item changes
    _database.child('clothingItems').onChildChanged.listen((event) {
      if (mounted) {
        setState(() {
          final changedItem =
              Map<String, dynamic>.from(event.snapshot.value as Map);
          changedItem['id'] = event.snapshot.key;

          int index = _clothingItems
              .indexWhere((item) => item['id'] == event.snapshot.key);
          if (index != -1) {
            _clothingItems[index] = changedItem;
          }
        });
      }
    });

    // Listener for item removals
    _database.child('clothingItems').onChildRemoved.listen((event) {
      if (mounted) {
        setState(() {
          _clothingItems
              .removeWhere((item) => item['id'] == event.snapshot.key);
        });
      }
    });
  }

  void _fetchClothingItems() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final snapshot = await _database.child('clothingItems').get();

      if (snapshot.exists) {
        final items = Map<String, dynamic>.from(snapshot.value as Map);

        setState(() {
          _clothingItems = items.entries.map((entry) {
            return {
              'id': entry.key,
              ...Map<String, dynamic>.from(entry.value as Map),
            };
          }).toList();

          _isLoading = false;
        });
      } else {
        setState(() {
          _clothingItems = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erreur lors de la récupération des articles : $e");
      setState(() {
        _clothingItems = [];
        _isLoading = false;
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Gérer la navigation si nécessaire
    if (index == 1) {
      // Naviguer vers la page Panier
    } else if (index == 2) {
      // Naviguer vers la page Profil
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Life of Syn'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchClothingItems,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _clothingItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Aucun article disponible"),
                      ElevatedButton(
                        onPressed: _fetchClothingItems,
                        child: const Text("Actualiser"),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _clothingItems.length,
                  itemBuilder: (context, index) {
                    final item = _clothingItems[index];
                    return GestureDetector(
                      onTap: () {
                        print('Item clicked: ${item['title']}');
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailPage(itemId: item['id']),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.all(8.0),
                        child: Stack(
                          children: [
                            ListTile(
                              leading: Image.network(
                                item['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                width: 50,
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.image_not_supported),
                              ),
                              title: Text(item['title'] ?? 'No Title'),
                              subtitle:
                                  Text('Taille: ${item['size'] ?? 'N/A'}\n'
                                      'Prix: ${item['price'] ?? 'N/A'} MAD'),
                            ),
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () =>
                                    _addToCart(context), // Add to cart action
                                icon: const Icon(Icons.shopping_cart,
                                    color: Colors.blue),
                                tooltip: 'Ajouter au panier',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Bar(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ItemDetail()),
          ).then((_) =>
              _fetchClothingItems()); // Refresh after returning from add item page
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    // Optional: Cancel any listeners if needed
    super.dispose();
  }
}
