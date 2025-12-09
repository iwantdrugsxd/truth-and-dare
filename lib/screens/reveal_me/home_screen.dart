import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'create_game_screen.dart';
import 'join_game_screen.dart';

class RevealMeHomeScreen extends StatelessWidget {
  const RevealMeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Logo/Title
                Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: AppTheme.magentaGradient,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: AppTheme.magentaGlow,
                      ),
                      child: const Icon(
                        Icons.visibility,
                        size: 50,
                        color: AppTheme.background,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'REVEAL ME',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppTheme.magenta.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'How spicy can you get?',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 64),

                // Game Options
                Column(
                  children: [
                    // Create Game Button
                    GlowingButton(
                      text: 'CREATE GAME',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const CreateGameScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      gradient: AppTheme.magentaGradient,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Join Game Button
                    Container(
                      width: double.infinity,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: Border.all(
                          color: AppTheme.magenta,
                          width: 2,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const JoinGameScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          child: Center(
                            child: Text(
                              'JOIN GAME',
                              style: TextStyle(
                                color: AppTheme.magenta,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 32),

                    // How to Play
                    TextButton(
                      onPressed: () {
                        // Show how to play dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppTheme.cardBackground,
                            title: const Text(
                              'How to Play',
                              style: TextStyle(color: AppTheme.textPrimary),
                            ),
                            content: const Text(
                              '1. Host creates a game and shares the code\n'
                              '2. Players join with the code and their name\n'
                              '3. Each player answers spicy questions within the timer\n'
                              '4. Other players rate answers 1-10 based on how spicy/funny they are\n'
                              '5. Player with highest average score wins!',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Got it'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Text(
                        'How to Play',
                        style: TextStyle(
                          color: AppTheme.magenta,
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


