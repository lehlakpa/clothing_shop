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
  int openDetail = 0;

  final finishes = [
    ['Terracotta', '#C6764A', '#8E4128'],
    ['Ash', '#A9814F', '#6E5230'],
    ['Charcoal', '#4A4842', '#242220'],
  ];

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    final liked = context.watch<WishlistProvider>().isLiked(product.id);

    return Scaffold(
      backgroundColor: AppColors.paper,

      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 110),

            child: Column(
              children: [
                _hero(product, liked),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 22),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 18),

                      Text(
                        product.maker.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.sub,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 22,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              color: AppColors.forest,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (index) => const Icon(
                              Icons.star,
                              size: 13,
                              color: AppColors.gold,
                            ),
                          ),

                          const SizedBox(width: 6),

                          Text(
                            '${product.rating} (${product.reviews} reviews)',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.sub,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.55,
                          color: AppColors.ink,
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'FINISH',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: List.generate(finishes.length, (index) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                finish = index;
                              });
                            },

                            child: Container(
                              width: 44,
                              height: 44,
                              margin: const EdgeInsets.only(right: 10),

                              padding: const EdgeInsets.all(2),

                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: finish == index
                                      ? AppColors.forest
                                      : Colors.transparent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),

                              child: SwatchWidget(
                                colors: [
                                  finishes[index][1],
                                  finishes[index][2],
                                ],
                                radius: 9,
                              ),
                            ),
                          );
                        }),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        'QUANTITY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      _quantity(),

                      const SizedBox(height: 20),

                      _delivery(),

                      const SizedBox(height: 18),

                      _details(),

                      const SizedBox(height: 16),

                      const Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            size: 15,
                            color: AppColors.teal,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Studio verified',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.sub,
                            ),
                          ),
                          SizedBox(width: 18),
                          Icon(
                            Icons.replay_outlined,
                            size: 15,
                            color: AppColors.teal,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '30-day returns',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.sub,
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

          _bottomBar(product),
        ],
      ),
    );
  }

  Widget _hero(ProductModel product, bool liked) {
    return SizedBox(
      height: 350,

      child: Stack(
        children: [
          Positioned.fill(
            child: SwatchWidget(colors: product.colors, radius: 0),
          ),

          Positioned(
            left: 22,
            top: 45,

            child: _circleButton(
              Icons.chevron_left,
              () => Navigator.pop(context),
            ),
          ),

          Positioned(
            right: 22,
            top: 45,

            child: Row(
              children: [
                _circleButton(Icons.share_outlined, () {}),

                const SizedBox(width: 8),

                _circleButton(
                  liked ? Icons.favorite : Icons.favorite_border,

                  () {
                    context.read<WishlistProvider>().toggle(product.id);
                  },

                  color: liked ? AppColors.clay : AppColors.ink,
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 15,
            left: 0,
            right: 0,

            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,

              children: List.generate(
                4,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == 0 ? 14 : 6,
                  height: 6,

                  decoration: BoxDecoration(
                    color: AppColors.paper,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = AppColors.ink,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 35,
        height: 35,

        decoration: const BoxDecoration(
          color: AppColors.cream,
          shape: BoxShape.circle,
        ),

        child: Icon(icon, size: 17, color: color),
      ),
    );
  }

  Widget _quantity() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),

      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(30),
      ),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                quantity = quantity > 1 ? quantity - 1 : 1;
              });
            },
            child: const Icon(Icons.remove, size: 15),
          ),

          const SizedBox(width: 18),

          Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(width: 18),

          GestureDetector(
            onTap: () {
              setState(() {
                quantity++;
              });
            },
            child: const Icon(Icons.add, size: 15),
          ),
        ],
      ),
    );
  }

  Widget _delivery() {
    return Container(
      padding: const EdgeInsets.all(13),

      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),

      child: const Row(
        children: [
          Icon(Icons.local_shipping_outlined, color: AppColors.teal),

          SizedBox(width: 10),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Arrives in 4–6 days',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),

              Text(
                'Free shipping over \$100 · Ships from Providence, RI',
                style: TextStyle(fontSize: 11, color: AppColors.sub),
              ),
            ],
          ),
        ],
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
            GestureDetector(
              onTap: () {
                setState(() {
                  openDetail = open ? -1 : index;
                });
              },

              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        data[index][0],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),

                    Icon(
                      open
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 17,
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
                    style: const TextStyle(fontSize: 12, color: AppColors.sub),
                  ),
                ),
              ),

            const Divider(color: AppColors.line, height: 1),
          ],
        );
      }),
    );
  }

  Widget _bottomBar(ProductModel product) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,

      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 26),

        decoration: const BoxDecoration(
          color: AppColors.cream,
          border: Border(top: BorderSide(color: AppColors.line)),
        ),

        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.sub,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Text(
                  '\$${(product.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.forest,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 14),

            Expanded(
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

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),

                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),

                child: const Text(
                  'Add to bag',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
