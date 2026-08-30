import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local fallback items in case Firestore is empty or offline
  List<ProductModel> _products = [];

  bool _isLoading = false;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;

  /// Stream real-time updates from Firestore. Falls back to static list if Firestore is empty.
  /// Stream real-time updates from Firestore. Updates local lists automatically.
  Stream<List<ProductModel>> productsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        _products = snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();

        // Ensure active search results stay updated when Stream emits
        if (_searchResults.isEmpty) {
          _searchResults = _products;
        }
      }
      return _products;
    });
  }

  /// One-time fetch method with safe fallback
  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products').get();
      if (snapshot.docs.isNotEmpty) {
        _products = snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList();
      }
    } catch (e) {
      debugPrint("Fetch products error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new product to Firestore
  Future<bool> addProduct(ProductModel product) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Firestore automatically generates a unique Document ID
      final docRef = await _firestore
          .collection('products')
          .add(product.toMap());

      // Update the local product instance with the newly created ID
      final newProduct = ProductModel(
        id: docRef.id,
        name: product.name,
        maker: product.maker,
        description: product.description,
        price: product.price,
        category: product.category,
        colors: product.colors,
        rating: product.rating,
        reviews: product.reviews,
        imageUrl: product.imageUrl,
      );

      _products.add(newProduct);
      return true;
    } catch (e) {
      debugPrint("Error adding product: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> _searchResults = [];

  List<ProductModel> get searchResults => List.unmodifiable(_searchResults);

  void searchProducts({required String query}) {
    if (query.trim().isEmpty) {
      _searchResults = products;
      notifyListeners();
      return;
    }

    final search = query.toLowerCase().trim();

    _searchResults = products.where((product) {
      return product.name.toLowerCase().contains(search) ||
          product.category.toLowerCase().contains(search) ||
          product.description.toLowerCase().contains(search) ||
          product.maker.toLowerCase().contains(search);
    }).toList();

    notifyListeners();
  }
}
