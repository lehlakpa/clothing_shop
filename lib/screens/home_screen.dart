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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // HEADER
                const HeaderSection(userName: 'lakpa'),

                const SizedBox(height: 16),

                // SEARCH BAR
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, size: 19, color: AppColors.sub),
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
                            hintText: 'Search studios, materials, makers',
                            hintStyle: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.sub,
                            ),
                            border: InputBorder.none,
                            isDense: true,
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

                const SizedBox(height: 16),

                // BANNER
                const BannerSlider(),

                const SizedBox(height: 26),

                // NEW FEATURES — plain sans-serif label, quiet text link
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'New Features',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'See all',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.sub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // PRODUCTS STREAM
                StreamBuilder<List<ProductModel>>(
                  stream: productProvider.productsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        productProvider.products.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.forest,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'Something went wrong',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.sub,
                            ),
                          ),
                        ),
                      );
                    }

                    // Use active search results if search bar has input, else snapshot stream items
                    final displayedProducts = searchController.text.isNotEmpty
                        ? productProvider.searchResults
                        : (snapshot.data ?? []);

                    if (displayedProducts.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(
                          child: Text(
                            'No products available right now.',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.sub,
                            ),
                          ),
                        ),
                      );
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
                            childAspectRatio: 0.70,
                          ),
                      itemBuilder: (_, index) {
                        final product = displayedProducts[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailsScreen(product: product),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: ProductCard(product: product),
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
}
