import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../providers/wishlist_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/swatch_widget.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int quantity = 1;
  int selectedFinish = 0;
  int openDetail = -1;

  final List<Map<String, dynamic>> finishes = [
    {'name': 'Terracotta', 'color': const Color(0xFFC6764A)},
    {'name': 'Ash', 'color': const Color(0xFFA9814F)},
    {'name': 'Charcoal', 'color': const Color(0xFF4A4842)},
  ];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final liked = context.watch<WishlistProvider>().isLiked(product.id);
    final hasImage = product.imageUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Hero Image Header with Glassmorphism Back Button
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.paper,
                elevation: 0,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withValues(alpha: 0.85),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppColors.ink,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.white.withValues(alpha: 0.85),
                      child: IconButton(
                        icon: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,
                          color: liked ? AppColors.clay : AppColors.ink,
                          size: 20,
                        ),
                        onPressed: () =>
                            context.read<WishlistProvider>().toggle(product.id),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (hasImage)
                        Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.paper,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: AppColors.forest,
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              _buildFallbackHero(),
                        )
                      else
                        _buildFallbackHero(),

                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.5),
                              Colors.transparent,
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.25, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content Body
              SliverToBoxAdapter(
                child: Container(
                  transform: Matrix4.translationValues(0, -20, 0),
                  decoration: const BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Maker Tag & Rating Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (product.maker.isNotEmpty
                                      ? product.maker
                                      : 'Handcrafted')
                                  .toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                color: AppColors.sub,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: AppColors.gold,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.rating > 0 ? product.rating : 5.0} (${product.reviews > 0 ? product.reviews : 12})',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Title & Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '\$${product.price.toStringAsFixed(product.price.truncateToDouble() == product.price ? 0 : 2)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.forest,
                              ),
                            ),
                          ],
                        ),

                        if (product.category.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.forest.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              product.category,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.forest,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          product.description.isNotEmpty
                              ? product.description
                              : 'Expertly designed and crafted with premium sustainable materials.',
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.ink.withValues(alpha: 0.8),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Finish Selector Section
                        const Text(
                          'Select Finish',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(finishes.length, (index) {
                            final isSelected = selectedFinish == index;
                            final item = finishes[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 16),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => selectedFinish = index),
                                child: Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 200,
                                      ),
                                      width: 42,
                                      height: 42,
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.forest
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                      ),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: item['color'] as Color,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['name'] as String,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isSelected
                                            ? AppColors.forest
                                            : AppColors.sub,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 24),

                        // Quantity Selector
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Quantity',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.line.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  _stepButton(Icons.remove, () {
                                    if (quantity > 1) {
                                      setState(() => quantity--);
                                    }
                                  }),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  _stepButton(
                                    Icons.add,
                                    () => setState(() => quantity++),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Delivery Info Card
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.line.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.local_shipping_outlined,
                                size: 20,
                                color: AppColors.forest,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Arrives in 4–6 days · Free over \$100',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.ink,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Accordion Section
                        _detailsAccordion(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Floating Bottom CTA
          Positioned(left: 0, right: 0, bottom: 0, child: _bottomBar(product)),
        ],
      ),
    );
  }

  Widget _buildFallbackHero() {
    return Stack(
      fit: StackFit.expand,
      children: [
        SwatchWidget(colors: widget.product.colors, radius: 0),
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.checkroom_outlined,
              size: 60,
              color: AppColors.paper,
            ),
          ),
        ),
      ],
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 16, color: AppColors.ink),
      onPressed: onTap,
      splashRadius: 20,
    );
  }

  Widget _detailsAccordion() {
    final data = [
      ['Dimensions & Details', 'Custom tailored, heavy density construction'],
      ['Care Instructions', 'Machine wash cold, gentle cycle, dry flat'],
      ['Shipping & Returns', 'Ships within 24 hours · 30-day effortless returns'],
    ];

    return Column(
      children: List.generate(data.length, (index) {
        final open = openDetail == index;
        return Column(
          children: [
            const Divider(height: 1, color: AppColors.line),
            Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: Key(index.toString()),
                initiallyExpanded: open,
                onExpansionChanged: (expanded) {
                  setState(() => openDetail = expanded ? index : -1);
                },
                title: Text(
                  data[index][0],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      bottom: 16,
                      right: 16,
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        data[index][1],
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.sub,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _bottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
      decoration: BoxDecoration(
        color: AppColors.paper,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          context.read<CartProvider>().addToCart(product, quantity: quantity);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Added to bag'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forest,
          foregroundColor: AppColors.paper,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          'Add to bag · \$${(product.price * quantity).toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
