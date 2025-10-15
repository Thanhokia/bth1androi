import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Product {
  String name;
  double price;
  String description;
  List<String> imagePaths;
  String category;
  bool hasDiscount;
  DateTime? discountTime;

  Product({
    required this.name,
    required this.price,
    required this.description,
    required this.imagePaths,
    required this.category,
    required this.hasDiscount,
    this.discountTime,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'description': description,
        'imagePaths': imagePaths,
        'category': category,
        'hasDiscount': hasDiscount,
        'discountTime': discountTime?.toIso8601String(),
      };

  static Product fromJson(Map<String, dynamic> json) => Product(
        name: json['name'],
        price: json['price'],
        description: json['description'],
        imagePaths: List<String>.from(json['imagePaths']),
        category: json['category'],
        hasDiscount: json['hasDiscount'],
        discountTime: json['discountTime'] != null
            ? DateTime.parse(json['discountTime'])
            : null,
      );
}

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('products');
    if (data != null) {
      final list = json.decode(data) as List;
      setState(() {
        products = list.map((e) => Product.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = json.encode(products.map((e) => e.toJson()).toList());
    await prefs.setString('products', data);
  }

  void _addOrEditProduct([Product? product, int? index]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditProductScreen(product: product),
      ),
    );
    if (result is Product) {
      setState(() {
        if (index != null) {
          products[index] = result;
        } else {
          products.add(result);
        }
      });
      await _saveProducts();
    }
  }

  void _viewProduct(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (product.imagePaths.isNotEmpty)
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: product.imagePaths
                      .map((path) => Padding(
                            padding: const EdgeInsets.all(4),
                            child: Image.file(File(path), width: 60, height: 60, fit: BoxFit.cover),
                          ))
                      .toList(),
                ),
              ),
            Text('Price: ${product.price}'),
            Text('Category: ${product.category}'),
            Text('Description: ${product.description}'),
            if (product.hasDiscount && product.discountTime != null)
              Text('Discount until: ${product.discountTime!.toLocal()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditProduct(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            leading: product.imagePaths.isNotEmpty
                ? Image.file(File(product.imagePaths.first), width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.image),
            title: Text(product.name),
            subtitle: Text('Price: ${product.price}\nCategory: ${product.category}'),
            onTap: () => _viewProduct(product),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _addOrEditProduct(product, index),
            ),
          );
        },
      ),
    );
  }
}

class AddEditProductScreen extends StatefulWidget {
  final Product? product;
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  List<XFile> _images = [];
  List<String> _savedImagePaths = [];
  String? _selectedCategory;
  bool _discountOffer = false;
  DateTime? _discountTime;

  final List<String> _categories = ['Electronics', 'Fashion', 'Books', 'Home'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price.toString();
      _descController.text = widget.product!.description;
      _savedImagePaths = List<String>.from(widget.product!.imagePaths);
      _selectedCategory = widget.product!.category;
      _discountOffer = widget.product!.hasDiscount;
      _discountTime = widget.product!.discountTime;
    }
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null) {
      setState(() {
        _images.addAll(picked);
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _images.add(photo);
      });
    }
  }

  Future<List<String>> _saveImagesLocally(List<XFile> images) async {
    final dir = await getApplicationDocumentsDirectory();
    List<String> paths = [];
    for (var img in images) {
      final file = File(img.path);
      final newPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_${img.name}';
      await file.copy(newPath);
      paths.add(newPath);
    }
    return paths;
  }

  Future<void> _pickDateTime() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _discountTime = picked;
      });
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      List<String> imagePaths = List<String>.from(_savedImagePaths);
      if (_images.isNotEmpty) {
        final saved = await _saveImagesLocally(_images);
        imagePaths.addAll(saved);
      }
      final product = Product(
        name: _nameController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        description: _descController.text,
        imagePaths: imagePaths,
        category: _selectedCategory ?? '',
        hasDiscount: _discountOffer,
        discountTime: _discountOffer ? _discountTime : null,
      );
      Navigator.pop(context, product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add/Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProduct,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter product name' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price', prefixText: '  '),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (v) => v == null || v.isEmpty ? 'Enter price' : null,
              ),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.image),
                    label: const Text('Upload Images'),
                    onPressed: _pickImages,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo'),
                    onPressed: _takePhoto,
                  ),
                ],
              ),
              SizedBox(
                height: 80,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ..._savedImagePaths.map((path) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.file(File(path), width: 60, height: 60, fit: BoxFit.cover),
                        )),
                    ..._images.map((img) => Padding(
                          padding: const EdgeInsets.all(4),
                          child: Image.file(File(img.path), width: 60, height: 60, fit: BoxFit.cover),
                        )),
                  ],
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Category'),
                value: _selectedCategory,
                items: _categories.map((cat) =>
                    DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (v) => v == null ? 'Select category' : null,
              ),
              SwitchListTile(
                title: const Text('Discount Offer'),
                value: _discountOffer,
                onChanged: (val) => setState(() => _discountOffer = val),
              ),
              if (_discountOffer)
                ListTile(
                  title: Text(_discountTime == null
                      ? 'Select Discount Time'
                      : 'Discount Time: ${_discountTime!.toLocal()}'.split(' ')[0]),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _pickDateTime,
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveProduct,
                    child: const Text('Save Product'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

