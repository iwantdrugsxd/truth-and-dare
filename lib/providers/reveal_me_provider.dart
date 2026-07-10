import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/reveal_me_models.dart';

class RevealMeApiException implements Exception {
  final String message;
  RevealMeApiException(this.message);
  @override
  String toString() => message;
}

class RevealMeProvider extends ChangeNotifier {
  String? _token;
  String? _userId;
  String? _playerName;

  String? _gameId;
  String? _gameCode;
  String? _hostName;
  List<String> _categories = [];
  int _questionsPerPlayer = 5;
  int _timerSeconds = 30;
  RevealMePhase _phase = RevealMePhase.none;
  List<RevealMePlayer> _players = [];

  RevealMeQuestion? _currentQuestion;
  String? _myAnswer;
  bool _answerSubmitted = false;

  List<RevealMeAnswerCard> _revealAnswers = [];
  String? _votedAnswerId;
  List<RevealMeRoundResult> _results = [];
  List<RevealMePlayer> _standings = [];
  final Map<String, int> _fastCounts = {}; // playerName -> fast-bonus rounds this game
  final Map<String, int> _totalVotesEarned = {}; // playerName -> votes received this game
  final Set<String> _scoredRoundIds = {}; // guards against double-tallying on repeated /results polls

  Timer? _pollTimer;
  bool _loading = false;
  String? _lastError;
  String? _myPlayerId;

  String? get playerName => _playerName;
  String? get myPlayerId => _myPlayerId;
  String? get gameCode => _gameCode;
  String? get hostName => _hostName;
  List<String> get categories => _categories;
  int get questionsPerPlayer => _questionsPerPlayer;
  int get timerSeconds => _timerSeconds;
  RevealMePhase get phase => _phase;
  List<RevealMePlayer> get players => _players;
  bool get isHost => _players.any((p) => p.id == _myPlayerId && p.isHost);
  RevealMeQuestion? get currentQuestion => _currentQuestion;
  String? get myAnswer => _myAnswer;
  bool get answerSubmitted => _answerSubmitted;
  List<RevealMeAnswerCard> get revealAnswers => _revealAnswers;
  String? get votedAnswerId => _votedAnswerId;
  List<RevealMeRoundResult> get results => _results;
  List<RevealMePlayer> get standings => _standings;
  bool get loading => _loading;
  String? get lastError => _lastError;
  bool get hasGame => _gameId != null;

  Future<void> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('reveal_me_token');
    _userId = prefs.getString('reveal_me_user_id');
    _playerName = prefs.getString('reveal_me_name');
    notifyListeners();
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _post(String path, [Map<String, dynamic>? body]) async {
    final resp = await http
        .post(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers, body: jsonEncode(body ?? {}))
        .timeout(const Duration(seconds: 15));
    return _handle(resp);
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final resp = await http.get(Uri.parse('${ApiConfig.baseUrl}$path'), headers: _headers).timeout(
          const Duration(seconds: 15),
        );
    return _handle(resp);
  }

  Map<String, dynamic> _handle(http.Response resp) {
    final body = resp.body.isNotEmpty ? jsonDecode(resp.body) as Map<String, dynamic> : <String, dynamic>{};
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw RevealMeApiException(body['error'] ?? 'Something went wrong. Try again.');
    }
    return body;
  }

  Future<void> joinAsGuest(String name) async {
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await _post('/auth/guest', {'name': name});
      _token = result['token'];
      _userId = result['user']['id'];
      _playerName = result['user']['name'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('reveal_me_token', _token!);
      await prefs.setString('reveal_me_user_id', _userId!);
      await prefs.setString('reveal_me_name', _playerName!);
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> createGame({
    required List<String> categories,
    required int questionsPerPlayer,
    required int timerSeconds,
  }) async {
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await _post('/games/create', {
        'categories': categories,
        'questionsPerPlayer': questionsPerPlayer,
        'timerSeconds': timerSeconds,
      });
      _applyGame(result['game']);
      _myPlayerId = result['player']?['id'];
      startPolling();
      await refreshGameState();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> joinGame(String code) async {
    _loading = true;
    _lastError = null;
    notifyListeners();
    try {
      final result = await _post('/games/join', {'code': code.trim().toUpperCase()});
      _applyGame(result['game']);
      _myPlayerId = result['player']?['id'];
      startPolling();
      await refreshGameState();
    } catch (e) {
      _lastError = e.toString();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _applyGame(Map<String, dynamic> g) {
    _gameId = g['id'];
    _gameCode = g['code'];
    _hostName = g['hostName'];
    _categories = (g['categories'] as String?)?.split(',') ?? [];
    _questionsPerPlayer = g['questionsPerPlayer'] ?? 5;
    _timerSeconds = g['timerSeconds'] ?? 30;
    _phase = phaseFromStatus(g['status']);
  }

  void startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) => refreshGameState());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> startGame() async {
    if (_gameId == null) return;
    await _post('/games/$_gameId/start');
    await refreshGameState();
  }

  Future<void> refreshGameState() async {
    if (_gameId == null) return;
    try {
      final result = await _get('/games/$_gameId');
      final g = result['game'];
      final previousPhase = _phase;
      _gameCode = g['code'];
      _hostName = g['hostName'];
      _phase = phaseFromStatus(g['status']);
      _players = (result['players'] as List).map((p) => RevealMePlayer.fromLobbyJson(p)).toList();
      for (final p in _players) {
        if (p.userId == _userId) {
          _myPlayerId = p.id;
          break;
        }
      }

      if (previousPhase != _phase) {
        _onPhaseEntered(_phase);
      }
      notifyListeners();
    } catch (_) {
      // Transient network hiccups shouldn't blow up the poll loop.
    }
  }

  void _onPhaseEntered(RevealMePhase phase) {
    if (phase == RevealMePhase.answering) {
      _currentQuestion = null;
      _myAnswer = null;
      _answerSubmitted = false;
      fetchQuestion();
    } else if (phase == RevealMePhase.reveal) {
      fetchReveal();
    } else if (phase == RevealMePhase.voting) {
      _votedAnswerId = null;
      fetchReveal();
    } else if (phase == RevealMePhase.results) {
      fetchResults();
    }
  }

  Future<void> fetchQuestion() async {
    if (_gameId == null) return;
    final result = await _get('/games/$_gameId/question');
    if (result['gameFinished'] == true) {
      _phase = RevealMePhase.finished;
      notifyListeners();
      return;
    }
    _currentQuestion = RevealMeQuestion.fromJson(result);
    _myAnswer = _currentQuestion!.existingAnswer;
    _answerSubmitted = _myAnswer != null && _myAnswer!.isNotEmpty;
    notifyListeners();
  }

  Future<void> submitAnswer(String text) async {
    if (_gameId == null || _currentQuestion == null) return;
    _myAnswer = text;
    _answerSubmitted = true;
    notifyListeners();
    try {
      await _post('/games/$_gameId/answer', {
        'questionId': _currentQuestion!.id,
        'answerText': text,
      });
    } catch (e) {
      _answerSubmitted = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchReveal() async {
    if (_gameId == null) return;
    final result = await _get('/games/$_gameId/reveal');
    _revealAnswers = (result['answers'] as List).map((a) => RevealMeAnswerCard.fromJson(a)).toList();
    notifyListeners();
  }

  Future<void> advanceToVoting() async {
    if (_gameId == null) return;
    await _post('/games/$_gameId/voting');
  }

  Future<void> submitVote(String answerId) async {
    if (_gameId == null || _votedAnswerId != null) return;
    _votedAnswerId = answerId;
    notifyListeners();
    try {
      await _post('/games/$_gameId/vote', {'answerId': answerId});
    } catch (e) {
      _votedAnswerId = null;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> fetchResults() async {
    if (_gameId == null) return;
    final result = await _get('/games/$_gameId/results');
    _results = (result['results'] as List).map((r) => RevealMeRoundResult.fromJson(r)).toList();
    _standings = (result['players'] as List).map((p) => RevealMePlayer.fromResultsJson(p)).toList();

    final roundId = _currentQuestion?.id;
    if (roundId != null && !_scoredRoundIds.contains(roundId)) {
      _scoredRoundIds.add(roundId);
      for (final r in _results) {
        _totalVotesEarned[r.playerName] = (_totalVotesEarned[r.playerName] ?? 0) + r.votes;
        if (r.fastBonus) {
          _fastCounts[r.playerName] = (_fastCounts[r.playerName] ?? 0) + 1;
        }
      }
    }
    notifyListeners();
  }

  /// Player name with the most fast-answer bonuses this game (ties broken by
  /// total votes earned). Null if nobody ever hit one.
  String? get fastestThinker {
    if (_fastCounts.isEmpty) return null;
    final entries = _fastCounts.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.compareTo(a.value);
        if (byCount != 0) return byCount;
        return (_totalVotesEarned[b.key] ?? 0).compareTo(_totalVotesEarned[a.key] ?? 0);
      });
    return entries.first.value > 0 ? entries.first.key : null;
  }

  Future<void> nextRound() async {
    if (_gameId == null) return;
    final result = await _post('/games/$_gameId/next');
    if (result['gameFinished'] == true) {
      _phase = RevealMePhase.finished;
    }
    notifyListeners();
  }

  void resetGame() {
    stopPolling();
    _gameId = null;
    _myPlayerId = null;
    _gameCode = null;
    _hostName = null;
    _categories = [];
    _phase = RevealMePhase.none;
    _players = [];
    _currentQuestion = null;
    _myAnswer = null;
    _answerSubmitted = false;
    _revealAnswers = [];
    _votedAnswerId = null;
    _results = [];
    _standings = [];
    _fastCounts.clear();
    _totalVotesEarned.clear();
    _scoredRoundIds.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
