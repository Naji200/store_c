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

  void _addToCart(BuildContext context, Map<String, dynamic> item) {
    CartService.addItem(item);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Article ajouté au panier!')),
    );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Naji App', style: TextStyle(fontSize: 24)),
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
                      const Text(
                        "Aucun article disponible",
                        style: TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchClothingItems,
                        child: const Text("Actualiser"),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _clothingItems.length,
                  itemBuilder: (context, index) {
                    final item = _clothingItems[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemDetailPage(itemId: item['id']),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12.0),
                                  topRight: Radius.circular(12.0),
                                ),
                                child: Image.network(
                                  item['imageUrl'] ?? '',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'No Title',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Prix: ${item['price']} MAD',
                                    style: const TextStyle(
                                      color: Colors.blueGrey,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: IconButton(
                                onPressed: () => _addToCart(context, item),
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  color: Colors.blue,
                                ),
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
          ).then((_) => _fetchClothingItems());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
