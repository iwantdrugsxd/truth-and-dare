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

  // Submit answer
  static Future<void> submitAnswer({
    required String gameId,
    required String questionId,
    required String answerText,
  }) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/games/$gameId/answer'),
        headers: headers,
        body: jsonEncode({
          'questionId': questionId,
          'answerText': answerText,
        }),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Failed to submit answer');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
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

