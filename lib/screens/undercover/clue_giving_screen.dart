import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'voting_screen.dart';

class ClueGivingScreen extends StatelessWidget {
  const ClueGivingScreen({super.key});

  void _nextPlayer(BuildContext context) {
    final provider = context.read<UndercoverProvider>();
    final currentPlayer = provider.currentPlayer;
    
    if (currentPlayer != null) {
      // Mark as done (clue given verbally)
      provider.submitClue(currentPlayer.id, '');
      
      // Move to next player
      if (provider.currentPlayerIndex < provider.players.length - 1) {
        provider.nextPlayer();
      } else {
        // All players done, go to voting
        provider.startVoting();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const VotingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        final currentPlayer = provider.currentPlayer;
        if (currentPlayer == null) return const SizedBox.shrink();

        final isLastPlayer = provider.currentPlayerIndex >= provider.players.length - 1;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      children: [
                        TouchableIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textSecondary,
                          iconSize: 32,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'ROUND ${provider.currentRound}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                              ),
                              const Text(
                                'Clue Giving',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 48),

                    // Current player
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        gradient: AppTheme.magentaGradient,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: AppTheme.magentaGlow,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: AppTheme.background.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Icon(
                              currentPlayer.icon,
                              color: AppTheme.background,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            currentPlayer.name,
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 32,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Give your clue verbally',
                            style: TextStyle(
                              color: AppTheme.background.withOpacity(0.9),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 64),

                    // Progress
                    Text(
                      '${provider.currentPlayerIndex + 1} / ${provider.players.length}',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Next button
                    GlowingButton(
                      text: isLastPlayer ? 'GO TO VOTING' : 'NEXT PLAYER',
                      onPressed: () => _nextPlayer(context),
                      gradient: AppTheme.magentaGradient,
                    ).animate().fadeIn().slideY(begin: 0.2),
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
