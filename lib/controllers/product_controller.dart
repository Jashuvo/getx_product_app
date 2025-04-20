import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/product_model.dart';

class ProductController extends GetxController {
  RxList<Product> products = <Product>[].obs;
  RxList<Product> filteredProducts = <Product>[].obs;
  RxList<Category> categories = <Category>[].obs;
  RxString selectedCategory = ''.obs;
  RxBool isLoading = false.obs;
  RxBool isCategoriesLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    initData();
  }

  Future<void> initData() async {
    await fetchCategories();
    await fetchProducts();
  }

  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/products/categories"),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        categories.value = data.map((e) => Category.fromJson(e)).toList();
        print('Loaded categories: ${categories.map((c) => c.name).toList()}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
    } finally {
      isCategoriesLoading.value = false;
    }
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/products?limit=100"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        products.value = List<Product>.from(
          data['products'].map((p) => Product.fromJson(p)),
        );
        filteredProducts.value = products;
      }
    } catch (e) {
      print('Error fetching products: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void filterByCategory(String slug) async {
    selectedCategory.value = slug;
    if (slug.isEmpty) {
      filteredProducts.value = products;
      return;
    }
    isLoading.value = true;
    try {
      // Cache the selected category
      final cached = [...filteredProducts];

      final response = await http.get(
        Uri.parse("https://dummyjson.com/products/category/$slug"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        filteredProducts.value = List<Product>.from(
          data['products'].map((p) => Product.fromJson(p)),
        );
      } else {
        // Restore cached products if request fails
        filteredProducts.value = cached;
        selectedCategory.value = '';
      }
    } catch (e) {
      print('Error filtering by category: $e');
      selectedCategory.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  void searchProducts(String query) async {
    if (query.isEmpty) {
      filteredProducts.value = products;
      return;
    }
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/products/search?q=$query"),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        filteredProducts.value = List<Product>.from(
          data['products'].map((p) => Product.fromJson(p)),
        );
      }
    } catch (e) {
      print('Error searching products: $e');
    }
  }
}
