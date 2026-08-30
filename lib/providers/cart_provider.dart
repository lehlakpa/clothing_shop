import 'package:flutter/foundation.dart';
import '../models/card_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount {
    return _items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold<double>(0, (sum, item) => sum + item.total);
  }

  double get shipping {
    if (_items.isEmpty) return 0;

    return subtotal > 100 ? 0 : 6;
  }

  double get total => subtotal + shipping;

  void addToCart(ProductModel product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItemModel(product: product, quantity: quantity));
    }

    notifyListeners();
  }

  void increase(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrease(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
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
