// lib/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'product.dart';

class ApiService {
  // !! LƯU Ý QUAN TRỌNG VỀ ĐỊA CHỈ IP !!
  // - Nếu dùng máy ảo Android, dùng địa chỉ 10.0.2.2 để trỏ đến localhost của máy tính.
  // - Nếu dùng máy thật, đảm bảo điện thoại và máy tính chung một mạng WiFi
  // và dùng địa chỉ IP của máy tính (ví dụ: 192.168.1.10).
  static const String baseUrl = 'http://localhost:8000/api';

  Future<List<Product>> fetchProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products'));
    
    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      List<Product> products = body
          .map(
            (dynamic item) => Product.fromJson(item),
          )
          .toList();
      return products;
    } else {
      throw Exception('Failed to load products');
    }
  }

  Future<bool> createProduct(Product product) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': product.name,
        'description': product.description,
        'price': product.price,
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/$id'),
    );
    return response.statusCode == 204;
  }
}
