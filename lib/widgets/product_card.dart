import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product_model.dart';
import '../providers/wishlist_provider.dart';
import 'app_colors.dart';
import 'swatch_widget.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final wishlist = context.watch<WishlistProvider>();

    final liked = wishlist.isLiked(product.id);

    return GestureDetector(
      onTap: onTap,

      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),

        clipBehavior: Clip.antiAlias,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            SizedBox(
              height: 110,
              width: double.infinity,

              child: Stack(
                children: [
                  Positioned.fill(
                    child: SwatchWidget(colors: product.colors, radius: 0),
                  ),

                  Positioned(
                    right: 8,
                    top: 8,

                    child: GestureDetector(
                      onTap: () {
                        context.read<WishlistProvider>().toggle(product.id);
                      },

                      child: Container(
                        width: 28,
                        height: 28,

                        decoration: const BoxDecoration(
                          color: AppColors.cream,
                          shape: BoxShape.circle,
                        ),

                        child: Icon(
                          liked ? Icons.favorite : Icons.favorite_border,

                          size: 15,

                          color: liked ? AppColors.clay : AppColors.ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(11),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    product.maker.toUpperCase(),

                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.sub,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .4,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    product.name,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.ink,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '\$${product.price.toStringAsFixed(0)}',

                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.forest,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
