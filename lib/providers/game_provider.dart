import 'dart:math';
import 'package:flutter/material.dart';
import '../models/player.dart';
import '../models/question.dart';
import '../data/questions_data.dart';

class GameProvider extends ChangeNotifier {
  final List<Player> _players = [];
  int _currentPlayerIndex = 0;
  Question? _currentQuestion;
  int _timerSeconds = 30;
  final List<Question> _usedTruths = [];
  final List<Question> _usedDares = [];
  final Random _random = Random();

  List<Player> get players => _players;
  int get currentPlayerIndex => _currentPlayerIndex;
  Player? get currentPlayer => _players.isNotEmpty ? _players[_currentPlayerIndex] : null;
  Question? get currentQuestion => _currentQuestion;
  int get timerSeconds => _timerSeconds;

  void addPlayer(String name) {
    if (_players.length >= 8) return;
    if (name.trim().isEmpty) return;

    final index = _players.length;
    final player = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.trim(),
      icon: Player.availableIcons[index % Player.availableIcons.length],
      color: Player.availableColors[index % Player.availableColors.length],
    );
    _players.add(player);
    notifyListeners();
  }

  void removePlayer(String id) {
    _players.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void setTimerSeconds(int seconds) {
    _timerSeconds = seconds;
    notifyListeners();
  }

  void spinBottle() {
    if (_players.isEmpty) return;
    _currentPlayerIndex = _random.nextInt(_players.length);
    notifyListeners();
  }

  void selectTruth() {
    _currentQuestion = _getRandomQuestion(QuestionType.truth);
    notifyListeners();
  }

  void selectDare() {
    _currentQuestion = _getRandomQuestion(QuestionType.dare);
    notifyListeners();
  }

  Question _getRandomQuestion(QuestionType type) {
    final questions = type == QuestionType.truth 
        ? QuestionsData.truths 
        : QuestionsData.dares;
    final usedList = type == QuestionType.truth ? _usedTruths : _usedDares;
    
    // Reset if all questions used
    if (usedList.length >= questions.length) {
      usedList.clear();
    }
    
    // Get available questions
    final available = questions.where((q) => !usedList.contains(q)).toList();
    final selected = available[_random.nextInt(available.length)];
    usedList.add(selected);
    
    return selected;
  }

  void completeChallenge() {
    if (currentPlayer != null) {
      currentPlayer!.score += 10;
    }
    _nextPlayer();
  }

  void forfeitChallenge() {
    _nextPlayer();
  }

  void _nextPlayer() {
    if (_players.isNotEmpty) {
      _currentPlayerIndex = (_currentPlayerIndex + 1) % _players.length;
    }
    _currentQuestion = null;
    notifyListeners();
  }

  void resetGame() {
    _players.clear();
    _currentPlayerIndex = 0;
    _currentQuestion = null;
    _usedTruths.clear();
    _usedDares.clear();
    notifyListeners();
  }
}



