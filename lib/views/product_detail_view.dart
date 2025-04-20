import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductDetailView extends StatelessWidget {
  final Product product;
  const ProductDetailView({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: product.images.length,
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.images[i],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              product.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(product.description),
            const SizedBox(height: 10),
            Text(
              "Price: \$${product.price}",
              style: const TextStyle(color: Colors.green, fontSize: 18),
            ),
            Text(
              "Rating: ⭐ ${product.rating}",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              "Category: ${product.category}",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
