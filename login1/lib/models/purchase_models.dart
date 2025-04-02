import 'auth_models.dart';

// Purchase Request
class PurchaseRequest {
  final String description;
  final int amountInCents;

  PurchaseRequest({
    required this.description,
    required this.amountInCents,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amountInCents': amountInCents,
    };
  }
}

// Purchase Status
enum PurchaseStatus {
  CREATED,
  PENDING,
  APPROVED,
  REJECTED,
  CANCELLED
}

// Extension for string conversion
extension PurchaseStatusExtension on PurchaseStatus {
  String toShortString() {
    return toString().split('.').last;
  }

  static PurchaseStatus fromString(String status) {
    return PurchaseStatus.values.firstWhere(
      (e) => e.toShortString() == status,
      orElse: () => PurchaseStatus.CREATED,
    );
  }
}

// Purchase model
class Purchase {
  final String id;
  final User user;
  final String description;
  final int amountInCents;
  final PurchaseStatus status;
  final String? reference;
  final DateTime createdAt;
  final DateTime updatedAt;

  Purchase({
    required this.id,
    required this.user,
    required this.description,
    required this.amountInCents,
    required this.status,
    this.reference,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      user: User.fromJson(json['user']),
      description: json['description'],
      amountInCents: json['amountInCents'],
      status: PurchaseStatusExtension.fromString(json['status']),
      reference: json['reference'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'description': description,
      'amountInCents': amountInCents,
      'status': status.toShortString(),
      'reference': reference,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Format amount for display
  String formattedAmount() {
    final dollars = amountInCents / 100;
    return '\$${dollars.toStringAsFixed(2)}';
  }
}

// Purchase Response
class PurchaseResponse {
  final bool success;
  final String? message;
  final Purchase? purchase;

  PurchaseResponse({
    required this.success,
    this.message,
    this.purchase,
  });

  factory PurchaseResponse.fromJson(Map<String, dynamic> json) {
    return PurchaseResponse(
      success: json['success'] ?? true,
      message: json['message'],
      purchase: json.containsKey('id') ? Purchase.fromJson(json) : null,
    );
  }

  factory PurchaseResponse.success(Purchase purchase) {
    return PurchaseResponse(
      success: true,
      purchase: purchase,
    );
  }

  factory PurchaseResponse.error(String message) {
    return PurchaseResponse(
      success: false,
      message: message,
    );
  }
}

// Purchase List Response
class PurchaseListResponse {
  final bool success;
  final String? message;
  final List<Purchase>? purchases;

  PurchaseListResponse({
    required this.success,
    this.message,
    this.purchases,
  });

  factory PurchaseListResponse.fromJson(Map<String, dynamic> json) {
    List<Purchase>? purchaseList;
    if (json.containsKey('data') && json['data'] is List) {
      purchaseList = (json['data'] as List)
          .map((item) => Purchase.fromJson(item))
          .toList();
    }

    return PurchaseListResponse(
      success: json['success'] ?? true,
      message: json['message'],
      purchases: purchaseList,
    );
  }

  factory PurchaseListResponse.success(List<Purchase> purchases) {
    return PurchaseListResponse(
      success: true,
      purchases: purchases,
    );
  }

  factory PurchaseListResponse.error(String message) {
    return PurchaseListResponse(
      success: false,
      message: message,
    );
  }
} 