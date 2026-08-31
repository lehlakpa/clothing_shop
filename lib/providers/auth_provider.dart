import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  bool _loading = false;
  bool get loading => _loading;
  String? _token;
  bool _isCheckingAuth = true;
  String? get token => _token;
  bool get isCheckingAuth => _isCheckingAuth;

  Future<void> checkAuth() async {
    _token = await _storage.read(key: 'accessToken');

    _isCheckingAuth = false;
    notifyListeners();
  }

  // Future<void> saveToken(String token) async {
  //   await _storage.write(key: 'accessToken', value: token);

  //   _token = token;
  //   notifyListeners();
  // }

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
        return true;
      }
      return true;
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

  Future<void> logout() async {
    await _storage.delete(key: "accessToken");
  }
}
