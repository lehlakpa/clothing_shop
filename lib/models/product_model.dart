// class ProductModel {
//   final String id;
//   final String title;
//   final String description;
//   final double price;

//   ProductModel({
//     this.id = '',
//     required this.title,
//     required this.description,
//     required this.price,
//   });

//   factory ProductModel.fromMap(Map<String, dynamic> map, String id) {
//     return ProductModel(
//       id: id,
//       title: map['title'] ?? '',
//       description: map['description'] ?? '',
//       price: (map['price'] ?? 0).toDouble(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {'title': title, 'description': description, 'price': price};
//   }
// }
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
    return ProductModel(
      id: id,
      name: map['name'] ?? '',
      maker: map['maker'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      category: map['category'] ?? '',
      colors: List<String>.from(map['colors'] ?? []),
      rating: (map['rating'] ?? 0).toDouble(),
      reviews: map['reviews'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
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
}
