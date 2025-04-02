import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/token_service.dart';
import '../models/models.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String purchaseInfo = "Presiona el botón para realizar una compra";
  bool isLoading = false;
  bool showToken = false;
  String? currentToken;
  UserLogin? currentUser;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Cargar token
    final token = await TokenService.getToken();
    
    // Cargar información del usuario
    final user = await UserLogin.loadFromPrefs();
    
    setState(() {
      currentToken = token;
      currentUser = user;
    });
  }

  Future<void> _checkAuthentication() async {
    final isLoggedIn = await TokenService.isLoggedIn();
    if (!isLoggedIn) {
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  Future<void> _logout() async {
    await TokenService.clearToken();
    await UserLogin.logout();
    Navigator.pushReplacementNamed(context, "/login");
  }

  Future<void> makePurchase() async {
    if (currentToken == null) {
      setState(() {
        purchaseInfo = "❌ Error: No hay token de autenticación";
      });
      return;
    }

    setState(() => isLoading = true);

    try {
      // Crear petición de compra
      final purchaseRequest = {
        "description": "Compra de prueba",
        "amountInCents": 50000
      };
      
      // Hacer llamada al API manualmente
      final url = Uri.parse("http://52.90.111.225:8081/api/cal/purchases");
      final response = await http.post(
        url,
        headers: {
          "Authorization": "Bearer $currentToken",
          "Content-Type": "application/json"
        },
        body: jsonEncode(purchaseRequest),
      );
      
      // Para depuración
      print('Purchase response status: ${response.statusCode}');
      print('Purchase response body: ${response.body}');

      setState(() {
        isLoading = false;
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          try {
            final data = jsonDecode(response.body);
            purchaseInfo = """
            ✅ Compra realizada con éxito
            📌 ID: ${data['id'] ?? 'N/A'}
            📧 Usuario: ${data['user']?['email'] ?? currentUser?.username ?? 'N/A'}
            🛒 Descripción: ${data['description'] ?? 'Compra de prueba'}
            💲 Monto: \$${(data['amountInCents'] ?? 50000) / 100}
            🔄 Estado: ${data['status'] ?? 'CREATED'}
            📅 Fecha: ${data['createdAt'] ?? DateTime.now().toString()}
            🔢 Referencia: ${data['reference'] ?? 'N/A'}
            """;
          } catch (e) {
            purchaseInfo = """
            ✅ Compra realizada con éxito
            Pero hubo un error al procesar la respuesta: $e
            Respuesta recibida: ${response.body}
            """;
          }
        } else {
          purchaseInfo = "⚠️ Error en la compra (${response.statusCode}): ${response.body}";
        }
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        purchaseInfo = "❌ Error de conexión: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          "Compra en Línea", 
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )
        ),
        backgroundColor: Color(0xFF0091AD),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.visibility, color: Colors.white),
            onPressed: () {
              setState(() {
                showToken = !showToken;
              });
            },
            tooltip: "Mostrar/Ocultar Token",
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadUserData,
            tooltip: "Recargar datos",
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _logout,
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFE6F8F9), // Fondo con tono turquesa sutil
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (currentUser != null)
                Card(
                  elevation: 4,
                  margin: EdgeInsets.only(bottom: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color(0xFFE6F8F9),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF00AFC1),
                                    Color(0xFF0091AD),
                                  ],
                                ),
                              ),
                              child: Icon(Icons.person, color: Colors.white, size: 28),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Usuario conectado",
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    currentUser!.username,
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0081A7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (showToken && currentToken != null) ...[
                          Divider(height: 30, thickness: 1),
                          Text(
                            "Token de autenticación:",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0081A7),
                            ),
                          ),
                          SizedBox(height: 10),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF00AFC1).withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              currentToken!.length > 100 
                                  ? '${currentToken!.substring(0, 100)}...' 
                                  : currentToken!,
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'monospace',
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF00AFC1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.shopping_cart,
                  size: 70,
                  color: Color(0xFF0091AD),
                ),
              ),
              SizedBox(height: 24),
              Text(
                "Realiza tu compra de manera segura",
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20, 
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0081A7),
                ),
              ),
              SizedBox(height: 24),
              isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0091AD)),
                    )
                  : Container(
                      width: double.infinity,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF00C2BA),
                            Color(0xFF0091AD),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF0091AD).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: makePurchase,
                        icon: Icon(Icons.payment, size: 22, color: Colors.black),
                        label: Text(
                          "Realizar Compra",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: 24),
              Expanded(
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Color(0xFFE6F8F9),
                        ],
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Color(0xFF0091AD),
                              ),
                              SizedBox(width: 8),
                              Text(
                                "Información de Compra",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0081A7),
                                ),
                              ),
                            ],
                          ),
                          Divider(),
                          SizedBox(height: 8),
                          Text(
                            purchaseInfo,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}