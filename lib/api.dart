import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Indirizzo del server:
// - Emulatore Android: 10.0.2.2 (alias del PC che ospita l'emulatore)
// - Telefono vero: IP del PC nella stessa rete Wi-Fi, es. http://192.168.1.20:3000
const String baseUrl = 'http://10.0.2.2:3000';

// Toglie la scritta "Exception: " dai messaggi d'errore
String errorText(Object e) => e.toString().replaceFirst('Exception: ', '');

// Tutte le chiamate al server sono qui, così le schermate restano semplici.
class Api {
  static String? token; // null = nessuna azienda loggata
  static bool get isLoggedIn => token != null;

  // Legge il token salvato sul telefono (resta anche dopo la chiusura dell'app)
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
  }

  static Future<void> _setToken(String? value) async {
    final prefs = await SharedPreferences.getInstance();
    token = value;
    if (value == null) {
      await prefs.remove('token');
    } else {
      await prefs.setString('token', value);
    }
  }

  static Map<String, String> _headers({bool auth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (auth && token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Trasforma la risposta HTTP in dati Dart, oppure lancia un errore
  static dynamic _decode(http.Response res) {
    final body = res.body.isEmpty ? null : jsonDecode(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body;
    }
    if (body is Map && body['error'] != null) {
      throw Exception(body['error']);
    }
    throw Exception('Errore del server (${res.statusCode})');
  }

  // R1 - Registrazione
  static Future<void> register(String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/register'),
      headers: _headers(),
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    _decode(res);
  }

  // R2 - Login: il server risponde con un token che salviamo
  static Future<void> login(String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/api/login'),
      headers: _headers(),
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = _decode(res);
    await _setToken(data['token']);
  }

  // R3 - Logout: avvisa il server e cancella il token dal telefono
  static Future<void> logout() async {
    try {
      await http.post(Uri.parse('$baseUrl/api/logout'), headers: _headers(auth: true));
    } catch (_) {
      // anche se il server non risponde, in locale usciamo comunque
    }
    await _setToken(null);
  }
}