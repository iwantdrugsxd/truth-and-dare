import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static String get baseUrl => ApiConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Sign up
  static Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
        },
        body: jsonEncode({
          'email': email.toLowerCase(),
          'password': password,
          'name': name,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Is the backend server running?');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'], data['user']);
        return data;
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Failed to sign up');
        } catch (_) {
          throw Exception('Sign up failed (Status: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Cannot connect to server. Make sure:\n1. Backend is running (npm start in backend folder)\n2. ngrok is active (ngrok http 3000)\n3. API URL is correct in api_config.dart');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      // Provide more helpful error messages
      final errorStr = e.toString();
      if (errorStr.contains('404') || errorStr.contains('Not Found')) {
        throw Exception('Backend server not found.\nMake sure:\n1. Backend is running: cd backend && npm start\n2. ngrok is active: ngrok http 3000');
      } else if (errorStr.contains('500')) {
        throw Exception('Server error. Please check the backend logs.');
      } else if (errorStr.contains('XMLHttpRequest') || errorStr.contains('CORS')) {
        throw Exception('Connection blocked.\nMake sure:\n1. Backend is running\n2. ngrok tunnel is active\n3. Check browser console for details');
      }
      throw Exception('Network error: ${e.toString().replaceAll('Exception: ', '').replaceAll('Network error: ', '')}');
    }
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
        },
        body: jsonEncode({
          'email': email.toLowerCase(),
          'password': password,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Is the backend server running?');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(data['token'], data['user']);
        return data;
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Failed to login');
        } catch (_) {
          throw Exception('Login failed (Status: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Cannot connect to server. Make sure:\n1. Backend is running (npm start in backend folder)\n2. ngrok is active (ngrok http 3000)\n3. API URL is correct in api_config.dart');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      // Provide more helpful error messages
      final errorStr = e.toString();
      if (errorStr.contains('404') || errorStr.contains('Not Found')) {
        throw Exception('Backend server not found.\nMake sure:\n1. Backend is running: cd backend && npm start\n2. ngrok is active: ngrok http 3000');
      } else if (errorStr.contains('500')) {
        throw Exception('Server error. Please check the backend logs.');
      } else if (errorStr.contains('XMLHttpRequest') || errorStr.contains('CORS')) {
        throw Exception('Connection blocked.\nMake sure:\n1. Backend is running\n2. ngrok tunnel is active\n3. Check browser console for details');
      }
      throw Exception('Network error: ${e.toString().replaceAll('Exception: ', '').replaceAll('Network error: ', '')}');
    }
  }

  // Get current user
  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveAuthData(token, data['user']);
        return data;
      } else {
        // Token invalid, clear it
        await logout();
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  // Save auth data
  static Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user));
  }

  // Get token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get user data
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    
    // Verify token is still valid
    final user = await getCurrentUser();
    return user != null;
  }
}

