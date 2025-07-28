import 'package:flutter/material.dart';

class AuthProvider with ChangeNotifier {
  String? _jwtToken;
  String? get jwtToken => _jwtToken;

  void setToken(String token) {
    _jwtToken = token;
    notifyListeners();
  }

  void logout() {
    _jwtToken = null;
    notifyListeners();
  }
} 