import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../models/undercover_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../game_selection_screen.dart';
import 'role_reveal_screen.dart';

class GameEndScreen extends StatelessWidget {
  const GameEndScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        final winner = provider.winner;
        final civilianWord = provider.civilianWord;
        final undercoverWord = provider.undercoverWord;

        String winnerText = '';
        Color winnerColor = AppTheme.cyan;

        switch (winner) {
          case GameWinner.civilians:
            winnerText = 'Civilians Win!';
            winnerColor = AppTheme.cyan;
            break;
          case GameWinner.undercover:
            winnerText = 'Undercover Wins!';
            winnerColor = Colors.red;
            break;
          case GameWinner.mrWhite:
            winnerText = 'Mr. White Wins!';
            winnerColor = Colors.orange;
            break;
          case GameWinner.none:
            winnerText = 'Game Over';
            break;
        }

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Winner announcement
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: winnerColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: winnerColor,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        winnerText,
                        style: TextStyle(
                          color: winnerColor,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 32),

                    // Secret words
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyan.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                    border: Border.all(
                                      color: AppTheme.cyan.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Civilian's Word",
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        civilianWord ?? '',
                                        style: const TextStyle(
                                          color: AppTheme.cyan,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                    border: Border.all(
                                      color: Colors.red.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text(
                                        "Undercover's Word",
                                        style: TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        undercoverWord ?? '',
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const SizedBox(height: 32),

                    // Player roles
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.allPlayers.length,
                        itemBuilder: (context, index) {
                          final player = provider.allPlayers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              border: Border.all(
                                color: player.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: player.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  child: Icon(
                                    player.icon,
                                    color: player.color,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        player.name,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (player.clue != null)
                                        Text(
                                          '"${player.clue}"',
                                          style: const TextStyle(
                                            color: AppTheme.textMuted,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(player.role).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: _getRoleColor(player.role),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    player.roleName,
                                    style: TextStyle(
                                      color: _getRoleColor(player.role),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate(delay: (index * 50).ms).fadeIn();
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Replay button
                    GlowingButton(
                      text: 'PLAY AGAIN',
                      onPressed: () {
                        // Restart game with same players
                        provider.restartGame();
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const RoleRevealScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                          (route) => false,
                        );
                      },
                      gradient: AppTheme.magentaGradient,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRoleColor(UndercoverRole role) {
    switch (role) {
      case UndercoverRole.civilian:
        return AppTheme.cyan;
      case UndercoverRole.undercover:
        return Colors.red;
      case UndercoverRole.mrWhite:
        return Colors.orange;
    }
  }
}

