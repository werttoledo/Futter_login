import 'package:shared_preferences/shared_preferences.dart';

class UserLogin {
  // Atributos privados
  String _username;
  String _password;
  String? _token;

  // constructor
  UserLogin({
    required String username,
    required String password,
    String? token,
  }) : _username = username,
       _password = password,
       _token = token;

  // Getters
  String get username => _username;
  String get password => _password;
  String? get token => _token;

  // Setters
  set username(String username) => _username = username;
  set password(String password) => _password = password;
  set token(String? token) => _token = token;

  // Método para crear objeto desde JSON
  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      token: json['token'],
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'username': _username,
      'password': _password,
      'token': _token,
    };
  }

  // Guardar en SharedPreferences
  Future<bool> saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Guardar token
      if (_token != null) {
        await prefs.setString('user_token', _token!);
      }
      
      // Guardar username
      await prefs.setString('username', _username);
      
      // Opcionalmente, puedes guardar la contraseña
      // Nota: Guardar contraseñas en SharedPreferences no es lo más seguro
      // await prefs.setString('password', _password);
      
      return true;
    } catch (e) {
      print('Error guardando user: $e');
      return false;
    }
  }

  // Cargar desde SharedPreferences
  static Future<UserLogin?> loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final token = prefs.getString('user_token');
      final username = prefs.getString('username');
      
      if (username != null) {
        return UserLogin(
          username: username,
          password: '', // No guardamos la contraseña por seguridad
          token: token,
        );
      }
      
      return null;
    } catch (e) {
      print('Error cargando user: $e');
      return null;
    }
  }

  // Verificar si hay un usuario logueado
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('user_token') && prefs.getString('user_token')?.isNotEmpty == true;
    } catch (e) {
      return false;
    }
  }

  // Cerrar sesión
  static Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');
      // Opcionalmente, también puedes eliminar el username
      // await prefs.remove('username');
      return true;
    } catch (e) {
      print('Error en logout: $e');
      return false;
    }
  }
} 