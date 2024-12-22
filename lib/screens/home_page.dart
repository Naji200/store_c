import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:naji_app/screens/itemdetails.dart';
import 'bar.dart'; // Importer le widget Bar

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<Map<String, dynamic>> _clothingItems = [];
  int _currentIndex = 0; // Pour suivre la page active

  @override
  void initState() {
    super.initState();
    _fetchClothingItems();
  }

  void _fetchClothingItems() async {
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
      });
    }
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Vous pouvez gérer la navigation en fonction de l'index sélectionné ici
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
      ),
      body: _clothingItems.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _clothingItems.length,
              itemBuilder: (context, index) {
                final item = _clothingItems[index];
                return GestureDetector(
                  // Redirection vers la page de détails de l'article
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
                    child: ListTile(
                      leading: Image.network(
                        item['imageUrl'] ?? '',
                        fit: BoxFit.cover,
                        width: 50,
                        height: 50,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.image_not_supported),
                      ),
                      title: Text(item['title'] ?? 'No Title'),
                      subtitle: Text(
                          'Taille: ${item['size'] ?? 'N/A'}\nPrix: ${item['price'] ?? 'N/A'} MAD'),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: Bar(
        // Utiliser le widget Bar
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }
}
