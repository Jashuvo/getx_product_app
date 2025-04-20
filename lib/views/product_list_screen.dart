import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/product_controller.dart';
import 'product_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ScrollController _categoriesScrollController = ScrollController();
  final controller = Get.find<ProductController>();

  @override
  void initState() {
    super.initState();
    // Add post-frame callback to scroll to selected category after initial build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedCategory();
    });
  }

  @override
  void dispose() {
    _categoriesScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedCategory() {
    if (!_categoriesScrollController.hasClients) return;

    // If no category is selected, scroll to start
    if (controller.selectedCategory.value.isEmpty) {
      _categoriesScrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Find the index of the selected category
    final selectedIndex = controller.categories.indexWhere(
      (category) => category.slug == controller.selectedCategory.value,
    );

    if (selectedIndex == -1) return;

    // Calculate scroll offset
    double totalOffset = 8.0; // Initial padding
    totalOffset += 88.0; // Width of 'All' chip
    totalOffset += selectedIndex * 110.0; // Width per category chip

    // Scroll to the selected category
    _categoriesScrollController.animateTo(
      totalOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Lighter background
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0, // Prevents color change on scroll
        title: const Text(
          'Products',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false, // Align title to the left
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(65),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: controller.searchProducts,
              decoration: InputDecoration(
                hintText: 'Search Products',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ),
      ),
      body: Obx(() {
        // Scroll to selected category whenever the list rebuilds
        if (!controller.isLoading.value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToSelectedCategory();
          });
        }
        if (controller.isLoading.value) {
          return _buildLoadingList();
        }
        return Column(
          children: [
            Container(
              height: 50,
              margin: const EdgeInsets.only(top: 8),
              child: Obx(() {
                if (controller.isCategoriesLoading.value) {
                  return _buildLoadingCategories();
                }
                if (controller.categories.isEmpty) {
                  return const Center(child: Text('No categories loaded'));
                }
                return ListView(
                  controller: _categoriesScrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: const Text(
                          'All',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        selected: controller.selectedCategory.value.isEmpty,
                        onSelected: (_) {
                          controller.filterByCategory('');
                          _categoriesScrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        selectedColor: Colors.blue.shade600,
                        backgroundColor: Colors.white,
                        elevation: 2,
                        labelStyle: TextStyle(
                          color:
                              controller.selectedCategory.value.isEmpty
                                  ? Colors.white
                                  : Colors.black87,
                        ),
                      ),
                    ),
                    ...controller.categories.asMap().entries.map((entry) {
                      final category = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: ChoiceChip(
                          label: Text(
                            category.name,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          selected:
                              controller.selectedCategory.value ==
                              category.slug,
                          onSelected: (_) {
                            controller.filterByCategory(category.slug);
                            _scrollToSelectedCategory();
                          },
                          selectedColor: Colors.blue.shade600,
                          backgroundColor: Colors.white,
                          elevation: 2,
                          labelStyle: TextStyle(
                            color:
                                controller.selectedCategory.value ==
                                        category.slug
                                    ? Colors.white
                                    : Colors.black87,
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                );
              }),
            ),
            Expanded(
              child: Obx(
                () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child:
                      controller.isLoading.value
                          ? _buildLoadingList()
                          : controller.filteredProducts.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                            key: ValueKey(controller.filteredProducts.length),
                            padding: const EdgeInsets.all(12),
                            itemCount: controller.filteredProducts.length,
                            itemBuilder: (_, index) {
                              final product =
                                  controller.filteredProducts[index];
                              return Hero(
                                tag: 'product_${product.id}',
                                child: Card(
                                  elevation: 4, // Increased elevation
                                  shadowColor: Colors.black38, // Darker shadow
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  color:
                                      Colors.white, // Explicit white background
                                  child: InkWell(
                                    onTap:
                                        () => Get.to(
                                          () => ProductDetailScreen(
                                            product: product,
                                          ),
                                          transition: Transition.rightToLeft,
                                        ),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Container(
                                      // Added container for extra depth
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.1),
                                          width: 1,
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              child: CachedNetworkImage(
                                                imageUrl: product.images[0],
                                                placeholder:
                                                    (_, __) => Container(
                                                      width: 80,
                                                      height: 80,
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey[200],
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Center(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      ),
                                                    ),
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.title,
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Colors
                                                              .black87, // Darker text
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    product.category,
                                                    style: TextStyle(
                                                      color:
                                                          Colors
                                                              .grey[700], // Darker grey
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '\$${product.price}',
                                                        style: TextStyle(
                                                          color:
                                                              Colors
                                                                  .blue
                                                                  .shade700,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      Icon(
                                                        Icons.star,
                                                        size: 16,
                                                        color:
                                                            Colors
                                                                .amber
                                                                .shade700,
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        product.rating
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors
                                                                  .black87, // Darker text
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 10,
      itemBuilder:
          (_, __) => Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                height: 104,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 16,
                            width: double.infinity,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 100,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Container(height: 12, width: 80, color: Colors.white),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildLoadingCategories() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemBuilder:
          (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 100,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No products found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
