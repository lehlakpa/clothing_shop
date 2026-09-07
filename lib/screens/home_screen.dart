import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/screens/add_screen.dart';
import 'package:clothing_shop/screens/product_details_screen.dart';
import 'package:clothing_shop/widgets/custom_banner.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/custom_headcer.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();

  final List<String> categories = const [
    'All',
    'Hoodies',
    'Jackets',
    'Tees',
    'Shirts',
    'Pants',
    'Accessories',
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final selectedCategory = productProvider.selectedCategory;

    return Scaffold(
      backgroundColor: AppColors.paper,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        backgroundColor: AppColors.forest,
        foregroundColor: AppColors.paper,
        elevation: 4,
        icon: const Icon(Icons.add_photo_alternate_outlined, size: 20),
        label: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // HEADER
                const HeaderSection(userName: 'Lakpa'),

                const SizedBox(height: 16),

                // SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.line.withValues(alpha: 0.8),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 20, color: AppColors.sub),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) {
                            context.read<ProductProvider>().searchProducts(
                              query: value,
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: 'Search new features, studios, items...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: AppColors.sub,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            searchController.clear();
                            context.read<ProductProvider>().searchProducts(
                              query: '',
                            );
                          },
                          icon: const Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.sub,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // BANNER
                const BannerSlider(),

                const SizedBox(height: 28),

                // ===================================
                // NEW FEATURES HEADER WITH COUNT PILL
                // ===================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'New Features',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Cloudinary',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        context.read<ProductProvider>().setCategory('All');
                        searchController.clear();
                        context.read<ProductProvider>().searchProducts(
                          query: '',
                        );
                      },
                      child: const Text(
                        'Reset Filter',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.sub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ===================================
                // CATEGORY FILTER CHIPS
                // ===================================
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected =
                          selectedCategory.toLowerCase() ==
                          category.toLowerCase();

                      return GestureDetector(
                        onTap: () {
                          context.read<ProductProvider>().setCategory(category);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.forest
                                : AppColors.cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.forest
                                  : AppColors.line,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.paper
                                  : AppColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                StreamBuilder<List<ProductModel>>(
                  stream: productProvider.productsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        productProvider.products.isEmpty) {
                      return _buildLoadingGrid();
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: AppColors.clay,
                                size: 36,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error loading items: ${snapshot.error}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.sub,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Filter products by selected category and search query
                    final allItems = snapshot.data ?? productProvider.products;
                    final query = searchController.text.toLowerCase().trim();

                    final displayedProducts = allItems.where((product) {
                      final matchesCategory =
                          selectedCategory == 'All' ||
                          product.category.trim().toLowerCase() ==
                              selectedCategory.trim().toLowerCase();

                      final matchesQuery =
                          query.isEmpty ||
                          product.name.toLowerCase().contains(query) ||
                          product.category.toLowerCase().contains(query) ||
                          product.description.toLowerCase().contains(query) ||
                          product.maker.toLowerCase().contains(query);

                      return matchesCategory && matchesQuery;
                    }).toList();

                    if (displayedProducts.isEmpty) {
                      return _buildEmptyState(context, selectedCategory);
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: displayedProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.60,
                          ),
                      itemBuilder: (_, index) {
                        final product = displayedProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===================================
  // SKELETON / LOADING GRID
  // ===================================
  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 16,
        childAspectRatio: 0.60,
      ),
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.cream,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.line.withValues(alpha: 0.6)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.forest,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.line.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.line.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 45,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.line.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===================================
  // EMPTY STATE
  // ===================================
  Widget _buildEmptyState(BuildContext context, String currentCategory) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.paper,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.image_search_outlined,
              size: 30,
              color: AppColors.sub,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            currentCategory == 'All'
                ? 'No products available'
                : 'No items in "$currentCategory"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Upload a new product image with Cloudinary to showcase here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: AppColors.sub, height: 1.4),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
            icon: const Icon(Icons.add_photo_alternate, size: 18),
            label: const Text(
              'Add New Product',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: AppColors.paper,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
