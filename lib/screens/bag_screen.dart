import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/app_colors.dart';
import '../widgets/swatch_widget.dart';

class BagScreen extends StatelessWidget {
  const BagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,

      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 22,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Bag',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 27,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            if (cart.items.isNotEmpty)
              Text(
                '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'items'}',
                style: const TextStyle(color: AppColors.sub, fontSize: 12),
              ),
          ],
        ),
      ),

      body: cart.items.isEmpty
          ? _emptyBag(context)
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
                    children: [
                      ...cart.items.map(
                        (item) => _cartItem(context, cart, item),
                      ),

                      const SizedBox(height: 8),

                      _promoCode(),

                      const SizedBox(height: 18),

                      _orderSummary(cart),

                      const SizedBox(height: 110),
                    ],
                  ),
                ),

                _bottomCheckout(context, cart),
              ],
            ),
    );
  }

  // ============================================================
  // CART ITEM
  // ============================================================

  Widget _cartItem(BuildContext context, CartProvider cart, dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PRODUCT IMAGE / SWATCH
          Container(
            width: 92,
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(15),
            ),
            clipBehavior: Clip.antiAlias,
            child: SwatchWidget(colors: item.product.colors, radius: 15),
          ),

          const SizedBox(width: 14),

          // DETAILS
          Expanded(
            child: SizedBox(
              height: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: () {
                          cart.remove(item.product.id);
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: AppColors.sub,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    item.product.maker,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.sub,
                      fontSize: 11.5,
                    ),
                  ),

                  const Spacer(),

                  Row(
                    children: [
                      _quantityControl(
                        icon: Icons.remove,
                        onTap: () {
                          cart.decrease(item.product.id);
                        },
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 13),
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      _quantityControl(
                        icon: Icons.add,
                        onTap: () {
                          cart.increase(item.product.id);
                        },
                      ),

                      const Spacer(),

                      Text(
                        '\$${item.totalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.forest,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUANTITY CONTROL
  // ============================================================

  Widget _quantityControl({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 29,
          height: 29,
          decoration: BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: AppColors.line),
          ),
          child: Icon(icon, size: 14, color: AppColors.ink),
        ),
      ),
    );
  }

  // ============================================================
  // PROMO CODE
  // ============================================================

  Widget _promoCode() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.paper,
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(
              Icons.local_offer_outlined,
              size: 18,
              color: AppColors.forest,
            ),
          ),

          const SizedBox(width: 12),

          const Expanded(
            child: Text(
              'Have a promo code?',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),

          TextButton(
            onPressed: () {},
            child: const Text(
              'Apply',
              style: TextStyle(
                color: AppColors.forest,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ORDER SUMMARY
  // ============================================================

  Widget _orderSummary(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          _summaryRow('Subtotal', '\$${cart.subtotal.toStringAsFixed(2)}'),

          const SizedBox(height: 10),

          _summaryRow(
            'Shipping',
            cart.shipping == 0
                ? 'Free'
                : '\$${cart.shipping.toStringAsFixed(2)}',
          ),

          const SizedBox(height: 14),

          const Divider(color: AppColors.line, height: 1),

          const SizedBox(height: 14),

          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const Spacer(),

              Text(
                '\$${cart.total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.forest,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: AppColors.sub, fontSize: 12.5),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.ink,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOTTOM CHECKOUT
  // ============================================================

  Widget _bottomCheckout(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.forestDark,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            offset: const Offset(0, -5),
            color: Colors.black.withOpacity(0.12),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL',
                  style: TextStyle(
                    color: Color(0xFF9FB3A6),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '\$${cart.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: AppColors.paper,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 20),

            Expanded(
              child: ElevatedButton(
                onPressed: cart.items.isEmpty
                    ? null
                    : () {
                        // Checkout
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.forestDark,
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY BAG
  // ============================================================

  Widget _emptyBag(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.cream,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(
                Icons.shopping_bag_outlined,
                size: 38,
                color: AppColors.forest,
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Your bag is empty',
              style: TextStyle(
                color: AppColors.ink,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Time to find something made by hand.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.sub, fontSize: 13, height: 1.5),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: () {
                // Navigate to shopping/home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.forestDark,
                foregroundColor: AppColors.paper,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start Shopping',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
