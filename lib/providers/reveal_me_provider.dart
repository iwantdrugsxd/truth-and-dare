import 'dart:math';
import 'package:flutter/material.dart';
import '../models/reveal_me_player.dart';
import '../data/reveal_me_questions_data.dart';

enum RevealMePhase {
  createOrJoin,
  lobby,
  gameplay,
  rating,
  results,
}

class RevealMeProvider extends ChangeNotifier {
  final List<RevealMePlayer> _players = [];
  final Random _random = Random();
  
  RevealMePhase _phase = RevealMePhase.createOrJoin;
  String? _gameCode;
  String? _hostName;
  int _currentPlayerIndex = 0;
  int _currentQuestionIndex = 0;
  int _questionsPerPlayer = 3;
  int _timerSeconds = 30;
  RevealMeQuestion? _currentQuestion;
  Map<String, double> _currentRatings = {}; // playerId -> rating
  bool _timerActive = false;
  int _remainingSeconds = 30;

  // Getters
  List<RevealMePlayer> get players => List.unmodifiable(_players);
  RevealMePhase get phase => _phase;
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
  bool get allRatingsSubmitted => _currentRatings.length == _players.length - 1; // All except current player

  // Create game
  void createGame(String hostName) {
    _hostName = hostName;
    _gameCode = _generateGameCode();
    _players.clear();
    _addPlayer(hostName, isHost: true);
    _phase = RevealMePhase.lobby;
    notifyListeners();
  }

  // Join game
  bool joinGame(String code, String playerName) {
    if (_gameCode == code && !_players.any((p) => p.name == playerName)) {
      _addPlayer(playerName);
      notifyListeners();
      return true;
    }
    return false;
  }

  void _addPlayer(String name, {bool isHost = false}) {
    final index = _players.length;
    _players.add(RevealMePlayer(
      id: DateTime.now().millisecondsSinceEpoch.toString() + index.toString(),
      name: name,
      isHost: isHost,
    ));
  }

  String _generateGameCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  // Start game
  void startGame() {
    if (_players.length < 2) return;
    
    // Shuffle player order
    _players.shuffle(_random);
    
    // Reset all scores
    for (var player in _players) {
      player.scores.clear();
      player.averageScore = 0.0;
      player.questionsAnswered = 0;
    }
    
    _currentPlayerIndex = 0;
    _currentQuestionIndex = 0;
    _phase = RevealMePhase.gameplay;
    _loadNextQuestion();
    notifyListeners();
  }

  void _loadNextQuestion() {
    final availableQuestions = RevealMeQuestion.allQuestions;
    _currentQuestion = availableQuestions[_random.nextInt(availableQuestions.length)];
    _remainingSeconds = _timerSeconds;
    _timerActive = false;
    _currentRatings.clear();
    notifyListeners();
  }

  // Start timer
  void startTimer() {
    _timerActive = true;
    _remainingSeconds = _timerSeconds;
    notifyListeners();
  }

  // Update timer (call this from a timer widget)
  void tickTimer() {
    if (_timerActive && _remainingSeconds > 0) {
      _remainingSeconds--;
      notifyListeners();
      if (_remainingSeconds == 0) {
        _timerActive = false;
        // Auto move to rating after timer ends
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
  void submitRating(String raterId, double rating) {
    _currentRatings[raterId] = rating.clamp(1.0, 10.0);
    notifyListeners();
  }

  // Finish rating and move to next question/player
  void finishRating() {
    if (!allRatingsSubmitted) return;
    
    final currentPlayer = this.currentPlayer;
    if (currentPlayer != null) {
      // Calculate average rating
      final ratings = _currentRatings.values.toList();
      if (ratings.isNotEmpty) {
        final average = ratings.reduce((a, b) => a + b) / ratings.length;
        currentPlayer.addScore(average);
      }
    }
    
    _currentQuestionIndex++;
    
    // Check if current player has answered enough questions
    if (_currentQuestionIndex >= _questionsPerPlayer) {
      _currentQuestionIndex = 0;
      _currentPlayerIndex++;
      
      // Check if all players are done
      if (_currentPlayerIndex >= _players.length) {
        _phase = RevealMePhase.results;
        notifyListeners();
        return;
      }
    }
    
    // Load next question for current player
    _loadNextQuestion();
    _phase = RevealMePhase.gameplay;
    notifyListeners();
  }

  // Get winner
  RevealMePlayer? get winner {
    if (_players.isEmpty) return null;
    _players.sort((a, b) => b.averageScore.compareTo(a.averageScore));
    return _players.first;
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
    _players.clear();
    _phase = RevealMePhase.createOrJoin;
    _gameCode = null;
    _hostName = null;
    _currentPlayerIndex = 0;
    _currentQuestionIndex = 0;
    _currentQuestion = null;
    _currentRatings.clear();
    _timerActive = false;
    _remainingSeconds = 30;
    notifyListeners();
  }
}

