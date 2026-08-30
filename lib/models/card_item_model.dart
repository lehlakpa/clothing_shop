import 'product_model.dart';

class CartItemModel {
  CartItemModel({required this.product, this.quantity = 1});

  final ProductModel product;
  int quantity;

  double get total => product.price * quantity;
}
