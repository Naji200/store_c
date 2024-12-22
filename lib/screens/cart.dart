import 'package:flutter/material.dart';
import 'package:naji_app/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double calculateTotal() {
    return CartService.cartItems.fold(0,
        (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0));
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartService.cartItems;
    final total = calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text("Panier")),
      body: Column(
        children: [
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text("Votre panier est vide."))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        child: ListTile(
                          leading: item['imageUrl'] != null &&
                                  item['imageUrl'].isNotEmpty
                              ? Image.network(
                                  item['imageUrl'],
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 50,
                                  height: 50,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          title: Text(item['title']),
                          subtitle: Text(
                            "${item['price']} MAD\nTaille: ${item['size']}\nMarque: ${item['brand']}",
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                CartService.removeItem(index);
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Total: ${total.toStringAsFixed(2)} MAD',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
