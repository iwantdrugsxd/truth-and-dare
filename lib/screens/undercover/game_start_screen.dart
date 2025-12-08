import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'clue_giving_screen.dart';

class GameStartScreen extends StatelessWidget {
  const GameStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          // Game title
                          Text(
                            'UNDERCOVER',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  color: AppTheme.magenta.withOpacity(0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                          ).animate().fadeIn().scale(),

                          const SizedBox(height: 16),

                          Text(
                            'Game Starting',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ).animate().fadeIn(delay: 200.ms),

                          const SizedBox(height: 32),

                          // Game info
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                              border: Border.all(
                                color: AppTheme.magenta.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                _buildInfoRow('Players', '${provider.allPlayers.length}'),
                                const SizedBox(height: 16),
                                _buildInfoRow('Undercovers', '${provider.numUndercover}'),
                                if (provider.numMrWhite > 0) ...[
                                  const SizedBox(height: 16),
                                  _buildInfoRow('Mr. White', '${provider.numMrWhite}'),
                                ],
                                const SizedBox(height: 16),
                                _buildInfoRow('Civilians', '${provider.allPlayers.length - provider.numUndercover - provider.numMrWhite}'),
                              ],
                            ),
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                          const SizedBox(height: 32),

                          // Instructions
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'How to Play',
                                  style: TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildInstruction('1. Give clues about your word'),
                                const SizedBox(height: 8),
                                _buildInstruction('2. Vote for who you think is Undercover'),
                                const SizedBox(height: 8),
                                _buildInstruction('3. Eliminate players and find the Undercover'),
                              ],
                            ),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                  
                  // Start button - Fixed at bottom
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      gradient: AppTheme.backgroundGradient,
                    ),
                    child: GlowingButton(
                      text: 'START GAME',
                      onPressed: () {
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
                    ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppTheme.magenta,
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildInstruction(String text) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.magenta,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}

