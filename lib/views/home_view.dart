import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_product_app/views/widgets/product_card.dart';
import '../controllers/product_controller.dart';
import 'product_detail_view.dart';

class HomeView extends StatelessWidget {
  HomeView({super.key});

  final ProductController controller = Get.find<ProductController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Store'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Obx(
        () =>
            controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          controller.searchProducts(value);
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: Obx(
                        () => ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            const SizedBox(width: 8),
                            ChoiceChip(
                              label: const Text('All'),
                              selected: controller.selectedCategory.value == '',
                              onSelected: (_) => controller.fetchProducts(),
                            ),
                            ...controller.categories.map((category) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
                                child: ChoiceChip(
                                  label: Text(category as String),
                                  selected:
                                      controller.selectedCategory.value ==
                                      category,
                                  onSelected:
                                      (_) => controller.filterByCategory(
                                        category as String,
                                      ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Obx(
                        () =>
                            controller.products.isEmpty
                                ? const Center(child: Text('No products found'))
                                : GridView.builder(
                                  padding: const EdgeInsets.all(8),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                        childAspectRatio: 0.75,
                                      ),
                                  itemCount: controller.products.length,
                                  itemBuilder: (context, index) {
                                    final product = controller.products[index];
                                    return GestureDetector(
                                      onTap:
                                          () => Get.to(
                                            () => ProductDetailView(
                                              product: product,
                                            ),
                                          ),
                                      child: ProductCard(product: product),
                                    );
                                  },
                                ),
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}
