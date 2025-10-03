// lib/product_management_screen.dart
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart'; // Thêm vào pubspec.yaml: image_picker: ^1.0.4
// Lưu ý: Chạy 'flutter pub get' sau khi thêm package. Để mock nếu chưa, comment phần pick.

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> imagePaths; // Đường dẫn ảnh lưu local
  final String category;
  final bool hasDiscount;
  final DateTime? discountTime;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imagePaths,
    required this.category,
    this.hasDiscount = false,
    this.discountTime,
  });

  // To Map for storage (mock)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'imagePaths': imagePaths,
      'category': category,
      'hasDiscount': hasDiscount,
      'discountTime': discountTime?.toIso8601String(),
    };
  }

  // From Map
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'].toDouble(),
      description: map['description'],
      imagePaths: List<String>.from(map['imagePaths']),
      category: map['category'],
      hasDiscount: map['hasDiscount'],
      discountTime: map['discountTime'] != null ? DateTime.parse(map['discountTime']) : null,
    );
  }
}

// Static list for mock local storage (thực tế: dùng shared_preferences + json hoặc sqflite)
class ProductStorage {
  static List<Product> products = [];
  static String generateId() => DateTime.now().millisecondsSinceEpoch.toString();
}

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  @override
  Widget build(BuildContext context) {
    final products = ProductStorage.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách sản phẩm'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToAddEdit(null),
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('Chưa có sản phẩm nào'))
          : ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: product.imagePaths.isNotEmpty
                  ? Image.file(
                File(product.imagePaths.first),
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              )
                  : const Icon(Icons.image, size: 50),
              title: Text(product.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Giá: ${product.price} VND'),
                  Text('Danh mục: ${product.category}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _navigateToAddEdit(product),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        ProductStorage.products.removeAt(index);
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã xóa sản phẩm')),
                      );
                    },
                  ),
                ],
              ),
              onTap: () => _showProductDetails(product),
            ),
          );
        },
      ),
    );
  }

  void _navigateToAddEdit(Product? product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductAddEditPage(product: product),
      ),
    ).then((_) => setState(() {})); // Refresh list sau khi lưu
  }

  void _showProductDetails(Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giá: ${product.price} VND'),
              Text('Mô tả: ${product.description}'),
              Text('Danh mục: ${product.category}'),
              if (product.hasDiscount) ...[
                Text('Ưu đãi: Có'),
                Text('Thời gian: ${product.discountTime?.toLocal().toString()}'),
              ],
              if (product.imagePaths.isNotEmpty) ...[
                const Text('Hình ảnh:'),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: product.imagePaths.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.all(4),
                      child: Image.file(File(product.imagePaths[i]), height: 100, fit: BoxFit.cover),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }
}

class ProductAddEditPage extends StatefulWidget {
  final Product? product;

  const ProductAddEditPage({super.key, this.product});

  @override
  State<ProductAddEditPage> createState() => _ProductAddEditPageState();
}

class _ProductAddEditPageState extends State<ProductAddEditPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _selectedCategory = 'Điện thoại';
  bool _hasDiscount = false;
  DateTime? _discountTime;
  List<XFile> _selectedImages = [];
  List<String> _imagePaths = [];

  final List<String> _categories = ['Điện thoại', 'Laptop', 'Máy ảnh', 'Phụ kiện'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final p = widget.product!;
      _nameController.text = p.name;
      _priceController.text = p.price.toString();
      _descriptionController.text = p.description;
      _selectedCategory = p.category;
      _hasDiscount = p.hasDiscount;
      _discountTime = p.discountTime;
      _imagePaths = p.imagePaths;
      // Load images from paths if edit
    }
  }

  Future<void> _pickImages() async {
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null && images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  Future<void> _pickDateTime() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );
      if (time != null) {
        final fullDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() {
          _discountTime = fullDateTime;
        });
      }
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Lưu ảnh vào local storage
    final directory = await getApplicationDocumentsDirectory();
    List<String> savedPaths = [];
    for (var image in _selectedImages) {
      final file = File(image.path);
      final newPath = '${directory.path}/product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await file.copy(newPath);
      savedPaths.add(newPath);
    }
    _imagePaths.addAll(savedPaths);

    final product = Product(
      id: widget.product?.id ?? ProductStorage.generateId(),
      name: _nameController.text,
      price: double.parse(_priceController.text),
      description: _descriptionController.text,
      imagePaths: _imagePaths,
      category: _selectedCategory!,
      hasDiscount: _hasDiscount,
      discountTime: _discountTime,
    );

    // Lưu vào mock storage
    final index = ProductStorage.products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      ProductStorage.products[index] = product;
    } else {
      ProductStorage.products.add(product);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(widget.product == null ? 'Thêm sản phẩm thành công!' : 'Cập nhật thành công!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Thêm sản phẩm' : 'Chỉnh sửa sản phẩm'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                  validator: (value) => value!.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Giá (VND)'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value!.isEmpty) return 'Bắt buộc';
                    if (double.tryParse(value) == null) return 'Phải là số';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Mô tả'),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Bắt buộc' : null,
                ),
                const SizedBox(height: 16),
                const Text('Hình ảnh sản phẩm'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _pickImages,
                  child: const Text('Chọn ảnh từ thư viện'),
                ),
                const SizedBox(height: 8),
                if (_selectedImages.isNotEmpty)
                  SizedBox(
                    height: 100,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) => Image.file(
                        File(_selectedImages[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Danh mục'),
                  items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Ưu đãi:'),
                    Switch(
                      value: _hasDiscount,
                      onChanged: (value) => setState(() => _hasDiscount = value),
                    ),
                  ],
                ),
                if (_hasDiscount) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _pickDateTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Thời gian khuyến mãi'),
                      child: Text(_discountTime == null ? 'Chọn ngày giờ' : _discountTime!.toLocal().toString()),
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('Lưu', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}