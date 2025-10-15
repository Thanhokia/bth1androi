import 'dart:io';
import 'package:flutter/material.dart';
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

class ProductFilterScreen extends StatefulWidget {
  const ProductFilterScreen({super.key});

  @override
  State<ProductFilterScreen> createState() => _ProductFilterScreenState();
}

class _ProductFilterScreenState extends State<ProductFilterScreen> {
  final _fromPriceController = TextEditingController();
  final _toPriceController = TextEditingController();
  List<String> _categories = ['Electronics', 'Fashion', 'Books', 'Home'];
  List<String> _selectedCategories = [];
  String _sortOrder = 'Mới nhất';
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  int _currentPage = 1;
  final int _pageSize = 10;

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
        _allProducts = list.map((e) => Product.fromJson(e)).toList();
        _filteredProducts = List<Product>.from(_allProducts);
      });
    }
  }

  void _applyFilter() {
    double? fromPrice = double.tryParse(_fromPriceController.text);
    double? toPrice = double.tryParse(_toPriceController.text);
    List<Product> filtered = _allProducts.where((p) {
      bool priceOk = true;
      if (fromPrice != null) priceOk &= p.price >= fromPrice;
      if (toPrice != null) priceOk &= p.price <= toPrice;
      bool categoryOk = _selectedCategories.isEmpty || _selectedCategories.contains(p.category);
      return priceOk && categoryOk;
    }).toList();
    if (_sortOrder == 'Giá tăng') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOrder == 'Giá giảm') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortOrder == 'Mới nhất') {
      filtered.sort((a, b) => (b.discountTime ?? DateTime(2000)).compareTo(a.discountTime ?? DateTime(2000)));
    }
    setState(() {
      _filteredProducts = filtered;
      _currentPage = 1;
    });
  }

  void _resetFilter() {
    setState(() {
      _fromPriceController.clear();
      _toPriceController.clear();
      _selectedCategories.clear();
      _sortOrder = 'Mới nhất';
      _filteredProducts = List<Product>.from(_allProducts);
      _currentPage = 1;
    });
  }

  List<Product> _getPageProducts() {
    int start = (_currentPage - 1) * _pageSize;
    int end = (_currentPage * _pageSize).clamp(0, _filteredProducts.length);
    return _filteredProducts.sublist(start, end);
  }

  int get _totalPages => (_filteredProducts.length / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lọc sản phẩm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _fromPriceController,
                    decoration: const InputDecoration(labelText: 'Từ giá'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _toPriceController,
                    decoration: const InputDecoration(labelText: 'Đến giá'),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Danh mục:', style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Wrap(
              children: _categories.map((cat) => CheckboxListTile(
                title: Text(cat),
                value: _selectedCategories.contains(cat),
                onChanged: (val) {
                  setState(() {
                    if (val == true) {
                      _selectedCategories.add(cat);
                    } else {
                      _selectedCategories.remove(cat);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
              )).toList(),
            ),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Xếp theo'),
              value: _sortOrder,
              items: ['Giá tăng', 'Giá giảm', 'Mới nhất']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _sortOrder = val!),
            ),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _applyFilter,
                  child: const Text('Áp dụng'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: _resetFilter,
                  child: const Text('Đặt lại'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredProducts.isEmpty
                  ? const Center(child: Text('Không có sản phẩm phù hợp'))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: _getPageProducts().length,
                            itemBuilder: (context, index) {
                              final product = _getPageProducts()[index];
                              return ListTile(
                                leading: product.imagePaths.isNotEmpty
                                    ? Image.file(File(product.imagePaths.first), width: 50, height: 50, fit: BoxFit.cover)
                                    : const Icon(Icons.image),
                                title: Text(product.name),
                                subtitle: Text('Giá: ${product.price}\nDanh mục: ${product.category}'),
                              );
                            },
                          ),
                        ),
                        if (_totalPages > 1)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left),
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              Text('Trang $_currentPage/$_totalPages'),
                              IconButton(
                                icon: const Icon(Icons.chevron_right),
                                onPressed: _currentPage < _totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

