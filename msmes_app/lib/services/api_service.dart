import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator

  // Signup using dynamic data from a map
  static Future<bool> signupFromMap(Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        developer.log("Signup failed: ${response.body}");
        return false;
      }
    } catch (e) {
      developer.log("Error during signup: $e");
      return false;
    }
  }

  // Login method
  static Future<bool> login({
    required String phone,
    required String password,
  }) async {
    final url = Uri.parse('$baseUrl/api/auth/login/');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'phone_number': phone, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        developer.log('Login success: $data');
        // Store token or user info here
        return true;
      } else {
        developer.log('Login failed: ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('Error during login: $e');
      return false;
    }
  }
}
