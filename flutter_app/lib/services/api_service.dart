import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  static Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(res.body);
      if (res.statusCode == 201 || res.statusCode == 200) {
        return {'success': true, 'user': data['user']};
      }
      return {'success': false, 'message': data['error'] ?? 'Erro ao cadastrar'};
    } catch (_) {
      return {'success': false, 'message': 'Servidor indisponível. Inicie o backend (npm start).'};
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      ).timeout(const Duration(seconds: 5));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return {'success': true, 'user': data['user'], 'token': data['token']};
      }
      return {'success': false, 'message': data['error'] ?? 'Credenciais inválidas'};
    } catch (_) {
      return {'success': false, 'message': 'Servidor indisponível. Inicie o backend (npm start).'};
    }
  }

  static Future<Map<String, dynamic>?> fetchFridgeStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/fridge')).timeout(const Duration(seconds: 3));
      if (res.statusCode == 200) return jsonDecode(res.body);
    } catch (_) {}
    return null;
  }

  static Future<void> updateFridgeTemperature(double temp) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/fridge/temperature'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'temperature': temp}),
      ).timeout(const Duration(seconds: 3));
    } catch (_) {}
  }

  static Future<void> saveSkinQuiz({
    required String email,
    required String skinType,
    required String skinGoal,
  }) async {
    try {
      await http.post(
        Uri.parse('$baseUrl/user/quiz'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'skinType': skinType, 'skinGoal': skinGoal}),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {}
  }
}
