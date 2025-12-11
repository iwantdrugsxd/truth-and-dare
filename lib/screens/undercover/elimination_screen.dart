import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../models/undercover_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'clue_giving_screen.dart';
import 'game_end_screen.dart';
import 'mr_white_guess_screen.dart';

class EliminationScreen extends StatefulWidget {
  const EliminationScreen({super.key});

  @override
  State<EliminationScreen> createState() => _EliminationScreenState();
}

class _EliminationScreenState extends State<EliminationScreen> {
  bool _showDetails = false;
  bool _canContinue = false;

  @override
  void initState() {
    super.initState();
    // Show details after a dramatic pause
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _showDetails = true;
        });
        // Check if we can continue after showing details
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _checkContinueCondition();
          }
        });
      }
    });
  }

  void _checkContinueCondition() {
    final provider = context.read<UndercoverProvider>();
    final eliminatedId = provider.eliminatedPlayerId;
    if (eliminatedId == null) return;

    final eliminated = provider.allPlayers.firstWhere((p) => p.id == eliminatedId);
    final isMrWhite = eliminated.role == UndercoverRole.mrWhite;
    final isCivilian = eliminated.role == UndercoverRole.civilian;

    // If Mr. White, show guess screen after delay
    if (isMrWhite && _showDetails) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
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
          }
        });
      });
      return;
    }

    // If civilian eliminated, check if game should end
    if (isCivilian) {
      final alivePlayers = provider.players;
      final aliveUndercovers = alivePlayers.where((p) => p.role == UndercoverRole.undercover).length;
      final aliveMrWhite = alivePlayers.where((p) => p.role == UndercoverRole.mrWhite).length;
      final aliveCivilians = alivePlayers.where((p) => p.role == UndercoverRole.civilian).length;
      final aliveBadGuys = aliveUndercovers + aliveMrWhite;

      // Bad guys win automatically if civilians < bad guys
      if (aliveCivilians < aliveBadGuys && aliveBadGuys > 0) {
        // Game ends, bad guys win
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) {
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
            }
          });
        });
        return;
      } else {
        // Game continues
        setState(() {
          _canContinue = true;
        });
      }
    } else {
      // Undercover eliminated - check win conditions
      provider.checkWinConditions();
      if (provider.phase == GamePhase.gameEnd) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Future.delayed(const Duration(milliseconds: 2000), () {
            if (mounted) {
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
            }
          });
        });
      } else {
        setState(() {
          _canContinue = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        final eliminatedId = provider.eliminatedPlayerId;
        if (eliminatedId == null) return const SizedBox.shrink();

        final eliminated = provider.allPlayers.firstWhere((p) => p.id == eliminatedId);
        final isMrWhite = eliminated.role == UndercoverRole.mrWhite;
        final isCivilian = eliminated.role == UndercoverRole.civilian;

        // Calculate remaining counts
        final alivePlayers = provider.players;
        final remainingUndercovers = alivePlayers.where((p) => p.role == UndercoverRole.undercover).length;
        final remainingMrWhite = alivePlayers.where((p) => p.role == UndercoverRole.mrWhite).length;
        final remainingCivilians = alivePlayers.where((p) => p.role == UndercoverRole.civilian).length;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    Row(
                      children: [
                        TouchableIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textSecondary,
                          iconSize: 32,
                        ),
                        const Expanded(
                          child: Text(
                            'ELIMINATION',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Dramatic elimination text
                    Text(
                      'ELIMINATED',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 8,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 48),

                    // Eliminated player card
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(
                          color: Colors.red.withOpacity(0.5),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: eliminated.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                color: Colors.red,
                                width: 3,
                              ),
                            ),
                            child: Icon(
                              eliminated.icon,
                              color: eliminated.color,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            eliminated.name,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(eliminated.role).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: _getRoleColor(eliminated.role),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              eliminated.roleName.toUpperCase(),
                              style: TextStyle(
                                color: _getRoleColor(eliminated.role),
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).scale(),

                    if (_showDetails) ...[
                      const SizedBox(height: 48),

                      // Result message
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: eliminated.role == UndercoverRole.undercover
                              ? AppTheme.cyan.withOpacity(0.2)
                              : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          border: Border.all(
                            color: eliminated.role == UndercoverRole.undercover
                                ? AppTheme.cyan
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Text(
                          eliminated.role == UndercoverRole.undercover
                              ? 'You caught the Undercover!'
                              : eliminated.role == UndercoverRole.mrWhite
                                  ? '${eliminated.name} was Mr. White!'
                                  : '${eliminated.name} was a ${eliminated.roleName}',
                          style: TextStyle(
                            color: eliminated.role == UndercoverRole.undercover
                                ? AppTheme.cyan
                                : AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),

                      const SizedBox(height: 32),

                      // Remaining counts
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Remaining',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildCountRow('Undercovers', remainingUndercovers, Colors.red),
                            if (remainingMrWhite > 0) ...[
                              const SizedBox(height: 12),
                              _buildCountRow('Mr. White', remainingMrWhite, Colors.orange),
                            ],
                            const SizedBox(height: 12),
                            _buildCountRow('Civilians', remainingCivilians, AppTheme.cyan),
                          ],
                        ),
                      ).animate().fadeIn(delay: 1500.ms).slideY(begin: 0.2),
                    ],

                    const SizedBox(height: 40),

                    // Continue button
                    if (_canContinue && !isMrWhite)
                      GlowingButton(
                        text: 'CONTINUE GAME',
                        onPressed: () {
                          // Start next round of clue giving
                          provider.startClueGiving();
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
                        },
                        gradient: AppTheme.magentaGradient,
                        glowColor: AppTheme.magenta,
                      ).animate().fadeIn(delay: 2000.ms).slideY(begin: 0.2),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCountRow(String label, int count, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color,
              width: 1,
            ),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
