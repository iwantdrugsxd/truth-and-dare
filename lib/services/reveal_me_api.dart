import 'dart:async';
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
      // Clean the code: trim, uppercase, remove spaces
      final cleanCode = code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
      
      print('[JOIN API] Attempting to join with code: "$code" -> cleaned: "$cleanCode"');
      
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/join'),
        headers: headers,
        body: jsonEncode({
          'code': cleanCode,
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Connection timeout. Is the backend server running?');
        },
      );

      print('[JOIN API] Response status: ${response.statusCode}');
      print('[JOIN API] Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        try {
          final error = jsonDecode(response.body);
          final errorMsg = error['error'] ?? 'Failed to join game';
          print('[JOIN API] Error: $errorMsg');
          throw Exception(errorMsg);
        } catch (e) {
          if (e.toString().contains('Exception:')) {
            rethrow;
          }
          throw Exception('Failed to join game (Status: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Cannot connect to server. Make sure the backend is running and ngrok is active.');
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
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Request timeout. Is the backend server running?');
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Token expired or invalid - try to get error message
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Authentication failed. Please log in again.');
        } catch (_) {
          throw Exception('Authentication failed (${response.statusCode}). Please log in again.');
        }
      } else {
        try {
          final error = jsonDecode(response.body);
          throw Exception(error['error'] ?? 'Failed to get game state');
        } catch (_) {
          throw Exception('Failed to get game state (Status: ${response.statusCode})');
        }
      }
    } on SocketException catch (e) {
      throw Exception('Cannot connect to server. Make sure the backend is running and ngrok is active.');
    } catch (e) {
      if (e.toString().contains('timeout')) {
        rethrow;
      }
      throw Exception('Network error: ${e.toString().replaceAll('Exception: ', '')}');
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

  // Submit answer
  static Future<void> submitAnswer({
    required String gameId,
    required String questionId,
    required String answerText,
  }) async {
    try {
      final headers = await _getHeaders();
      final url = '$baseUrl/games/$gameId/answer';
      
      print('[API] Submitting answer to: $url');
      print('[API] QuestionId: $questionId');
      print('[API] Answer length: ${answerText.length}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode({
          'questionId': questionId,
          'answerText': answerText,
        }),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout: Server did not respond in time');
        },
      );

      print('[API] Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        print('[API] ✅ Answer submitted successfully');
        return;
      }
      
      // Handle error response
      String errorMessage = 'Failed to submit answer';
      try {
        final errorBody = jsonDecode(response.body);
        errorMessage = errorBody['error'] ?? errorMessage;
      } catch (e) {
        errorMessage = 'Server error: ${response.statusCode}';
      }
      
      throw Exception(errorMessage);
    } on http.ClientException catch (e) {
      print('[API] ❌ Network error: $e');
      throw Exception('Network error: Cannot connect to server. Please check:\n1. Backend server is running\n2. ngrok tunnel is active\n3. Internet connection');
    } on TimeoutException catch (e) {
      print('[API] ❌ Timeout: $e');
      throw Exception('Request timeout: Server took too long to respond');
    } catch (e) {
      print('[API] ❌ Error: $e');
      if (e.toString().contains('XMLHttpRequest') || e.toString().contains('CORS')) {
        throw Exception('CORS error: Please ensure backend CORS is configured correctly');
      }
      rethrow;
    }
  }

  // Get answers for a question
  static Future<List<Map<String, dynamic>>> getAnswers({
    required String gameId,
    required String questionId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/question/$questionId/answers'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['answers'] ?? []);
      } else {
        throw Exception('Failed to get answers');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Remove player (host only)
  static Future<void> removePlayer({
    required String gameId,
    required String playerId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/games/$gameId/players/$playerId'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to remove player');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get reveal answers (Psych-style: anonymous, shuffled)
  static Future<Map<String, dynamic>> getRevealAnswers(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/reveal'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get reveal answers');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Submit vote (Psych-style: vote for best answer)
  static Future<void> submitVote({
    required String gameId,
    required String answerId,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/vote'),
        headers: headers,
        body: jsonEncode({
          'answerId': answerId,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to submit vote');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Get round results (Psych-style: votes and points)
  static Future<Map<String, dynamic>> getRoundResults(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/games/$gameId/results'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get round results');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Advance to voting phase
  static Future<void> advanceToVoting(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/voting'),
        headers: headers,
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to advance to voting');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Next round (Psych-style: move to next round or end game)
  static Future<Map<String, dynamic>> nextRound(String gameId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/next'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to move to next round');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Move to next question (backward compatibility)
  static Future<Map<String, dynamic>> nextQuestion(String gameId) async {
    return nextRound(gameId);
  }
}

