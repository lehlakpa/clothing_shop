import 'dart:async';

import 'package:clothing_shop/models/card_item_model.dart';
import 'package:clothing_shop/widgets/device_id_servider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  CartProvider() {
    _init();
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItemModel> _items = [];
  String? _guestId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isLoading = true;

  List<CartItemModel> get items => List.unmodifiable(_items);

  /// True until the first Firestore snapshot arrives, so the UI can show
  /// a spinner instead of flashing an empty cart on launch.
  bool get isLoading => _isLoading;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get shipping {
    if (_items.isEmpty) return 0;
    return subtotal > 100 ? 0 : 6;
  }

  double get total => subtotal + shipping;

  CollectionReference<Map<String, dynamic>> get _cartRef {
    final guestId = _guestId;
    if (guestId == null) {
      throw StateError(
        'CartProvider used before initialization finished — await '
        'cartProvider.ready first, or just wait for isLoading to flip.',
      );
    }
    return _firestore.collection('carts').doc(guestId).collection('items');
  }

  String _docId(String productId, String selectedColor) =>
      selectedColor.isEmpty ? productId : '${productId}_$selectedColor';

  Future<void> _init() async {
    _guestId = await DeviceIdService.getGuestId();

    _subscription = _cartRef.snapshots().listen(
      (snapshot) {
        _items = snapshot.docs
            .map((doc) => CartItemModel.fromMap(doc.data()))
            .toList();
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('CartProvider stream error: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> addToCart(
    ProductModel product, {
    int quantity = 1,
    String selectedColor = '',
  }) async {
    if (_guestId == null) await _init();

    final docRef = _cartRef.doc(_docId(product.id, selectedColor));
    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.update({'quantity': FieldValue.increment(quantity)});
    } else {
      final item = CartItemModel(
        product: product,
        quantity: quantity,
        selectedColor: selectedColor,
      );
      await docRef.set({
        ...item.toMap(),
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// NOTE: matches the original signature (productId only). If the same
  /// product is in the cart in more than one color, pass selectedColor
  /// explicitly or this targets the empty-color doc id, same limitation
  /// the original in-memory version had.
  Future<void> increase(String productId, {String selectedColor = ''}) async {
    await _cartRef.doc(_docId(productId, selectedColor)).update({
      'quantity': FieldValue.increment(1),
    });
  }

  Future<void> decrease(String productId, {String selectedColor = ''}) async {
    final docRef = _cartRef.doc(_docId(productId, selectedColor));
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;

    final currentQuantity =
        (snapshot.data()?['quantity'] as num?)?.toInt() ?? 1;

    if (currentQuantity > 1) {
      await docRef.update({'quantity': FieldValue.increment(-1)});
    } else {
      await docRef.delete();
    }
  }

  /// Removes every color variant of this product from the cart.
  Future<void> remove(String productId) async {
    final snapshot = await _cartRef
        .where('productId', isEqualTo: productId)
        .get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> clear() async {
    final snapshot = await _cartRef.get();

    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
