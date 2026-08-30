import 'package:clothing_shop/models/card_item_model.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0, (sum, item) => sum + item.totalPrice);
  }

  double get shipping {
    if (_items.isEmpty) return 0;

    return subtotal > 100 ? 0 : 6;
  }

  double get total => subtotal + shipping;

  void addToCart(
    ProductModel product, {
    int quantity = 1,
    String selectedColor = '',
  }) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id && item.selectedColor == selectedColor,
    );

    if (index >= 0) {
      final currentItem = _items[index];
      _items[index] = currentItem.copyWith(
        quantity: currentItem.quantity + quantity,
      );
    } else {
      _items.add(
        CartItemModel(
          product: product,
          quantity: quantity,
          selectedColor: selectedColor,
        ),
      );
    }

    notifyListeners();
  }

  void increase(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final currentItem = _items[index];
      _items[index] = currentItem.copyWith(quantity: currentItem.quantity + 1);
      notifyListeners();
    }
  }

  void decrease(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final currentItem = _items[index];
      if (currentItem.quantity > 1) {
        _items[index] = currentItem.copyWith(
          quantity: currentItem.quantity - 1,
        );
      } else {
        // Optional: removes item when quantity reaches 0
        _items.removeAt(index);
      }

      notifyListeners();
    }
  }

  void remove(String productId) {
    _items.removeWhere((item) => item.product.id == productId);

    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
