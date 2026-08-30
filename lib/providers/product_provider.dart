import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local fallback items in case Firestore is empty or offline
  List<ProductModel> _products = [
    ProductModel(
      name: "Speckled Ceramic Mug",
      maker: "Kinstugi Pottery Co.",
      description:
          "Hand-thrown stoneware mug with a reactive speckled glaze and comfortable grip handle.",
      price: 34.00,
      category: "Ceramics",
      colors: ["Cream", "Sand", "Oatmeal"],
    ),
    ProductModel(
      name: "Handwoven Wool Throw",
      maker: "Atlas Weavers Guild",
      description:
          "Ultra-soft Merino wool blanket ethically hand-woven on traditional wooden looms.",
      price: 120.00,
      category: "Textiles",
      colors: ["Terracotta", "Forest Green", "Charcoal"],
    ),
    ProductModel(
      name: "Carved Walnut Bowl",
      maker: "Timber & Grain Woodcraft",
      description:
          "Sustainably harvested solid black walnut serving bowl finished with food-safe organic oil.",
      price: 68.00,
      category: "Wood",
      colors: ["Dark Walnut", "Natural Grain"],
    ),
    ProductModel(
      name: "Amber Glass Decanter",
      maker: "Solstice Glass Workshop",
      description:
          "Hand-blown amber tinted glass decanter designed for aerating wine or displaying cold drinks.",
      price: 55.00,
      category: "Glass",
      colors: ["Warm Amber", "Smoked Gray"],
    ),
    ProductModel(
      name: "Pendant Lantern Light",
      maker: "Lumen Studio",
      description:
          "Minimalist brass and frosted glass pendant lamp cast to create warm ambient illumination.",
      price: 145.00,
      category: "Light",
      colors: ["Brushed Brass", "Matte Black"],
    ),
    ProductModel(
      name: "Terracotta Flower Vase",
      maker: "Terra Clay House",
      description:
          "Earthy raw clay vase with a waterproof interior coating, ideal for dried or fresh stems.",
      price: 42.00,
      category: "Ceramics",
      colors: ["Rust", "Desert Sand"],
    ),
    ProductModel(
      name: "Linen Table Runner",
      maker: "Heritage Loom Works",
      description:
          "100% organic stonewashed European linen table runner with delicate fringe details.",
      price: 38.00,
      category: "Textiles",
      colors: ["Sage", "Off-White", "Dusty Rose"],
    ),
    ProductModel(
      name: "Oak Serving Board",
      maker: "Timber & Grain Woodcraft",
      description:
          "Heavyweight white oak charcuterie board featuring a hand-sculpted handle and hanging loop.",
      price: 48.00,
      category: "Wood",
      colors: ["Natural Oak"],
    ),
    ProductModel(
      name: "Fluted Glass Tumblers",
      maker: "Solstice Glass Workshop",
      description:
          "Set of 2 ribbed glass tumblers heat-tempered for both hot espresso and iced beverages.",
      price: 28.00,
      category: "Glass",
      colors: ["Clear Glass", "Olive Tint"],
    ),
  ];

  bool _isLoading = false;

  List<ProductModel> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;

  /// Stream real-time updates from Firestore. Falls back to static list if Firestore is empty.
  Stream<List<ProductModel>> productsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return _products; // Return local default list if DB is empty
      }
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList();
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
