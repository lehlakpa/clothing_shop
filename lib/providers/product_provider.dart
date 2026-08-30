// import 'package:clothing_shop/models/product_model.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/widgets.dart';

// class ProductProvider extends ChangeNotifier {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//   List<ProductModel> _products = [];
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;

//   List<ProductModel> get products => _products;
//   Future<void> addProduct({
//     required String title,
//     required String description,
//     required double price,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();
//       await _firestore.collection("products").add({
//         "title": title,
//         "description": description,
//         "price": price,
//       });
//     } catch (e) {
//       throw Exception("Product Upload failed: $e");
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }

//   Future<void> fetchproducts() async {
//     try {
//       final snapshot = await _firestore.collection("products").get();
//       _products = snapshot.docs.map((doc) {
//         return ProductModel.fromMap(doc.data(), doc.id);
//       }).toList();
//       notifyListeners();
//     } catch (e) {
//       throw Exception("failed to load ");
//     }
//   }

//   Future<void> deleteProduct(String id) async {
//     try {
//       await _firestore.collection('products').doc(id).delete();

//       _products.removeWhere((product) => product.id == id);

//       notifyListeners();
//     } catch (e) {
//       debugPrint('Delete Product Error: $e');
//     }
//   }

//   Future<void> updateProduct({
//     required String id,
//     required String title,
//     required String description,
//     required double price,
//   }) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       await _firestore.collection('products').doc(id).update({
//         'title': title,
//         'description': description,
//         'price': price,
//       });
//     } catch (e) {
//       debugPrint('Update Product Error: $e');
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<ProductModel> _products = [];
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> fetchproducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('products').get();
      _products
        ..clear()
        ..addAll(snapshot.docs.map(
          (doc) => ProductModel.fromMap(doc.data(), doc.id),
        ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ProductModel>> productsStream() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add({
      ...product.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProduct(ProductModel product) async {
    await _firestore
        .collection('products')
        .doc(product.id)
        .update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _firestore.collection('products').doc(id).delete();
  }
}
