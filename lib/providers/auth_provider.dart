import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  bool _loading = false;
  bool get loading => _loading;

  String? _token;
  String? get token => _token;

  bool _isCheckingAuth = true;
  bool get isCheckingAuth => _isCheckingAuth;

  Map<String, dynamic>? _profile;
  Map<String, dynamic>? get profile => _profile;

  Future<void> checkAuth() async {
    _token = await _storage.read(key: 'accessToken');

    _isCheckingAuth = false;
    notifyListeners();
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
        final data = jsonDecode(response.body);
        final accessToken = data["accessToken"];
        await _storage.write(key: "accessToken", value: accessToken);
        _token = accessToken;
        notifyListeners();
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

  Future<String?> getToken() async {
    return await _storage.read(key: "accessToken");
  }

  Future<bool> getProfile() async {
    try {
      final accessToken = await _storage.read(key: "accessToken");
      if (accessToken == null) {
        return false;
      }
      final response = await http.get(
        Uri.parse('https://dummyjson.com/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _profile = data as Map<String, dynamic>;
        _token = accessToken;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: "accessToken");
    _token = null;
    _profile = null;
    notifyListeners();
  }
}
