import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/widgets/custom_buttom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/bottom_nav.dart'; // Ensure correct path to your BottomNav widget
import '../widgets/custom_headcer.dart';
import '../widgets/product_card.dart';
import 'bag_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  final TextEditingController searchController = TextEditingController();

  final List<BannerItem> banners = [
    BannerItem(
      tag: 'AUTUMN STUDIO SALE',
      title: 'Fired, woven & carved this week',
      subtitle: '15% off new arrivals from 12 small studios.',
      buttonText: 'Browse the sale',
      gradientColors: [AppColors.forest, AppColors.forestDark],
      tagColor: AppColors.gold,
      buttonBgColor: AppColors.gold,
      buttonTextColor: AppColors.forestDark,
    ),
    BannerItem(
      tag: 'HANDMADE TEXTILES',
      title: 'Artisan rugs & throw blankets',
      subtitle: 'Sustainably sourced wool crafted by local weavers.',
      buttonText: 'Explore Collection',
      gradientColors: const [Color(0xFF8C533E), Color(0xFF593122)],
      tagColor: const Color(0xFFF2C94C),
      buttonBgColor: const Color(0xFFF2C94C),
      buttonTextColor: const Color(0xFF331D15),
    ),
    BannerItem(
      tag: 'FEATURED MAKER',
      title: 'Minimalist Glassware Series',
      subtitle: 'Hand-blown glass pieces designed for everyday elegance.',
      buttonText: 'Meet the Maker',
      gradientColors: const [Color(0xFF2C4C5E), Color(0xFF162B37)],
      tagColor: const Color(0xFF81D4FA),
      buttonBgColor: const Color(0xFF81D4FA),
      buttonTextColor: const Color(0xFF0D1B2A),
    ),
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (currentIndex == index) return;

    setState(() {
      currentIndex = index;
    });

    switch (index) {
      case 0:
        // Current tab: Home
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BagScreen()),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
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
                            setState(() {});
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
                            setState(() {});
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
                BannerSlider(banners: banners),

                const SizedBox(height: 22),

                // PRODUCT HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'New Features',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'serif',
                      ),
                    ),
                    Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.teal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // PRODUCTS
                StreamBuilder<List<ProductModel>>(
                  stream: productProvider.productsStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: Text('Something went wrong')),
                      );
                    }

                    final products = snapshot.data ?? [];

                    if (products.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: Text('No products found')),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: products.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.70,
                          ),
                      itemBuilder: (_, index) {
                        final product = products[index];
                        return ProductCard(product: product);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
