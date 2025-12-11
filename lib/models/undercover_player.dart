import 'package:flutter/material.dart';

enum UndercoverRole {
  civilian,
  undercover,
  mrWhite,
}

class UndercoverPlayer {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  UndercoverRole role;
  String? word;
  String? clue;
  bool isAlive;
  bool hasRevealedRole;
  int votesReceived;
  String? votedFor;

  UndercoverPlayer({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.role,
    this.word,
    this.clue,
    this.isAlive = true,
    this.hasRevealedRole = false,
    this.votesReceived = 0,
    this.votedFor,
  });

  String get roleName {
    switch (role) {
      case UndercoverRole.civilian:
        return 'Civilian';
      case UndercoverRole.undercover:
        return 'Undercover';
      case UndercoverRole.mrWhite:
        return 'Mr. White';
    }
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

