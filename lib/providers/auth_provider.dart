import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Asegúrate de poner los imports al inicio

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    _isAuthenticated = await _authService.login(email, password);
    notifyListeners();
    return _isAuthenticated;
  }

  Future<bool> register(String email, String password) async {
    return await _authService.register(email, password);
  }
}

Future<void> saveSession(String email) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('user_email', email);
}

Future<String?> getSession() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('user_email');
}
