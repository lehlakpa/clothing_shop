import 'package:clothing_shop/services/cloudinary_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
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

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  /// Add a new product to Firestore
  Future<bool> addProduct(ProductModel product, XFile image) async {
    _isLoading = true;
    notifyListeners();

    try {
      final String? imageUrl = await CloudinaryService.uploadImage(image);
      if (imageUrl == null) {
        return false;
      }

      final productData = product.toMap();
      productData['imageUrl'] = imageUrl;
      productData['createdAt'] = FieldValue.serverTimestamp();

      // Firestore automatically generates a unique Document ID
      final docRef = await _firestore
          .collection('products')
          .add(productData);

      // Also log the uploaded image URL into the uploaded_images tracking collection in Firestore
      await _firestore.collection('uploaded_images').add({
        'imageUrl': imageUrl,
        'fileName': image.name,
        'productId': docRef.id,
        'productName': product.name,
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      // Update the local product instance with the newly created ID and Cloudinary URL
      final newProduct = product.copyWith(
        id: docRef.id,
        imageUrl: imageUrl,
      );

      _products.add(newProduct);
      notifyListeners();
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

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  List<ProductModel> getFilteredProducts({String? query, String? category}) {
    final cat = category ?? _selectedCategory;
    final q = (query ?? '').toLowerCase().trim();

    return _products.where((product) {
      final matchesCategory = cat == 'All' ||
          product.category.trim().toLowerCase() == cat.trim().toLowerCase();

      final matchesQuery = q.isEmpty ||
          product.name.toLowerCase().contains(q) ||
          product.category.toLowerCase().contains(q) ||
          product.description.toLowerCase().contains(q) ||
          product.maker.toLowerCase().contains(q);

      return matchesCategory && matchesQuery;
    }).toList();
  }

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
