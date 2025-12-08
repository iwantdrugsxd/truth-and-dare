import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  int score;

  Player({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.score = 0,
  });

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
