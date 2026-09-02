import 'dart:convert';

import 'package:clothing_shop/constants/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  static String get uploadPreset => Constants.uploadPreset;
  static String get cloudName => Constants.cloudName;

  /// Uploads an image file to Cloudinary and returns the secure URL.
  static Future<String?> uploadImage(XFile image) async {
    try {
      // Read image as bytes.
      final Uint8List bytes = await image.readAsBytes();

      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
      );

      final request = http.MultipartRequest('POST', uri);

      request.fields['upload_preset'] = uploadPreset;

      // XFile works on Web + Android + iOS.
      request.files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: image.name),
      );

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);

        return data['secure_url'];
      }

      debugPrint('Cloudinary error: ${response.statusCode}');
      debugPrint(response.body);

      return null;
    } catch (e) {
      debugPrint('Cloudinary error: $e');

      return null;
    }
  }

  /// Uploads image to Cloudinary and persists the URL and metadata to Firestore database.
  static Future<Map<String, dynamic>?> uploadAndSaveImage(
    XFile image, {
    String collection = 'uploaded_images',
    Map<String, dynamic>? additionalData,
  }) async {
    final imageUrl = await uploadImage(image);
    if (imageUrl == null) return null;

    try {
      final docData = <String, dynamic>{
        'imageUrl': imageUrl,
        'fileName': image.name,
        'fileSizeBytes': await image.length(),
        'uploadedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      final docRef = await FirebaseFirestore.instance
          .collection(collection)
          .add(docData);

      return {
        'docId': docRef.id,
        'imageUrl': imageUrl,
        'fileName': image.name,
      };
    } catch (e) {
      debugPrint('Firestore save error: $e');
      return {
        'docId': null,
        'imageUrl': imageUrl,
        'fileName': image.name,
      };
    }
  }

  /// Stores an existing image URL and metadata into Firestore database.
  static Future<String?> saveImageUrlToFirestore({
    required String imageUrl,
    String? fileName,
    String collection = 'uploaded_images',
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final docData = <String, dynamic>{
        'imageUrl': imageUrl,
        'fileName': fileName ?? 'image_${DateTime.now().millisecondsSinceEpoch}',
        'uploadedAt': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      final docRef = await FirebaseFirestore.instance
          .collection(collection)
          .add(docData);

      return docRef.id;
    } catch (e) {
      debugPrint('Firestore save error: $e');
      return null;
    }
  }
}

