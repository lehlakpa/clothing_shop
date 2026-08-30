import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/bottom_nav.dart';
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

  String category = 'All';

  final categories = ['All', 'Ceramics', 'Textiles', 'Wood', 'Glass', 'Light'];

  void navigate(int index) {
    if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const BagScreen()),
      );
      return;
    }

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ProfileScreen()),
      );
      return;
    }

    setState(() {
      currentIndex = index;
    });
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          'GOOD MORNING',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.sub,
                            fontWeight: FontWeight.bold,
                            letterSpacing: .5,
                          ),
                        ),

                        const SizedBox(height: 2),

                        const Text(
                          'Asha',
                          style: TextStyle(
                            fontSize: 27,
                            color: AppColors.ink,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'serif',
                          ),
                        ),
                      ],
                    ),

                    Container(
                      width: 42,
                      height: 42,

                      decoration: const BoxDecoration(
                        color: AppColors.forest,
                        shape: BoxShape.circle,
                      ),

                      alignment: Alignment.center,

                      child: const Text(
                        'A',
                        style: TextStyle(
                          color: AppColors.paper,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),

                  decoration: BoxDecoration(
                    color: AppColors.cream,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.line),
                  ),

                  child: const Row(
                    children: [
                      Icon(Icons.search, size: 17, color: AppColors.sub),

                      SizedBox(width: 8),

                      Text(
                        'Search studios, materials, makers',
                        style: TextStyle(fontSize: 12.5, color: AppColors.sub),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  height: 38,

                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,

                    itemCount: categories.length,

                    separatorBuilder: (_, _) => const SizedBox(width: 8),

                    itemBuilder: (_, index) {
                      final cat = categories[index];

                      final selected = category == cat;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            category = cat;
                          });
                        },

                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),

                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.forest
                                : Colors.transparent,

                            borderRadius: BorderRadius.circular(30),

                            border: Border.all(
                              color: selected
                                  ? AppColors.forest
                                  : AppColors.line,
                            ),
                          ),

                          alignment: Alignment.center,

                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? AppColors.paper : AppColors.ink,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                _saleBanner(),

                const SizedBox(height: 22),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                    const Text(
                      'New from the studio',
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

                StreamBuilder(
                  stream: productProvider.productsStream(),

                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return const Text('Something went wrong');
                    }

                    final products = snapshot.data ?? [];

                    final filtered = category == 'All'
                        ? products
                        : products
                              .where((p) => p.category == category)
                              .toList();

                    if (filtered.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(30),
                        child: Center(child: Text('No products found')),
                      );
                    }

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: filtered.length,

                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: .70,
                          ),

                      itemBuilder: (_, index) {
                        return ProductCard(product: filtered[index]);
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
        onTap: navigate,
      ),
    );
  }

  Widget _saleBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),

        gradient: const LinearGradient(
          colors: [AppColors.forest, AppColors.forestDark],
        ),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Text(
            'AUTUMN STUDIO SALE',
            style: TextStyle(
              color: AppColors.gold,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Fired, woven & carved this week',
            style: TextStyle(
              color: AppColors.paper,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontFamily: 'serif',
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            '15% off new arrivals from 12 small studios.',
            style: TextStyle(color: Color(0xFFD9D2C2), fontSize: 12.5),
          ),

          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: () {},

            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.forestDark,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            child: const Text('Browse the sale'),
          ),
        ],
      ),
    );
  }
}
