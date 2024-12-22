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
      print("Error while fetching categories: $e");
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

  /// Function to add an item to Firebase Realtime Database
  Future<void> _addItem() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Generate a new unique key for the item
        DatabaseReference newItemRef = _database.child('clothingItems').push();

        // Add the item to the database
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
          const SnackBar(content: Text("Item added successfully!")),
        );

        // Reset the form
        _formKey.currentState!.reset();
        _clearControllers();
      } catch (e) {
        print("Error while adding item: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error adding item: $e")),
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
      appBar: AppBar(
        title: const Text('Add Clothing Item'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.blue[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),

              // Category (Dynamic Dropdown)
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: TextStyle(color: Colors.blue[800]),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                      ),
                      value: _selectedCategory,
                      hint: const Text('Select a category'),
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
                      validator: (value) =>
                          value == null ? 'Please select a category' : null,
                    ),
              const SizedBox(height: 16),

              // Size
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(
                  labelText: 'Size',
                  labelStyle: TextStyle(color: Colors.blue[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a size'
                    : null,
              ),
              const SizedBox(height: 16),

              // Brand
              TextFormField(
                controller: _brandController,
                decoration: InputDecoration(
                  labelText: 'Brand',
                  labelStyle: TextStyle(color: Colors.blue[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a brand'
                    : null,
              ),
              const SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Colors.blue[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Enter a valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(
                  labelText: 'Image URL',
                  labelStyle: TextStyle(color: Colors.blue[800]),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  // Optional: Add URL validation
                  if (!value.startsWith('http') && !value.startsWith('https')) {
                    return 'Enter a valid URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _addItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Submit'),
              ),

              // Image Preview if URL is provided
              if (_imageUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.network(
                    _imageUrlController.text,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text('Unable to load image'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
