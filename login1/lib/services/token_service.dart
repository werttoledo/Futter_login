import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_login.dart';

class TokenService {
  static const String baseUrl = "http://52.90.111.225:8081/api/cal/auth";
  static const String _tokenKey = 'user_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Obtener token de SharedPreferences
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Guardar token en SharedPreferences
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Guardar refresh token (si lo proporciona la API)
  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  // Obtener refresh token
  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // Limpiar token de SharedPreferences
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  // Verificar si el usuario está logueado
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Realizar login y obtener token
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": username,
          "password": password
        }),
      );

      // Imprimir respuesta para depuración
      print('Login response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Buscar token en varias posibles ubicaciones en la respuesta
        String? token = _extractTokenFromResponse(data);
        
        if (token != null) {
          // Guardar token
          await saveToken(token);
          
          // Buscar refresh token si existe
          if (data['refreshToken'] != null) {
            await saveRefreshToken(data['refreshToken']);
          }
          
          // Crear y guardar UserLogin
          final user = UserLogin(
            username: username,
            password: password, // Considera no almacenar la contraseña
            token: token,
          );
          
          await user.saveToPrefs();
          
          return {
            'success': true,
            'message': 'Login exitoso',
            'token': token,
          };
        } else {
          // Si la respuesta es exitosa pero no encontramos el token,
          // guardamos la respuesta completa como token (solución temporal)
          await saveToken(response.body);
          
          return {
            'success': true,
            'message': 'Token guardado desde la respuesta',
            'token': response.body,
          };
        }
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Error de autenticación',
        };
      }
    } catch (e) {
      print('Error en login: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }

  // Método auxiliar para extraer token de diferentes formatos de respuesta
  static String? _extractTokenFromResponse(dynamic data) {
    if (data is Map) {
      // Verificar diferentes ubicaciones posibles del token
      if (data['token'] != null) return data['token'];
      if (data['accessToken'] != null) return data['accessToken'];
      if (data['access_token'] != null) return data['access_token'];
      if (data['auth_token'] != null) return data['auth_token'];
      
      // Buscar en objeto data anidado
      if (data['data'] is Map) {
        final dataObj = data['data'];
        if (dataObj['token'] != null) return dataObj['token'];
        if (dataObj['accessToken'] != null) return dataObj['accessToken'];
      }
      
      // Buscar en objeto auth anidado
      if (data['auth'] is Map) {
        final authObj = data['auth'];
        if (authObj['token'] != null) return authObj['token'];
      }
    }
    
    return null;
  }

  // Obtener cliente http con token de autorización
  static Future<http.Client> getAuthClient() async {
    final client = http.Client();
    final token = await getToken();
    
    if (token != null) {
      return _AuthClient(client, token);
    }
    
    return client;
  }

  // Realizar registro
  static Future<Map<String, dynamic>> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": username,
          "password": password
        }),
      );

      print('Register response: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Registro exitoso',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Error en el registro',
        };
      }
    } catch (e) {
      print('Error en registro: $e');
      return {
        'success': false,
        'message': 'Error: ${e.toString()}',
      };
    }
  }
}

// Cliente HTTP personalizado que añade el token a cada solicitud
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