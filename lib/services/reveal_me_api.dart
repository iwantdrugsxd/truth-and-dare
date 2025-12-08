import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/reveal_me_player.dart';
import '../data/reveal_me_questions_data.dart';
import '../config/api_config.dart';
import 'auth_service.dart';

class RevealMeAPI {
  static String get baseUrl => ApiConfig.baseUrl;
  
  // Get auth headers
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'ngrok-skip-browser-warning': 'true', // Skip ngrok browser warning
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Create game
  static Future<Map<String, dynamic>> createGame({
    int questionsPerPlayer = 3,
    int timerSeconds = 30,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/create'),
        headers: headers,
        body: jsonEncode({
          'questionsPerPlayer': questionsPerPlayer,
          'timerSeconds': timerSeconds,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to create game');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Join game
  static Future<Map<String, dynamic>> joinGame({
    required String code,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/join'),
        headers: headers,
        body: jsonEncode({
          'code': code.toUpperCase(),
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Is the backend server running?');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Failed to join game');
        } catch (_) {
          throw Exception('Failed to join game (Status: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Cannot connect to server. Make sure the backend is running on http://localhost:3000');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get game state
  static Future<Map<String, dynamic>> getGameState(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get game state');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Start game
  static Future<void> startGame(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/start'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to start game');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get current question
  static Future<Map<String, dynamic>> getCurrentQuestion(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/question'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get question');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Submit rating
  static Future<void> submitRating({
    required String gameId,
    required String questionId,
    required String playerId,
    required String raterId,
    required double rating,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/rate'),
        headers: headers,
        body: jsonEncode({
          'questionId': questionId,
          'playerId': playerId,
          'raterId': raterId,
          'rating': rating,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to submit rating');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Move to next question
  static Future<Map<String, dynamic>> nextQuestion(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/next'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to move to next');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

