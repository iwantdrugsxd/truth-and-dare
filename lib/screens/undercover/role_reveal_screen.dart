import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../models/undercover_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'clue_giving_screen.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen> {
  int _currentRevealIndex = 0;

  void _nextPlayer() {
    final provider = context.read<UndercoverProvider>();
    if (_currentRevealIndex < provider.allPlayers.length - 1) {
      setState(() {
        _currentRevealIndex++;
      });
    } else {
      // All players revealed, start clue giving
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        if (_currentRevealIndex >= provider.allPlayers.length) {
          return const SizedBox.shrink();
        }

        final player = provider.allPlayers[_currentRevealIndex];
        final isLast = _currentRevealIndex == provider.allPlayers.length - 1;

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
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, size: 32),
                          color: AppTheme.textSecondary,
                        ),
                        const Expanded(
                          child: Text(
                            'ROLE REVEAL',
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

                    const SizedBox(height: 48),

                    // Instruction
                    Text(
                      'Pass the Phone & Tap Your Name',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(begin: -0.2),

                    const SizedBox(height: 48),

                    // Player list
                    Expanded(
                      child: ListView.builder(
                        itemCount: provider.allPlayers.length,
                        itemBuilder: (context, index) {
                          final p = provider.allPlayers[index];
                          final isCurrent = index == _currentRevealIndex;
                          final isRevealed = index < _currentRevealIndex;

                          return GestureDetector(
                            onTap: isCurrent ? () {
                              provider.markRoleRevealed(p.id);
                              _nextPlayer();
                            } : null,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppTheme.magenta.withOpacity(0.2)
                                    : AppTheme.cardBackground,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                border: Border.all(
                                  color: isCurrent
                                      ? AppTheme.magenta
                                      : AppTheme.surfaceLight,
                                  width: isCurrent ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: p.color.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(25),
                                    ),
                                    child: Icon(
                                      p.icon,
                                      color: p.color,
                                      size: 28,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        if (isRevealed)
                                          Text(
                                            p.roleName,
                                            style: TextStyle(
                                              color: _getRoleColor(p.role),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        if (isRevealed && p.word != null)
                                          Text(
                                            'Word: ${p.word}',
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrent)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.magentaGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Text(
                                        'Your turn!',
                                        style: TextStyle(
                                          color: AppTheme.background,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  if (isRevealed)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.magenta,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                          ).animate(delay: (index * 50).ms).fadeIn();
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Continue button (for last player)
                    if (isLast)
                      GlowingButton(
                        text: 'START THE ROUND',
                        onPressed: () {
                          provider.markRoleRevealed(player.id);
                          _nextPlayer();
                        },
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

