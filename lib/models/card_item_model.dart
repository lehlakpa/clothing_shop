import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;
  final String selectedColor;

  const CartItemModel({
    required this.product,
    required this.quantity,
    this.selectedColor = '',
  });

  // Calculate total price for this cart item
  double get totalPrice => product.price * quantity;

  // Create a new CartItemModel with changed values
  CartItemModel copyWith({
    ProductModel? product,
    int? quantity,
    String? selectedColor,
  }) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
    );
  }

  // Convert cart item to Map
  Map<String, dynamic> toMap() {
    return {
      'productId': product.id,
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
    };
  }

  // Create CartItemModel from Map
  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    final productMap = Map<String, dynamic>.from(map['product'] as Map? ?? {});

    return CartItemModel(
      product: ProductModel.fromMap(
        productMap,
        map['productId']?.toString() ?? '',
      ),

      quantity: (map['quantity'] as num?)?.toInt() ?? 1,

      selectedColor: map['selectedColor']?.toString() ?? '',
    );
  }
}
