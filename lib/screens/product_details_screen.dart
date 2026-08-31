import 'dart:ui';

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
            padding: const EdgeInsets.only(bottom: 118),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _hero(product, liked),

                Transform.translate(
                  offset: const Offset(0, -34),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: _makerPanel(product),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 6, 22, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name,
                              style: const TextStyle(
                                fontSize: 25,
                                height: 1.15,
                                letterSpacing: -0.4,
                                color: AppColors.ink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '\$${product.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              letterSpacing: -0.3,
                              color: AppColors.forest,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Text(
                        product.description,
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.6,
                          color: AppColors.ink,
                        ),
                      ),

                      const SizedBox(height: 26),

                      _sectionLabel('Finish', finishes[finish][0]),
                      const SizedBox(height: 10),
                      _finishPicker(),

                      const SizedBox(height: 26),

                      _quantityAndDelivery(),

                      const SizedBox(height: 8),

                      _details(),

                      const SizedBox(height: 18),

                      _trustRow(),

                      const SizedBox(height: 8),
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

  // ---------------------------------------------------------------------
  // Hero
  // ---------------------------------------------------------------------

  Widget _hero(ProductModel product, bool liked) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SwatchWidget(colors: product.colors, radius: 0),

          // Bottom scrim so the overlapping panel and icons stay legible.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 130,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0),
                    Colors.black.withOpacity(0.16),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            left: 18,
            top: 45,
            child: _glassButton(
              Icons.chevron_left,
              () => Navigator.pop(context),
            ),
          ),

          Positioned(
            right: 18,
            top: 45,
            child: Row(
              children: [
                _glassButton(Icons.share_outlined, () {}),
                const SizedBox(width: 8),
                _glassButton(
                  liked ? Icons.favorite : Icons.favorite_border,
                  () => context.read<WishlistProvider>().toggle(product.id),
                  color: liked ? AppColors.clay : AppColors.ink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _glassButton(
    IconData icon,
    VoidCallback onTap, {
    Color color = AppColors.ink,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            width: 35,
            height: 35,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.paper.withOpacity(0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Maker panel — the one signature element, everything else stays quiet.
  // ---------------------------------------------------------------------

  Widget _makerPanel(ProductModel product) {
    final initial = product.maker.isNotEmpty
        ? product.maker[0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.forest,
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.paper,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.maker,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: AppColors.gold),
                    const SizedBox(width: 3),
                    Text(
                      '${product.rating} · ${product.reviews} reviews',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.sub,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.verified_user_outlined,
            size: 16,
            color: AppColors.teal,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Section label — plain sentence case, current value trails on the right
  // instead of stacking a second all-caps line beneath it.
  // ---------------------------------------------------------------------

  Widget _sectionLabel(String label, [String? value]) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: AppColors.ink,
          ),
        ),
        if (value != null) ...[
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 12.5, color: AppColors.sub),
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Finish picker — swatch + name together, so the color isn't a guess.
  // ---------------------------------------------------------------------

  Widget _finishPicker() {
    return SizedBox(
      height: 60,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: finishes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final selected = finish == index;

          return GestureDetector(
            onTap: () => setState(() => finish = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.only(left: 6, right: 16),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.forest.withOpacity(0.08)
                    : Colors.transparent,
                border: Border.all(
                  color: selected ? AppColors.forest : AppColors.line,
                  width: selected ? 1.4 : 1,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: SwatchWidget(
                      colors: [finishes[index][1], finishes[index][2]],
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    finishes[index][0],
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? AppColors.forest : AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Quantity + delivery, side by side instead of two stacked blocks.
  // ---------------------------------------------------------------------

  Widget _quantityAndDelivery() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _quantity(),
        const SizedBox(width: 12),
        Expanded(child: _delivery()),
      ],
    );
  }

  Widget _quantity() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () =>
                setState(() => quantity = quantity > 1 ? quantity - 1 : 1),
            child: const Icon(Icons.remove, size: 15, color: AppColors.sub),
          ),
          const SizedBox(width: 14),
          Text(
            '$quantity',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
          ),
          const SizedBox(width: 14),
          GestureDetector(
            onTap: () => setState(() => quantity++),
            child: const Icon(Icons.add, size: 15, color: AppColors.forest),
          ),
        ],
      ),
    );
  }

  Widget _delivery() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.local_shipping_outlined,
                size: 14,
                color: AppColors.teal,
              ),
              SizedBox(width: 6),
              Text(
                'Arrives in 4–6 days',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Free over \$100, from Providence, RI',
            style: TextStyle(fontSize: 10.5, color: AppColors.sub),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Details accordion
  // ---------------------------------------------------------------------

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
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    Icon(
                      open ? Icons.remove : Icons.add,
                      size: 16,
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

  Widget _trustRow() {
    return Row(
      children: const [
        Icon(Icons.verified_user_outlined, size: 15, color: AppColors.teal),
        SizedBox(width: 6),
        Text(
          'Studio verified',
          style: TextStyle(fontSize: 10.5, color: AppColors.sub),
        ),
        SizedBox(width: 18),
        Icon(Icons.replay_outlined, size: 15, color: AppColors.teal),
        SizedBox(width: 6),
        Text(
          '30-day returns',
          style: TextStyle(fontSize: 10.5, color: AppColors.sub),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Bottom bar
  // ---------------------------------------------------------------------

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
                  'Total',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: AppColors.sub,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '\$${(product.price * quantity).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    color: AppColors.forest,
                    fontWeight: FontWeight.w700,
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
                  elevation: 0,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                      topRight: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text(
                  'Add to bag',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
