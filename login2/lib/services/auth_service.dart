import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AuthService {
  final String baseUrl = "http://52.90.111.225:8081/api/cal/auth";
  final String _tokenKey = 'auth_token';

  // Get token from SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Save token to SharedPreferences
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Clear token from SharedPreferences
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Print debug info about response
  void _debugResponse(String endpoint, http.Response response) {
    debugPrint('===== API Response: $endpoint =====');
    debugPrint('Status Code: ${response.statusCode}');
    debugPrint('Headers: ${response.headers}');
    debugPrint('Body: ${response.body}');
    
    try {
      final json = jsonDecode(response.body);
      debugPrint('JSON keys: ${json.keys.toList()}');
      if (json is Map<String, dynamic>) {
        json.forEach((key, value) {
          debugPrint('$key: ${value.runtimeType} - $value');
        });
      }
    } catch (e) {
      debugPrint('Error decoding JSON: $e');
    }
    
    debugPrint('=====================================');
  }

  // Find token in different response formats
  String? _extractToken(Map<String, dynamic> data) {
    // Check direct token field
    if (data.containsKey('token')) {
      return data['token'];
    }
    
    // Check for nested token
    if (data.containsKey('data') && data['data'] is Map) {
      final dataMap = data['data'] as Map<String, dynamic>;
      if (dataMap.containsKey('token')) {
        return dataMap['token'];
      }
    }
    
    // Check for auth object
    if (data.containsKey('auth') && data['auth'] is Map) {
      final authMap = data['auth'] as Map<String, dynamic>;
      if (authMap.containsKey('token')) {
        return authMap['token'];
      }
    }

    // Check for authorization token
    if (data.containsKey('authorization')) {
      return data['authorization'];
    }

    // Check for access_token
    if (data.containsKey('access_token')) {
      return data['access_token'];
    }
    
    return null;
  }

  Future<LoginResponse> login(String email, String password) async {
    try {
      final loginRequest = LoginRequest(email: email, password: password);
      
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(loginRequest.toJson()),
      );
      
      // Debug response
      _debugResponse('login', response);
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Extract token with fallback method
        final token = _extractToken(data);
        
        if (token != null) {
          // Save token to SharedPreferences
          await saveToken(token);
          
          // If user data is returned
          User? user;
          if (data.containsKey('user')) {
            user = User.fromJson(data['user']);
          } else if (data.containsKey('data') && data['data'] is Map) {
            final dataMap = data['data'] as Map<String, dynamic>;
            if (dataMap.containsKey('user')) {
              user = User.fromJson(dataMap['user']);
            }
          }
          
          return LoginResponse(
            success: true,
            token: token,
            user: user,
          );
        } else {
          // If we can't find the token but the response is successful,
          // save the entire response body as token (hacky but might work)
          if (response.body.isNotEmpty) {
            await saveToken(response.body);
            return LoginResponse(
              success: true,
              token: response.body,
              message: 'Token guardado desde cuerpo de respuesta',
            );
          }
          return LoginResponse.error('Token not found in response. Revise la estructura de la respuesta de la API.');
        }
      } else {
        final message = data.containsKey('message') 
            ? data['message'] 
            : 'Authentication failed';
        return LoginResponse.error(message);
      }
    } catch (e) {
      return LoginResponse.error('Error: ${e.toString()}');
    }
  }

  Future<RegisterResponse> register(String email, String password) async {
    try {
      final registerRequest = RegisterRequest(email: email, password: password);
      
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(registerRequest.toJson()),
      );
      
      // Debug response
      _debugResponse('register', response);
      
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        // If user data is returned
        User? user;
        if (data.containsKey('user')) {
          user = User.fromJson(data['user']);
        } else if (data.containsKey('data') && data['data'] is Map) {
          final dataMap = data['data'] as Map<String, dynamic>;
          if (dataMap.containsKey('user')) {
            user = User.fromJson(dataMap['user']);
          }
        }
        
        return RegisterResponse(
          success: true,
          user: user,
        );
      } else {
        final message = data.containsKey('message') 
            ? data['message'] 
            : 'Registration failed';
        return RegisterResponse.error(message);
      }
    } catch (e) {
      return RegisterResponse.error('Error: ${e.toString()}');
    }
  }

  // Logout user
  Future<void> logout() async {
    await clearToken();
  }

  // Get authenticated http client with token
  Future<http.Client> getAuthClient() async {
    final client = http.Client();
    final token = await getToken();
    if (token != null) {
      return _AuthClient(client, token);
    }
    return client;
  }
}

// Custom HTTP client that adds the auth token to all requests
class _AuthClient extends http.BaseClient {
  final http.Client _inner;
  final String _token;

  _AuthClient(this._inner, this._token);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers['Authorization'] = 'Bearer $_token';
    return _inner.send(request);
  }
}