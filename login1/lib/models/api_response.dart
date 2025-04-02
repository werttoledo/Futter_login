// Modelo para las respuestas de la API

class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.statusCode,
  });

  // Crear respuesta de éxito
  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  // Crear respuesta de error
  factory ApiResponse.error(String message, {T? data, int? statusCode}) {
    return ApiResponse(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  // Crear desde un Map JSON
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(Map<String, dynamic>)? fromJson) {
    // Determinar si la respuesta fue exitosa basada en diferentes formatos posibles
    bool isSuccess = false;
    if (json.containsKey('success')) {
      isSuccess = json['success'] == true;
    } else if (json.containsKey('status')) {
      isSuccess = json['status'] == 'success' || json['status'] == true;
    } else if (json.containsKey('error')) {
      isSuccess = json['error'] == false;
    }

    // Extraer mensaje si existe
    String? message;
    if (json.containsKey('message')) {
      message = json['message']?.toString();
    } else if (json.containsKey('msg')) {
      message = json['msg']?.toString();
    } else if (json.containsKey('error_message')) {
      message = json['error_message']?.toString();
    }

    // Extraer datos
    T? responseData;
    if (json.containsKey('data') && fromJson != null) {
      try {
        if (json['data'] is Map<String, dynamic>) {
          responseData = fromJson(json['data'] as Map<String, dynamic>);
        }
      } catch (e) {
        print('Error parsing data: $e');
      }
    } else if (fromJson != null) {
      try {
        // Intentar parsear la respuesta completa
        responseData = fromJson(json);
      } catch (e) {
        print('Error parsing response: $e');
      }
    }

    // Extraer código de estado si existe
    int? statusCode;
    if (json.containsKey('statusCode')) {
      statusCode = json['statusCode'] is int ? json['statusCode'] : null;
    } else if (json.containsKey('code')) {
      statusCode = json['code'] is int ? json['code'] : null;
    }

    return ApiResponse(
      success: isSuccess,
      message: message,
      data: responseData,
      statusCode: statusCode,
    );
  }
}

// Modelo para respuestas con token
class TokenResponse {
  final String? token;
  final String? refreshToken;
  final DateTime? expiresAt;
  final Map<String, dynamic>? userData;

  TokenResponse({
    this.token,
    this.refreshToken,
    this.expiresAt,
    this.userData,
  });

  factory TokenResponse.fromJson(Map<String, dynamic> json) {
    // Extraer token de diferentes posibles campos
    String? token;
    if (json.containsKey('token')) {
      token = json['token'];
    } else if (json.containsKey('accessToken')) {
      token = json['accessToken'];
    } else if (json.containsKey('access_token')) {
      token = json['access_token'];
    } else if (json.containsKey('auth_token')) {
      token = json['auth_token'];
    }

    // Extraer refresh token si existe
    String? refreshToken;
    if (json.containsKey('refreshToken')) {
      refreshToken = json['refreshToken'];
    } else if (json.containsKey('refresh_token')) {
      refreshToken = json['refresh_token'];
    }

    // Extraer fecha de expiración si existe
    DateTime? expiresAt;
    if (json.containsKey('expiresAt')) {
      try {
        expiresAt = DateTime.parse(json['expiresAt']);
      } catch (_) {}
    } else if (json.containsKey('expires_at')) {
      try {
        expiresAt = DateTime.parse(json['expires_at']);
      } catch (_) {}
    } else if (json.containsKey('exp')) {
      final exp = json['exp'];
      if (exp is int) {
        // Convertir timestamp a DateTime
        expiresAt = DateTime.fromMillisecondsSinceEpoch(
          exp * 1000, // Multiplicar por 1000 si está en segundos
        );
      }
    }

    // Extraer datos de usuario si existen
    Map<String, dynamic>? userData;
    if (json.containsKey('user')) {
      userData = json['user'] is Map ? json['user'] : null;
    } else if (json.containsKey('userData')) {
      userData = json['userData'] is Map ? json['userData'] : null;
    } else if (json.containsKey('data') && json['data'] is Map && json['data']['user'] is Map) {
      userData = json['data']['user'];
    }

    return TokenResponse(
      token: token,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      userData: userData,
    );
  }
} 