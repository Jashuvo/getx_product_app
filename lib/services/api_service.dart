import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ApiService {
  static const baseUrl = 'https://dummyjson.com/products';

  static Future<List<Product>> fetchProducts() async {
    final res = await http.get(Uri.parse('$baseUrl?limit=100'));
    final data = json.decode(res.body);
    return List<Product>.from(data['products'].map((x) => Product.fromJson(x)));
  }

  static Future<List<Product>> searchProducts(String query) async {
    final res = await http.get(Uri.parse('$baseUrl/search?q=$query'));
    final data = json.decode(res.body);
    return List<Product>.from(data['products'].map((x) => Product.fromJson(x)));
  }

  static Future<List<String>> fetchCategories() async {
    final res = await http.get(Uri.parse('$baseUrl/categories'));
    return List<String>.from(json.decode(res.body));
  }

  static Future<List<Product>> fetchByCategory(String category) async {
    final res = await http.get(Uri.parse('$baseUrl/category/$category'));
    final data = json.decode(res.body);
    return List<Product>.from(data['products'].map((x) => Product.fromJson(x)));
  }
}
