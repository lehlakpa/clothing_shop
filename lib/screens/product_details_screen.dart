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
  int finish = 0;
  int openDetail = -1;

  final finishes = [
    ['Terracotta', '#C6764A'],
    ['Ash', '#A9814F'],
    ['Charcoal', '#4A4842'],
  ];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final liked = context.watch<WishlistProvider>().isLiked(product.id);

    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.ink),
        actions: [
          IconButton(
            icon: Icon(
              liked ? Icons.favorite : Icons.favorite_border,
              color: liked ? AppColors.clay : AppColors.ink,
            ),
            onPressed: () =>
                context.read<WishlistProvider>().toggle(product.id),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 260,
                      width: double.infinity,
                      child: SwatchWidget(colors: product.colors, radius: 0),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Title + price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      Text(
                        '\$${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.forest,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Maker + rating, plain line
                  Row(
                    children: [
                      Text(
                        product.maker,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.sub,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.star, size: 13, color: AppColors.gold),
                      const SizedBox(width: 3),
                      Text(
                        '${product.rating} (${product.reviews})',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.sub,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Text(
                    product.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: AppColors.ink,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Finish
                  const Text(
                    'Finish',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(finishes.length, (index) {
                      final selected = finish == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: GestureDetector(
                          onTap: () => setState(() => finish = index),
                          child: Column(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(
                                    int.parse(
                                      finishes[index][1].replaceFirst(
                                        '#',
                                        '0xFF',
                                      ),
                                    ),
                                  ),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.forest
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                finishes[index][0],
                                style: TextStyle(
                                  fontSize: 11,
                                  color: selected
                                      ? AppColors.forest
                                      : AppColors.sub,
                                  fontWeight: selected
                                      ? FontWeight.w600
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

                  // Quantity
                  const Text(
                    'Quantity',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _stepButton(Icons.remove, () {
                        setState(
                          () => quantity = quantity > 1 ? quantity - 1 : 1,
                        );
                      }),
                      SizedBox(
                        width: 40,
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _stepButton(Icons.add, () => setState(() => quantity++)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Delivery, plain text line instead of a card
                  Row(
                    children: const [
                      Icon(
                        Icons.local_shipping_outlined,
                        size: 15,
                        color: AppColors.sub,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Arrives in 4–6 days · Free over \$100',
                        style: TextStyle(fontSize: 12.5, color: AppColors.sub),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Details accordion, simplified
                  _details(),
                ],
              ),
            ),
          ),

          _bottomBar(product),
        ],
      ),
    );
  }

  Widget _stepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.line),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 15, color: AppColors.ink),
      ),
    );
  }

  Widget _details() {
    final data = [
      ['Dimensions', '8.5"H × 5"W, 1.4 lb'],
      ['Care', 'Wipe clean, avoid dishwasher'],
      ['Shipping & returns', 'Ships in 2–3 days, 30-day returns'],
    ];

    return Column(
      children: List.generate(data.length, (index) {
        final open = openDetail == index;

        return Column(
          children: [
            const Divider(color: AppColors.line, height: 1),
            GestureDetector(
              onTap: () => setState(() => openDetail = open ? -1 : index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data[index][0],
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Icon(
                      open
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 18,
                      color: AppColors.sub,
                    ),
                  ],
                ),
              ),
            ),
            if (open)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    data[index][1],
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.sub,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _bottomBar(ProductModel product) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: const BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().addToCart(
                product,
                quantity: quantity,
              );
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Added to bag')));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forest,
              foregroundColor: AppColors.paper,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 15),
            ),
            child: Text(
              'Add to bag · \$${(product.price * quantity).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
          ),
        ),
      ),
    );
  }
}
