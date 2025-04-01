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
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Compra en Línea", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.visibility),
            onPressed: () {
              setState(() {
                showToken = !showToken;
              });
            },
            tooltip: "Mostrar/Ocultar Token",
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUserData,
            tooltip: "Recargar datos",
          ),
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _logout,
            tooltip: "Cerrar sesión",
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (currentUser != null)
              Card(
                elevation: 5,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.deepPurple[100],
                            child: Icon(Icons.person, color: Colors.deepPurple),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Usuario conectado",
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                Text(
                                  currentUser!.username,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (showToken && currentToken != null) ...[
                        Divider(height: 24),
                        Text(
                          "Token de autenticación:",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            currentToken!.length > 100 
                                ? '${currentToken!.substring(0, 100)}...' 
                                : currentToken!,
                            style: TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            Icon(Icons.shopping_cart, size: 80, color: Colors.deepPurple),
            SizedBox(height: 20),
            Text(
              "Realiza tu compra de manera segura",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator(color: Colors.deepPurple)
                : ElevatedButton.icon(
                    onPressed: makePurchase,
                    icon: Icon(Icons.payment),
                    label: Text("Realizar Compra"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
            SizedBox(height: 20),
            Expanded(
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      purchaseInfo,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}