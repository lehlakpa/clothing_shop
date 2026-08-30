import 'package:clothing_shop/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;
  final String selectedColor;

  CartItemModel({
    this.id = '',
    required this.product,
    this.quantity = 1,
    this.selectedColor = '',
  });

  /// Calculates total price for this cart item based on quantity
  double get totalPrice => product.price * quantity;

  /// Creates a copy of CartItemModel with updated fields
  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
    String? selectedColor,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map, String id) {
    return CartItemModel(
      id: id,
      product: ProductModel.fromMap(
        map['product'] as Map<String, dynamic>? ?? {},
        map['productId'] ?? '',
      ),
      quantity: map['quantity'] ?? 1,
      selectedColor: map['selectedColor'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
    };
  }
}
