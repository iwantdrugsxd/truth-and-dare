import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../models/undercover_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'clue_giving_screen.dart';
import 'game_end_screen.dart';
import 'mr_white_guess_screen.dart';

class EliminationScreen extends StatelessWidget {
  const EliminationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        final eliminatedId = provider.eliminatedPlayerId;
        if (eliminatedId == null) return const SizedBox.shrink();

        final eliminated = provider.allPlayers.firstWhere((p) => p.id == eliminatedId);
        final isMrWhite = eliminated.role == UndercoverRole.mrWhite;

        // If Mr. White, show guess screen
        if (isMrWhite) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const MrWhiteGuessScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          });
        }

        // Check if game ended
        if (provider.phase == GamePhase.gameEnd) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const GameEndScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          });
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Eliminated player
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: eliminated.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: Icon(
                              eliminated.icon,
                              color: eliminated.color,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            eliminated.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(eliminated.role).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _getRoleColor(eliminated.role),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              eliminated.roleName.toUpperCase(),
                              style: TextStyle(
                                color: _getRoleColor(eliminated.role),
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 32),

                    // Result message
                    Text(
                      eliminated.role == UndercoverRole.undercover
                          ? 'You caught the Undercover!\nCivilians Win!'
                          : '${eliminated.name} was a ${eliminated.roleName}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),

                    const Spacer(),

                    // Continue button
                    if (provider.phase != GamePhase.gameEnd)
                      GlowingButton(
                        text: 'NEXT ROUND',
                        onPressed: () {
                          if (provider.phase == GamePhase.clueGiving) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const ClueGivingScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          }
                        },
                        gradient: AppTheme.magentaGradient,
                      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
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

