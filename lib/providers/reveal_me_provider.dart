import 'dart:async';
import 'package:flutter/material.dart';
import '../models/reveal_me_player.dart';
import '../data/reveal_me_questions_data.dart';
import '../services/reveal_me_api.dart';

enum RevealMePhase {
  createOrJoin,
  lobby,
  answering, // Psych-style: all players answer same question
  reveal, // Psych-style: show all answers anonymously
  voting, // Psych-style: vote for best answer
  roundResults, // Psych-style: show round results
  gameplay, // Backward compatibility: turn-based gameplay
  rating, // Backward compatibility: rating phase
  results, // Final leaderboard
}

class RevealMeProvider extends ChangeNotifier {
  final List<RevealMePlayer> _players = [];
  Timer? _pollTimer;
  
  RevealMePhase _phase = RevealMePhase.createOrJoin;
  String? _gameId;
  String? _playerId; // Current user's player ID
  String? _gameCode;
  String? _hostName;
  int _currentRound = 0; // Psych-style: round-based
  int _currentPlayerIndex = 0; // Keep for backward compatibility
  int _currentQuestionIndex = 0; // Keep for backward compatibility
  int _questionsPerPlayer = 3;
  int _timerSeconds = 30;
  RevealMeQuestion? _currentQuestion;
  String? _currentQuestionId; // Backend question ID
  String? _currentPlayerId; // Keep for backward compatibility
  String? _currentAnswer; // Current player's answer to the question
  List<Map<String, dynamic>> _revealAnswers = []; // Anonymous answers for reveal screen
  String? _selectedAnswerId; // Answer ID selected for voting
  Map<String, dynamic>? _roundResults; // Results for current round
  String? _timerStartTime; // Server timestamp for timer synchronization
  Map<String, double> _currentRatings = {}; // Keep for backward compatibility
  List<Map<String, dynamic>> _currentAnswers = []; // Keep for backward compatibility
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
  int get currentRound => _currentRound;
  int get currentPlayerIndex => _currentPlayerIndex; // Backward compatibility
  RevealMePlayer? get currentPlayer => _players.isNotEmpty && _currentPlayerIndex < _players.length 
      ? _players[_currentPlayerIndex] 
      : null;
  RevealMeQuestion? get currentQuestion => _currentQuestion;
  int get currentQuestionIndex => _currentQuestionIndex; // Backward compatibility
  int get questionsPerPlayer => _questionsPerPlayer;
  int get timerSeconds => _timerSeconds;
  bool get timerActive => _timerActive;
  int get remainingSeconds => _remainingSeconds;
  String? get currentAnswer => _currentAnswer;
  List<Map<String, dynamic>> get revealAnswers => List.unmodifiable(_revealAnswers);
  String? get selectedAnswerId => _selectedAnswerId;
  Map<String, dynamic>? get roundResults => _roundResults;
  List<Map<String, dynamic>> get currentAnswers => List.unmodifiable(_currentAnswers); // Backward compatibility
  Map<String, double> get currentRatings => Map.unmodifiable(_currentRatings); // Backward compatibility
  bool get allRatingsSubmitted {
    if (_currentPlayerId == null) return false;
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

      // After joining, refresh game state to get all players
      await refreshGameState();
      
              // If game is already in progress, update phase accordingly
              if (_phase == RevealMePhase.answering || _phase == RevealMePhase.gameplay || _phase == RevealMePhase.rating) {
                await _loadCurrentQuestion();
              }
      
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
      if (_gameId != null) {
        final oldPhase = _phase;
        await refreshGameState();
        
        // Handle phase transitions
        if (oldPhase != _phase) {
          // Auto-navigate based on phase changes
          if (_phase == RevealMePhase.answering && oldPhase == RevealMePhase.lobby) {
            await _loadCurrentQuestion();
          } else if (_phase == RevealMePhase.reveal && oldPhase == RevealMePhase.answering) {
            await _loadRevealAnswers();
            // Auto-advance to voting after a short delay (all players see answers)
            Future.delayed(const Duration(seconds: 3), () async {
              if (_gameId != null && _phase == RevealMePhase.reveal) {
                // Update status to voting (this will be picked up by polling)
                try {
                  // We'll let the reveal screen handle navigation, but ensure status updates
                  await refreshGameState();
                } catch (e) {
                  print('Error auto-advancing to voting: $e');
                }
              }
            });
          } else if (_phase == RevealMePhase.voting && oldPhase == RevealMePhase.reveal) {
            // Voting phase - no auto-load needed
          } else if (_phase == RevealMePhase.roundResults && oldPhase == RevealMePhase.voting) {
            await _loadRoundResults();
          }
          notifyListeners();
        }
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

      // Update phase based on status (Psych-style)
      final oldPhase = _phase;
      _currentRound = game['currentRound'] ?? game['current_round'] ?? 0;
      
      switch (game['status']) {
        case 'lobby':
          _phase = RevealMePhase.lobby;
          break;
        case 'answering':
          if (_phase != RevealMePhase.answering) {
            _phase = RevealMePhase.answering;
            // Keep polling to check when all players answered
            if (_pollTimer == null) {
              _startPolling();
            }
            await _loadCurrentQuestion(); // This loads timer start time
          } else {
            // Already in answering phase, but refresh question to get timer time
            // Only reload if we don't have timer time yet
            if (_timerStartTime == null) {
              await _loadCurrentQuestion();
            }
          }
          break;
        case 'reveal':
          if (_phase != RevealMePhase.reveal) {
            _phase = RevealMePhase.reveal;
            await _loadRevealAnswers();
          }
          break;
        case 'voting':
          if (_phase != RevealMePhase.voting) {
            _phase = RevealMePhase.voting;
          }
          break;
        case 'results':
          if (_phase != RevealMePhase.roundResults) {
            _phase = RevealMePhase.roundResults;
            await _loadRoundResults();
          }
          break;
        case 'playing': // Backward compatibility
          if (_phase != RevealMePhase.gameplay && _phase != RevealMePhase.rating) {
            _phase = RevealMePhase.gameplay;
            _stopPolling();
            await _loadCurrentQuestion();
          }
          break;
        case 'rating': // Backward compatibility
          if (_phase != RevealMePhase.rating) {
            _phase = RevealMePhase.rating;
          }
          break;
        case 'finished':
          _phase = RevealMePhase.results;
          _stopPolling();
          break;
      }
      
      // If phase changed to gameplay, load question (backward compatibility)
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
          // Note: isHost is final, so we recreate the player if host status changed
          if (player.isHost != (playerData['is_host'] ?? false)) {
            newPlayers.add(RevealMePlayer(
              id: player.id,
              name: player.name,
              isHost: playerData['is_host'] ?? false,
              averageScore: player.averageScore,
              questionsAnswered: player.questionsAnswered,
            ));
          } else {
            newPlayers.add(player);
          }
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
      
      // Update isHost flag based on current player
      if (_playerId != null) {
        final currentPlayerData = playersData.firstWhere(
          (p) => p['id'] == _playerId,
          orElse: () => {},
        );
        if (currentPlayerData.isNotEmpty) {
          _isHost = currentPlayerData['is_host'] ?? false;
        }
      }

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
      // Small delay to ensure backend has updated
      await Future.delayed(const Duration(milliseconds: 300));
      await refreshGameState();
      notifyListeners();
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
      // Note: Psych-style doesn't have currentPlayer, all players answer same question

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
      _currentQuestionIndex = response['roundNumber'] ?? response['questionNumber'] ?? 1;
      _currentRound = response['roundNumber'] ?? _currentRound;
      _currentAnswer = response['existingAnswer'] as String?;
      
      // Get synchronized timer start time from server
      _timerStartTime = response['timerStartTime'];
      
      // Calculate remaining time if we have server start time
      if (_timerStartTime != null) {
        try {
          final serverStartTime = DateTime.parse(_timerStartTime!);
          final now = DateTime.now();
          final elapsed = now.difference(serverStartTime).inSeconds;
          _remainingSeconds = (_timerSeconds - elapsed).clamp(0, _timerSeconds);
          _timerActive = _remainingSeconds > 0;
        } catch (e) {
          print('Error parsing timer start time: $e');
          _remainingSeconds = _timerSeconds;
          _timerActive = false;
        }
      } else {
        _remainingSeconds = _timerSeconds;
        _timerActive = false;
      }
      
      _currentRatings.clear();
      _currentAnswers.clear();

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
  
  // Set remaining seconds (for synchronized timer)
  void setRemainingSeconds(int seconds) {
    _remainingSeconds = seconds.clamp(0, _timerSeconds);
    _timerActive = _remainingSeconds > 0;
    notifyListeners();
  }

  // Submit answer
  Future<void> submitAnswer(String answerText) async {
    if (_gameId == null || _currentQuestionId == null) {
      throw Exception('No active question');
    }

    try {
      print('[SUBMIT ANSWER] Submitting answer for game: $_gameId, question: $_currentQuestionId');
      await RevealMeAPI.submitAnswer(
        gameId: _gameId!,
        questionId: _currentQuestionId!,
        answerText: answerText,
      );

      _currentAnswer = answerText;
      await refreshGameState(); // Refresh to check if all answered
      notifyListeners();
    } catch (e) {
      print('[SUBMIT ANSWER] Error: $e');
      rethrow;
    }
  }

  // Load reveal answers (Psych-style: anonymous, shuffled)
  Future<void> _loadRevealAnswers() async {
    if (_gameId == null) return;

    try {
      final response = await RevealMeAPI.getRevealAnswers(_gameId!);
      _revealAnswers = List<Map<String, dynamic>>.from(response['answers'] ?? []);
      _currentQuestion = RevealMeQuestion(
        id: response['question']['questionId'] ?? 0,
        category: response['question']['category'] ?? 'Spicy',
        question: response['question']['question'] ?? '',
        answerType: 'story',
      );
      notifyListeners();
    } catch (e) {
      print('Error loading reveal answers: $e');
    }
  }

  // Load round results (Psych-style: votes and points)
  Future<void> _loadRoundResults() async {
    if (_gameId == null) return;

    try {
      final response = await RevealMeAPI.getRoundResults(_gameId!);
      _roundResults = response;
      await refreshGameState(); // Refresh to get updated scores
      notifyListeners();
    } catch (e) {
      print('Error loading round results: $e');
    }
  }

  // Advance to voting phase
  Future<void> advanceToVoting() async {
    if (_gameId == null) return;

    try {
      await RevealMeAPI.advanceToVoting(_gameId!);
      await refreshGameState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Submit vote (Psych-style: vote for best answer)
  Future<void> submitVote(String answerId) async {
    if (_gameId == null) return;

    try {
      await RevealMeAPI.submitVote(
        gameId: _gameId!,
        answerId: answerId,
      );
      _selectedAnswerId = answerId;
      await refreshGameState(); // Check if all voted
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Load answers for rating screen (backward compatibility)
  Future<void> loadAnswersForRating() async {
    if (_gameId == null || _currentQuestionId == null) return;

    try {
      final answers = await RevealMeAPI.getAnswers(
        gameId: _gameId!,
        questionId: _currentQuestionId!,
      );
      _currentAnswers = answers;
      notifyListeners();
    } catch (e) {
      print('Error loading answers: $e');
    }
  }

  // Move to rating phase (backward compatibility)
  Future<void> moveToRating() async {
    _timerActive = false;
    _phase = RevealMePhase.rating;
    _currentRatings.clear();
    await loadAnswersForRating();
    notifyListeners();
  }

  // Remove player (host only)
  Future<void> removePlayer(String playerId) async {
    if (_gameId == null || !_isHost) {
      throw Exception('Only the host can remove players');
    }

    try {
      await RevealMeAPI.removePlayer(
        gameId: _gameId!,
        playerId: playerId,
      );
      await refreshGameState(); // Refresh to get updated player list
    } catch (e) {
      rethrow;
    }
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

  // Mark player as ready
  Future<void> markReady() async {
    if (_gameId == null) return;
    
    try {
      final response = await RevealMeAPI.markReady(_gameId!);
      if (response['allReady'] == true) {
        // All players ready - game will advance automatically
        if (response['gameFinished'] == true) {
          _phase = RevealMePhase.results;
        } else {
          _phase = RevealMePhase.answering;
          await _loadCurrentQuestion();
        }
      }
      await refreshGameState();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Next round (Psych-style: move to next round or end game) - DEPRECATED, use markReady
  Future<void> nextRound() async {
    if (_gameId == null || !_isHost) return;
    
    try {
      final response = await RevealMeAPI.nextRound(_gameId!);
      if (response['gameFinished'] == true) {
        _phase = RevealMePhase.results;
      } else {
        _phase = RevealMePhase.answering;
        await _loadCurrentQuestion();
      }
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Finish rating and move to next (backward compatibility)
  Future<void> finishRating() async {
    return nextRound();
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
