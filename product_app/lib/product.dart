// lib/product.dart
import 'category.dart';

class Product {
  final int id;
  final String name;
  final String? description;
  final String price;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toString(),
      category: json.containsKey('category') && json['category'] != null
          ? Category.fromJson(Map<String, dynamic>.from(json['category']))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        if (category != null) 'category': category!.toJson(),
      };
}
