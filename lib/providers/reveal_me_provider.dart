import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reveal_me_player.dart';
import '../data/reveal_me_questions_data.dart';
import '../services/reveal_me_api.dart';

enum RevealMePhase {
  createOrJoin,
  lobby,
  gameplay,
  rating,
  results,
}

class RevealMeProvider extends ChangeNotifier {
  final List<RevealMePlayer> _players = [];
  Timer? _pollTimer;
  
  RevealMePhase _phase = RevealMePhase.createOrJoin;
  String? _gameId;
  String? _playerId; // Current user's player ID
  String? _gameCode;
  String? _hostName;
  int _currentPlayerIndex = 0;
  int _currentQuestionIndex = 0;
  int _questionsPerPlayer = 3;
  int _timerSeconds = 30;
  RevealMeQuestion? _currentQuestion;
  String? _currentQuestionId; // Backend question ID
  String? _currentPlayerId; // Player being asked
  Map<String, double> _currentRatings = {};
  bool _timerActive = false;
  int _remainingSeconds = 30;
  bool _isHost = false;

  // Getters
  List<RevealMePlayer> get players => List.unmodifiable(_players);
  RevealMePhase get phase => _phase;
  String? get gameId => _gameId;
  String? get playerId => _playerId;
  String? get gameCode => _gameCode;
  String? get hostName => _hostName;
  int get currentPlayerIndex => _currentPlayerIndex;
  RevealMePlayer? get currentPlayer => _players.isNotEmpty && _currentPlayerIndex < _players.length 
      ? _players[_currentPlayerIndex] 
      : null;
  RevealMeQuestion? get currentQuestion => _currentQuestion;
  int get currentQuestionIndex => _currentQuestionIndex;
  int get questionsPerPlayer => _questionsPerPlayer;
  int get timerSeconds => _timerSeconds;
  bool get timerActive => _timerActive;
  int get remainingSeconds => _remainingSeconds;
  Map<String, double> get currentRatings => Map.unmodifiable(_currentRatings);
  bool get allRatingsSubmitted {
    if (_currentPlayerId == null) return false;
    // Check if all players except current player have rated
    final otherPlayers = _players.where((p) => p.id != _currentPlayerId).toList();
    return _currentRatings.length >= otherPlayers.length;
  }
  bool get isHost => _isHost;

  // Create game
  Future<void> createGame({int questionsPerPlayer = 3, int timerSeconds = 30}) async {
    try {
      final response = await RevealMeAPI.createGame(
        questionsPerPlayer: questionsPerPlayer,
        timerSeconds: timerSeconds,
      );

      _gameId = response['game']['id'];
      _gameCode = response['game']['code'];
      _hostName = response['game']['hostName'];
      _questionsPerPlayer = response['game']['questionsPerPlayer'];
      _timerSeconds = response['game']['timerSeconds'];
      _playerId = response['player']['id'];
      _isHost = true;

      _players.clear();
      _addPlayerFromAPI(response['player']);

      _phase = RevealMePhase.lobby;
      _startPolling();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Join game
  Future<void> joinGame(String code) async {
    try {
      final response = await RevealMeAPI.joinGame(
        code: code,
      );

      _gameId = response['game']['id'];
      _gameCode = response['game']['code'];
      _hostName = response['game']['hostName'];
      _questionsPerPlayer = response['game']['questionsPerPlayer'];
      _timerSeconds = response['game']['timerSeconds'];
      _playerId = response['player']['id'];
      _isHost = response['player']['is_host'] ?? false;

      _players.clear();
      _addPlayerFromAPI(response['player']);

      _phase = RevealMePhase.lobby;
      _startPolling();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void _addPlayerFromAPI(Map<String, dynamic> playerData) {
    // Helper function to safely parse double from API response
    double _parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    // Check if player already exists
    final existingIndex = _players.indexWhere((p) => p.id == playerData['id']);
    if (existingIndex >= 0) {
      // Update existing player
      final player = _players[existingIndex];
      player.averageScore = _parseDouble(playerData['average_score']);
      player.questionsAnswered = playerData['questions_answered'] ?? 0;
    } else {
      // Add new player
      _players.add(RevealMePlayer(
        id: playerData['id'],
        name: playerData['name'],
        isHost: playerData['is_host'] ?? false,
        averageScore: _parseDouble(playerData['average_score']),
        questionsAnswered: playerData['questions_answered'] ?? 0,
      ));
    }
  }

  // Poll for game state updates
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_gameId != null && _phase == RevealMePhase.lobby) {
        await refreshGameState();
      }
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  // Refresh game state from server
  Future<void> refreshGameState() async {
    if (_gameId == null) return;

    try {
      final response = await RevealMeAPI.getGameState(_gameId!);
      
      final game = response['game'];
      final playersData = response['players'] as List;

      // Update game state
      _gameCode = game['code'];
      _hostName = game['hostName'];
      _questionsPerPlayer = game['questionsPerPlayer'];
      _timerSeconds = game['timerSeconds'];
      _currentPlayerIndex = game['currentPlayerIndex'] ?? 0;
      _currentQuestionIndex = game['currentQuestionIndex'] ?? 0;

      // Update phase based on status
      final oldPhase = _phase;
      switch (game['status']) {
        case 'lobby':
          _phase = RevealMePhase.lobby;
          break;
        case 'playing':
          if (_phase != RevealMePhase.gameplay && _phase != RevealMePhase.rating) {
            _phase = RevealMePhase.gameplay;
            _stopPolling();
            await _loadCurrentQuestion();
          }
          break;
        case 'finished':
          _phase = RevealMePhase.results;
          _stopPolling();
          break;
      }
      
      // If phase changed to gameplay, load question
      if (oldPhase != _phase && _phase == RevealMePhase.gameplay) {
        await _loadCurrentQuestion();
      }

      // Helper function to safely parse double from API response
      double _parseDoubleValue(dynamic value) {
        if (value == null) return 0.0;
        if (value is double) return value;
        if (value is int) return value.toDouble();
        if (value is String) {
          return double.tryParse(value) ?? 0.0;
        }
        return 0.0;
      }

      // Update players (preserve order from server)
      final newPlayers = <RevealMePlayer>[];
      for (var playerData in playersData) {
        final existingIndex = _players.indexWhere((p) => p.id == playerData['id']);
        if (existingIndex >= 0) {
          // Update existing
          final player = _players[existingIndex];
          player.averageScore = _parseDoubleValue(playerData['average_score']);
          player.questionsAnswered = playerData['questions_answered'] ?? 0;
          newPlayers.add(player);
        } else {
          // Add new
          newPlayers.add(RevealMePlayer(
            id: playerData['id'],
            name: playerData['name'],
            isHost: playerData['is_host'] ?? false,
            averageScore: _parseDoubleValue(playerData['average_score']),
            questionsAnswered: playerData['questions_answered'] ?? 0,
          ));
        }
      }
      _players.clear();
      _players.addAll(newPlayers);

      notifyListeners();
    } catch (e) {
      print('Error refreshing game state: $e');
    }
  }

  // Start game
  Future<void> startGame() async {
    if (_gameId == null || !_isHost) return;

    try {
      await RevealMeAPI.startGame(_gameId!);
      await refreshGameState();
    } catch (e) {
      rethrow;
    }
  }

  // Load current question
  Future<void> _loadCurrentQuestion() async {
    if (_gameId == null) return;

    try {
      final response = await RevealMeAPI.getCurrentQuestion(_gameId!);

      if (response['gameFinished'] == true) {
        _phase = RevealMePhase.results;
        await refreshGameState();
        notifyListeners();
        return;
      }

      final questionData = response['question'];
      final playerData = response['currentPlayer'];

      // Find question in local data
      final questionId = questionData['questionId'] as int;
      final allQuestions = RevealMeQuestion.allQuestions;
      if (allQuestions.isEmpty) {
        _currentQuestion = null;
      } else {
        try {
          _currentQuestion = allQuestions.firstWhere(
            (q) => q.id == questionId,
          );
        } catch (e) {
          _currentQuestion = allQuestions[0];
        }
      }

      _currentQuestionId = questionData['id'];
      _currentPlayerId = playerData['id'];
      _currentQuestionIndex = response['questionNumber'] ?? 1;
      _remainingSeconds = _timerSeconds;
      _timerActive = false;
      _currentRatings.clear();

      notifyListeners();
    } catch (e) {
      print('Error loading question: $e');
    }
  }

  // Start timer
  void startTimer() {
    _timerActive = true;
    _remainingSeconds = _timerSeconds;
    notifyListeners();
  }

  // Update timer
  void tickTimer() {
    if (_timerActive && _remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();
      if (_remainingSeconds == 0) {
        _timerActive = false;
        Future.delayed(const Duration(milliseconds: 500), () {
          moveToRating();
        });
      }
    }
  }

  // Move to rating phase
  void moveToRating() {
    _timerActive = false;
    _phase = RevealMePhase.rating;
    _currentRatings.clear();
    notifyListeners();
  }

  // Submit rating
  Future<void> submitRating(double rating) async {
    if (_gameId == null || _currentQuestionId == null || _currentPlayerId == null || _playerId == null) {
      return;
    }

    try {
      await RevealMeAPI.submitRating(
        gameId: _gameId!,
        questionId: _currentQuestionId!,
        playerId: _currentPlayerId!,
        raterId: _playerId!,
        rating: rating,
      );

      _currentRatings[_playerId!] = rating;
      await refreshGameState();
      notifyListeners();
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  // Finish rating and move to next
  Future<void> finishRating() async {
    if (_gameId == null) return;

    try {
      final response = await RevealMeAPI.nextQuestion(_gameId!);

      if (response['gameFinished'] == true) {
        _phase = RevealMePhase.results;
        await refreshGameState();
        notifyListeners();
        return;
      }

      await refreshGameState();
      await _loadCurrentQuestion();
    } catch (e) {
      print('Error finishing rating: $e');
    }
  }

  // Get winner
  RevealMePlayer? get winner {
    if (_players.isEmpty) return null;
    final sorted = List<RevealMePlayer>.from(_players)
      ..sort((a, b) => b.averageScore.compareTo(a.averageScore));
    return sorted.first;
  }

  // Settings
  void setQuestionsPerPlayer(int count) {
    _questionsPerPlayer = count.clamp(1, 10);
    notifyListeners();
  }

  void setTimerSeconds(int seconds) {
    _timerSeconds = seconds.clamp(10, 120);
    notifyListeners();
  }

  // Reset
  void resetGame() {
    _stopPolling();
    _players.clear();
    _phase = RevealMePhase.createOrJoin;
    _gameId = null;
    _playerId = null;
    _gameCode = null;
    _hostName = null;
    _currentPlayerIndex = 0;
    _currentQuestionIndex = 0;
    _currentQuestion = null;
    _currentQuestionId = null;
    _currentPlayerId = null;
    _currentRatings.clear();
    _timerActive = false;
    _remainingSeconds = 30;
    _isHost = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopPolling();
    super.dispose();
  }
}
