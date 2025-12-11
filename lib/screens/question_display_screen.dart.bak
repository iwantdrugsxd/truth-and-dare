import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_state.dart';
import '../models/question.dart';
import '../widgets/glowing_button.dart';
import 'timer_screen.dart';

class QuestionDisplayScreen extends StatelessWidget {
  const QuestionDisplayScreen({super.key});

  void _startTimer(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const TimerScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Consumer<GameState>(
              builder: (context, gameState, child) {
                final question = gameState.currentQuestion;
                final isTruth = question?.type == QuestionType.truth;
                final typeColor = isTruth ? AppTheme.primaryCyan : AppTheme.primaryPink;
                
                return Column(
                  children: [
                    // Type label
                    Text(
                      isTruth ? 'TRUTH' : 'DARE',
                      style: AppTheme.displayMedium.copyWith(
                        color: typeColor,
                        letterSpacing: 8,
                      ),
                    ).animate().fadeIn().shimmer(
                      duration: 2000.ms,
                      color: typeColor.withOpacity(0.3),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Player name
                    Text(
                      "${gameState.currentPlayer?.name ?? 'Player'}'s Turn",
                      style: AppTheme.bodyMedium,
                    ).animate().fadeIn(delay: 200.ms),
                    
                    const Spacer(),
                    
                    // Question text
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: typeColor.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        question?.text ?? 'No question available',
                        style: AppTheme.headlineLarge.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ).animate()
                      .fadeIn(delay: 300.ms, duration: 600.ms)
                      .scale(begin: const Offset(0.9, 0.9)),
                    
                    const SizedBox(height: 24),
                    
                    // Category chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: typeColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        question?.category ?? '',
                        style: AppTheme.labelLarge.copyWith(
                          color: typeColor,
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                    
                    const Spacer(),
                    
                    // Complete button
                    GlowingButton(
                      text: 'COMPLETE',
                      onPressed: () => _startTimer(context),
                      gradient: isTruth 
                          ? AppTheme.primaryGradient 
                          : AppTheme.pinkGradient,
                      glowColor: typeColor,
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                    
                    const SizedBox(height: 32),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

