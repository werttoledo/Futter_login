// Authentication-related request and response models

// Login Request
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// Register Request
class RegisterRequest {
  final String email;
  final String password;

  RegisterRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

// User model
class User {
  final String id;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    try {
      // Handle ID which might come with different field names
      String userId = '';
      if (json.containsKey('id')) {
        userId = json['id'].toString();
      } else if (json.containsKey('userId')) {
        userId = json['userId'].toString();
      } else if (json.containsKey('_id')) {
        userId = json['_id'].toString();
      } else if (json.containsKey('uid')) {
        userId = json['uid'].toString();
      }

      // Handle email which might be in different fields
      String userEmail = '';
      if (json.containsKey('email')) {
        userEmail = json['email'];
      } else if (json.containsKey('mail')) {
        userEmail = json['mail'];
      } else if (json.containsKey('username')) {
        userEmail = json['username'];
      }

      // Handle dates which might be in different formats or fields
      DateTime created;
      if (json.containsKey('createdAt')) {
        created = _parseDateTime(json['createdAt']);
      } else if (json.containsKey('created_at')) {
        created = _parseDateTime(json['created_at']);
      } else if (json.containsKey('created')) {
        created = _parseDateTime(json['created']);
      } else {
        created = DateTime.now(); // Fallback
      }

      DateTime updated;
      if (json.containsKey('updatedAt')) {
        updated = _parseDateTime(json['updatedAt']);
      } else if (json.containsKey('updated_at')) {
        updated = _parseDateTime(json['updated_at']);
      } else if (json.containsKey('updated')) {
        updated = _parseDateTime(json['updated']);
      } else {
        updated = DateTime.now(); // Fallback
      }

      return User(
        id: userId,
        email: userEmail,
        createdAt: created,
        updatedAt: updated,
      );
    } catch (e) {
      print('Error parsing User from JSON: $e');
      // Return a fallback user to avoid errors
      return User(
        id: 'unknown',
        email: json['email'] ?? 'unknown@email.com',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // Helper method to parse different date formats
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    } else if (value is int) {
      // Handle Unix timestamp (either in seconds or milliseconds)
      return value > 100000000000 
          ? DateTime.fromMillisecondsSinceEpoch(value) 
          : DateTime.fromMillisecondsSinceEpoch(value * 1000);
    }
    
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// Login Response
class LoginResponse {
  final bool success;
  final String? message;
  final String? token;
  final User? user;

  LoginResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] ?? false,
      message: json['message'],
      token: json['token'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  factory LoginResponse.success(String token, User user) {
    return LoginResponse(
      success: true,
      token: token,
      user: user,
    );
  }

  factory LoginResponse.error(String message) {
    return LoginResponse(
      success: false,
      message: message,
    );
  }
}

// Register Response
class RegisterResponse {
  final bool success;
  final String? message;
  final User? user;

  RegisterResponse({
    required this.success,
    this.message,
    this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  factory RegisterResponse.success(User user) {
    return RegisterResponse(
      success: true,
      user: user,
    );
  }

  factory RegisterResponse.error(String message) {
    return RegisterResponse(
      success: false,
      message: message,
    );
  }
} 