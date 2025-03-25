import 'dart:convert';
import 'package:http/http.dart' as http;
class AuthService {
final String baseUrl = "http://52.90.111.225:8081/api/cal/auth"; Future<bool> login(String email, String password) async {final response = await http.post(
Uri.parse("$baseUrl/login"),
headers: {"Content-Type": "application/json"},
body: jsonEncode({"email": email, "password": password}), );
return response.statusCode == 200;
}
Future<bool> register(String email, String password) async { final response = await http.post(
Uri.parse("$baseUrl/register"),
headers: {"Content-Type": "application/json"},
body: jsonEncode({"email": email, "password": password}), );
return response.statusCode == 201; }
}