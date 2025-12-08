import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../models/reveal_me_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../game_selection_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final winner = provider.winner;
        final sortedPlayers = List<RevealMePlayer>.from(provider.players)
          ..sort((a, b) => b.averageScore.compareTo(a.averageScore));

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Winner Announcement
                    if (winner != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppTheme.magentaGradient,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: AppTheme.magentaGlow,
                        ),
                        child: const Text(
                          'WINNER',
                          style: TextStyle(
                            color: AppTheme.background,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.magentaGradient,
                          boxShadow: AppTheme.magentaGlow,
                        ),
                        child: Center(
                          child: Text(
                            winner.name[0].toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        winner.name,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Average Score: ${winner.averageScore.toStringAsFixed(1)}/10',
                        style: TextStyle(
                          color: AppTheme.magenta,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],

                    const SizedBox(height: 48),

                    // Leaderboard
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Final Scores',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ...sortedPlayers.asMap().entries.map((entry) {
                            final index = entry.key;
                            final player = entry.value;
                            final isWinner = player.id == winner?.id;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isWinner
                                    ? AppTheme.magenta.withOpacity(0.2)
                                    : AppTheme.surfaceLight.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                border: Border.all(
                                  color: isWinner
                                      ? AppTheme.magenta
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Rank
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isWinner
                                          ? AppTheme.magenta
                                          : AppTheme.cardBackground,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: isWinner
                                              ? AppTheme.background
                                              : AppTheme.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Avatar
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: RevealMePlayer.availableColors[
                                          sortedPlayers.indexOf(player) % RevealMePlayer.availableColors.length].withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      RevealMePlayer.availableIcons[
                                          sortedPlayers.indexOf(player) % RevealMePlayer.availableIcons.length],
                                      color: RevealMePlayer.availableColors[
                                          sortedPlayers.indexOf(player) % RevealMePlayer.availableColors.length],
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Name
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (player.isHost)
                                          Text(
                                            'Host',
                                            style: TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Score
                                  Text(
                                    player.averageScore.toStringAsFixed(1),
                                    style: TextStyle(
                                      color: isWinner
                                          ? AppTheme.magenta
                                          : AppTheme.textPrimary,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                          }).toList(),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Play Again Button
                    GlowingButton(
                      text: 'PLAY AGAIN',
                      onPressed: () {
                        provider.resetGame();
                        Navigator.pushAndRemoveUntil(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const GameSelectionScreen(),
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
}

