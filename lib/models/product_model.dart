class ProductModel {
  final String id;
  final String name;
  final String maker;
  final String description;
  final double price;
  final String category;
  final List<String> colors;
  final double rating;
  final int reviews;
  final String imageUrl;

  /// Backwards-compatible display name for older product-management screens.
  String get title => name;

  ProductModel({
    this.id = '',
    required this.name,
    required this.maker,
    required this.description,
    required this.price,
    required this.category,
    required this.colors,
    this.rating = 0,
    this.reviews = 0,
    this.imageUrl = '',
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
    // Safe helper to parse double (price, rating)
    double parseDouble(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    // Safe helper to parse int (reviews)
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    // Safe helper to parse colors list
    List<String> parseColors(dynamic val) {
      if (val is List) return List<String>.from(val);
      if (val is String) {
        return val
            .replaceAll('[', '')
            .replaceAll(']', '')
            .replaceAll("'", '')
            .replaceAll('"', '')
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
      return [];
    }

    return ProductModel(
      id: id,
      name: map['name']?.toString() ?? '',
      maker: map['maker']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: parseDouble(map['price']),
      category: map['category']?.toString() ?? '',
      colors: parseColors(map['colors']),
      rating: parseDouble(map['rating']),
      reviews: parseInt(map['reviews']),
      imageUrl: map['imageUrl']?.toString() ?? '',
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'maker': maker,
      'description': description,
      'price': price,
      'category': category,
      'colors': colors,
      'rating': rating,
      'reviews': reviews,
      'imageUrl': imageUrl,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? maker,
    String? description,
    double? price,
    String? category,
    List<String>? colors,
    double? rating,
    int? reviews,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      maker: maker ?? this.maker,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      colors: colors ?? this.colors,
      rating: rating ?? this.rating,
      reviews: reviews ?? this.reviews,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
