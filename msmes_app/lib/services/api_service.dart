import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.113:8000'; // Physical Device

  // static const String baseUrl = 'http://192.168.184.210:8000'; Hotspot

  // static const String baseUrl = 'http://10.0.2.2:8000'; // Android Emulator

  // static const String baseUrl =
  //     'https://3700-196-189-56-201.ngrok-free.app'; // Ngrok

  // Save both access and refresh tokens
  static Future<void> saveTokens(
    String accessToken,
    String refreshToken,
  ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', accessToken);
    await prefs.setString('refresh_token', refreshToken);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<String?> getRefreshToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  static Future<Map<String, dynamic>?> fetchAuthJson(String endpoint) async {
    return _retryAuthRequest((token) async {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        developer.log('Failed to fetch $endpoint: ${response.body}');
        return null;
      }
    });
  }

  // Signup
  static Future<Map<String, dynamic>> signupFromMap(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/signup/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true};
      } else {
        final responseData = jsonDecode(response.body);
        developer.log("Signup failed: ${response.body}");
        print('Signup Error: $responseData');
        return {
          'success': false,
          'message': responseData.toString(), // you can customize this
        };
      }
    } catch (e) {
      developer.log("Error during signup: $e");
      print('Signup Exception: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();
    final url = Uri.parse('$baseUrl/api/auth/profile/');

    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  static Future<Map<String, dynamic>?> login({
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
        final access = data['access'];
        final refresh = data['refresh'];
        final status = data['subscription_status'];

        if (access != null && refresh != null) {
          await saveTokens(access, refresh);
          return {'success': true, 'subscription_status': status};
        }
      }
    } catch (e) {
      developer.log('Login error: $e');
    }

    return {'success': false};
  }

  // //login
  // static Future<dynamic> login({
  //   required String phone,
  //   required String password,
  // }) async {
  //   final url = Uri.parse('$baseUrl/api/auth/login/');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'phone_number': phone, 'password': password}),
  //     );
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final access = data['access'];
  //       final refresh = data['refresh'];

  //       if (access != null && refresh != null) {
  //         await saveTokens(access, refresh);
  //         developer.log('Login success. Tokens saved.');
  //         return {
  //           'success': true,
  //           'message': 'Login successful',
  //           'user': data['user'], // optional
  //         };
  //       } else {
  //         developer.log('Tokens missing in login response.');
  //         return {'success': false, 'message': 'Missing tokens'};
  //       }
  //     } else {
  //       developer.log('Login failed: ${response.body}');
  //       return {'success': false, 'message': 'Invalid credentials'};
  //     }
  //   } catch (e) {
  //     developer.log('Error during login: $e');
  //     return {
  //       'success': false,
  //       'message': 'An error occurred. Please try again.',
  //     };
  //   }
  // }

  static Future<Map<String, dynamic>> loginWithSubscription({
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
        final access = data['access'];
        final refresh = data['refresh'];
        final user = data['user'];
        final subscriptionStatus = user['subscription_status'] ?? 'unknown';

        if (access != null && refresh != null) {
          await saveTokens(access, refresh);
          return {
            'success': true,
            'user': user,
            'subscription_status': subscriptionStatus,
          };
        } else {
          return {'success': false, 'message': 'Tokens missing in response'};
        }
      } else {
        return {'success': false, 'message': 'Login failed: ${response.body}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // // Login
  // static Future<bool> login({
  //   required String phone,
  //   required String password,
  // }) async {
  //   final url = Uri.parse('$baseUrl/api/auth/login/');

  //   try {
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({'phone_number': phone, 'password': password}),
  //     );

  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       final access = data['access'];
  //       final refresh = data['refresh'];

  //       if (access != null && refresh != null) {
  //         await saveTokens(access, refresh);
  //         developer.log('Login success. Tokens saved.');
  //         return true;
  //       } else {
  //         developer.log('Tokens missing in login response.');
  //         return false;
  //       }
  //     } else {
  //       developer.log('Login failed: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     developer.log('Error during login: $e');
  //     return false;
  //   }
  // }

  // Refresh token
  static Future<bool> refreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      developer.log('No refresh token found.');
      return false;
    }

    final url = Uri.parse('$baseUrl/api/auth/token/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final newAccessToken = data['access'];
        if (newAccessToken != null) {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', newAccessToken);
          developer.log('Token refreshed.');
          return true;
        }
      } else {
        developer.log('Refresh failed: ${response.body}');
      }
    } catch (e) {
      developer.log('Error during token refresh: $e');
    }

    return false;
  }

  // Check subscription status
  static Future<bool> checkSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return false;

    final url = Uri.parse('$baseUrl/api/subscription/status/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming your backend sends { "active": true/false }
        return data['active'] == true;
      } else {
        developer.log('Subscription status check failed: ${response.body}');
        return false;
      }
    } catch (e) {
      developer.log('Error checking subscription: $e');
      return false;
    }
  }

  // Authenticated GET request with retry
  static Future<http.Response?> fetchInventory() async {
    return _retryAuthRequest((token) {
      return http.get(
        Uri.parse('$baseUrl/api/inventory/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
    });
  }

  // Add inventory item with token retry
  static Future<bool> addInventoryItem({
    required String name,
    required int quantity,
    required double price,
    String category = 'foods',
    String description = '',
  }) async {
    return await _retryAuthRequest((token) async {
          final url = Uri.parse('$baseUrl/api/inventory/');
          final body = {
            'product_name': name,
            'quantity_in_stock': quantity,
            'price_per_unit': price,
            'purchase_price': price,
            'category': category,
            'product_description': description,
          };

          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          );

          if (response.statusCode == 201) {
            developer.log('Inventory item added.');
            return true;
          } else if (response.statusCode == 401) {
            return null; // Trigger token refresh
          } else {
            developer.log('Failed to add item: ${response.body}');
            return false;
          }
        }) ??
        false;
  }

  // Generic token refresh + retry helper
  static Future<T?> _retryAuthRequest<T>(
    Future<T?> Function(String token) requestFn,
  ) async {
    String? token = await getToken();
    if (token == null) return null;

    T? result = await requestFn(token);
    if (result != null) return result;

    // Token might have expired; try refreshing
    final refreshed = await refreshToken();
    if (!refreshed) return null;

    token = await getToken();
    if (token == null) return null;

    return await requestFn(token);
  }
}
