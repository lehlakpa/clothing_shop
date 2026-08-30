import 'package:clothing_shop/models/product_model.dart';
import 'package:clothing_shop/providers/cart_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('cart totals account for quantities and shipping', () {
    final cart = CartProvider();
    final product = ProductModel(
      id: 'vase',
      name: 'Vase',
      maker: 'Studio',
      description: 'Handmade vase',
      price: 40,
      category: 'Ceramics',
      colors: const ['#FFFFFF'],
    );

    cart.addToCart(product, quantity: 2);

    expect(cart.itemCount, 2);
    expect(cart.subtotal, 80);
    expect(cart.shipping, 6);
    expect(cart.total, 86);
  });
}
