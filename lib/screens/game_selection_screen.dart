import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/glowing_button.dart';
import '../services/auth_service.dart';
import '../widgets/touchable_icon_button.dart';
import 'player_setup_screen.dart';
import 'undercover/undercover_setup_screen.dart';
import 'reveal_me/home_screen.dart';
import 'auth/login_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: AppTheme.cyanGradient,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: AppTheme.cyanGlow,
                      ),
                      child: const Icon(
                        Icons.casino,
                        size: 60,
                        color: AppTheme.background,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'PARTIZO',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: AppTheme.cyan.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose Your Game',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 64),

                // Game Options
                Column(
                  children: [
                    // Truth or Dare Button
                    GlowingButton(
                      text: 'TRUTH OR DARE',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const PlayerSetupScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      gradient: AppTheme.cyanGradient,
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Undercover Button
                    GlowingButton(
                      text: 'UNDERCOVER',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const UndercoverSetupScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      gradient: AppTheme.magentaGradient,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),

                    // Reveal Me Button
                    GlowingButton(
                      text: 'REVEAL ME',
                      onPressed: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                const RevealMeHomeScreen(),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                            transitionDuration: const Duration(milliseconds: 500),
                          ),
                        );
                      },
                      gradient: LinearGradient(
                        colors: [AppTheme.pink, AppTheme.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),
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

