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
