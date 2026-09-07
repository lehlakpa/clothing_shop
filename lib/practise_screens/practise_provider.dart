import 'dart:convert';

import 'package:clothing_shop/models/product.dart';
import 'package:clothing_shop/practise_screens/api_exception.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class PractiseProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String? _token;
  bool _loading = false;
  bool _authChecked = false;

  Map<String, dynamic>? profile;
  List<Product> products = [];

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _loading;

  bool get authChecked => _authChecked;

  Future<bool> checkAuthStatus() async {
    _token = await _storage.read(key: "accessToken");
    _authChecked = true;
    notifyListeners();
    return isLoggedIn;
  }

  Future<bool> login(String username, String password) async {
    _loading = true;
    notifyListeners();
    try {
      final response = await http.post(
        Uri.parse('https://dummyjson.com/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": username,
          "password": password,
          "expiresInMins": 30,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final accessToken = data["accessToken"] as String;
        await _storage.write(key: "accessToken", value: accessToken);
        _token = accessToken;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "accessToken");
    _token = null;
    profile = null;
    products = [];
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getProfile() async {
    if (_token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      switch (response.statusCode) {
        case 200:
          profile = jsonDecode(response.body) as Map<String, dynamic>;
          notifyListeners();
          return profile;
        case 401:
          await logout();
          return null;
        default:
          throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse("https://dummyjson.com/products"),
        headers: {'Content-Type': 'application/json'},
      );
      switch (response.statusCode) {
        case 200:
          final data = jsonDecode(response.body);
          products = (data['products'] as List)
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
          notifyListeners();
          return products;
        case 400:
          throw Exception('Bad Request');
        case 401:
          throw Exception("Unauthorized");
        case 404:
          throw Exception('Products not found');
        case 500:
          throw Exception('Server error');
        case 503:
          throw Exception('Server unavailable');
        default:
          throw Exception('Unexpected error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception("Something went wrong: $e");
    }
  }
}
