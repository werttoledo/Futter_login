import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/models.dart';
import 'auth_service.dart';

class PurchaseService {
  final String baseUrl = "http://52.90.111.225:8081/api/cal";
  final AuthService _authService = AuthService();

  // Create a new purchase
  Future<PurchaseResponse> createPurchase(PurchaseRequest request) async {
    try {
      // Get token
      final token = await _authService.getToken();
      if (token == null) {
        return PurchaseResponse.error('No authentication token found');
      }

      final response = await http.post(
        Uri.parse("$baseUrl/purchases"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode(request.toJson()),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final purchase = Purchase.fromJson(data);
        return PurchaseResponse.success(purchase);
      } else {
        final message = data.containsKey('message')
            ? data['message']
            : 'Failed to create purchase';
        return PurchaseResponse.error(message);
      }
    } catch (e) {
      return PurchaseResponse.error('Error: ${e.toString()}');
    }
  }

  // Get all purchases for the current user
  Future<PurchaseListResponse> getPurchases() async {
    try {
      // Get token
      final token = await _authService.getToken();
      if (token == null) {
        return PurchaseListResponse.error('No authentication token found');
      }

      final response = await http.get(
        Uri.parse("$baseUrl/purchases"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (data.containsKey('data') && data['data'] is List) {
          final List<Purchase> purchases = (data['data'] as List)
              .map((item) => Purchase.fromJson(item))
              .toList();
          return PurchaseListResponse.success(purchases);
        } else {
          return PurchaseListResponse.success([]);
        }
      } else {
        final message = data.containsKey('message')
            ? data['message']
            : 'Failed to get purchases';
        return PurchaseListResponse.error(message);
      }
    } catch (e) {
      return PurchaseListResponse.error('Error: ${e.toString()}');
    }
  }

  // Get a specific purchase by ID
  Future<PurchaseResponse> getPurchaseById(String id) async {
    try {
      // Get token
      final token = await _authService.getToken();
      if (token == null) {
        return PurchaseResponse.error('No authentication token found');
      }

      final response = await http.get(
        Uri.parse("$baseUrl/purchases/$id"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final purchase = Purchase.fromJson(data);
        return PurchaseResponse.success(purchase);
      } else {
        final message = data.containsKey('message')
            ? data['message']
            : 'Failed to get purchase';
        return PurchaseResponse.error(message);
      }
    } catch (e) {
      return PurchaseResponse.error('Error: ${e.toString()}');
    }
  }
} 