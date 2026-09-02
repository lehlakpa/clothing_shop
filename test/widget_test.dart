import 'package:clothing_shop/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProductModel serialization and copyWith with Cloudinary URL', () {
    final product = ProductModel(
      id: 'hoodie_01',
      name: 'Oversized Heavyweight Hoodie',
      maker: 'Studio Kioo',
      description: 'Handmade organic cotton hoodie',
      price: 65.0,
      category: 'Hoodies',
      colors: const ['#1B1D18', '#223B2E'],
      rating: 4.9,
      reviews: 24,
      imageUrl: '',
    );

    expect(product.imageUrl, '');

    // Test copyWith attaching uploaded Cloudinary URL
    const cloudinaryUrl =
        'https://res.cloudinary.com/dglxnraim/image/upload/v12345/product.jpg';
    final updatedProduct = product.copyWith(imageUrl: cloudinaryUrl);

    expect(updatedProduct.imageUrl, cloudinaryUrl);
    expect(updatedProduct.name, 'Oversized Heavyweight Hoodie');

    // Test serialization to map
    final map = updatedProduct.toMap();
    expect(map['imageUrl'], cloudinaryUrl);
    expect(map['category'], 'Hoodies');
    expect(map['price'], 65.0);

    // Test deserialization from map
    final parsed = ProductModel.fromMap(map, 'hoodie_01');
    expect(parsed.imageUrl, cloudinaryUrl);
    expect(parsed.name, 'Oversized Heavyweight Hoodie');
    expect(parsed.colors.length, 2);
  });
}
