import 'package:clothing_shop/models/product_model.dart'; // Adjust path
import 'package:clothing_shop/providers/product_provider.dart';
import 'package:flutter/material.dart';

class ProductGridStream extends StatelessWidget {
  const ProductGridStream({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      // Replace with your actual stream reference (e.g., productProvider.productsStream())
      stream: ProductProvider().productsStream(),
      builder: (context, snapshot) {
        // 1. Connection Error State
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading products: ',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 2. Initial Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 3. Extract Stream Data
        final products = snapshot.data ?? [];

        // 4. Empty List Fallback State
        if (products.isEmpty) {
          return const Center(
            child: Text(
              'No products available right now.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        // 5. Data Rendered State
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        );
      },
    );
  }
}

// Sample Card Widget to display individual ProductModel data
class ProductCard extends StatelessWidget {
  final ProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.imageUrl.trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasImage
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 36,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  )
                : Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 36,
                        color: Colors.grey,
                      ),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 3),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF223B2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
