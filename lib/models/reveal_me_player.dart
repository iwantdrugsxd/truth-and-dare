import 'package:flutter/material.dart';

class RevealMePlayer {
  final String id;
  final String name;
  final bool isHost;
  double averageScore;
  List<double> scores;
  int questionsAnswered;

  RevealMePlayer({
    required this.id,
    required this.name,
    this.isHost = false,
    this.averageScore = 0.0,
    List<double>? scores,
    this.questionsAnswered = 0,
  }) : scores = scores ?? [];

  void addScore(double score) {
    scores.add(score);
    questionsAnswered++;
    _calculateAverage();
  }

  void _calculateAverage() {
    if (scores.isEmpty) {
      averageScore = 0.0;
      return;
    }
    averageScore = scores.reduce((a, b) => a + b) / scores.length;
  }

  static final List<IconData> availableIcons = [
    Icons.rocket_launch,
    Icons.flash_on,
    Icons.auto_awesome,
    Icons.star,
    Icons.favorite,
    Icons.diamond,
    Icons.local_fire_department,
    Icons.emoji_emotions,
  ];

  static final List<Color> availableColors = [
    const Color(0xFF4ECDC4),
    const Color(0xFFE040FB),
    const Color(0xFF3D5AFE),
    const Color(0xFFFF6B9D),
    const Color(0xFFFFC107),
    const Color(0xFF00E676),
    const Color(0xFFFF5722),
    const Color(0xFF9C27B0),
  ];
}


