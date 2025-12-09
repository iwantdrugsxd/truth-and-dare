import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/question.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import 'timer_screen.dart';

class QuestionDisplayScreen extends StatefulWidget {
  const QuestionDisplayScreen({super.key});

  @override
  State<QuestionDisplayScreen> createState() => _QuestionDisplayScreenState();
}

class _QuestionDisplayScreenState extends State<QuestionDisplayScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-start timer when screen loads (no button needed)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer(context);
    });
  }

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
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, provider, _) {
              final question = provider.currentQuestion;
              final currentPlayer = provider.currentPlayer;
              final isDare = question?.type == QuestionType.dare;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, size: 32),
                          color: AppTheme.textSecondary,
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const Spacer(),

                    // Question type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isDare ? AppTheme.magenta : AppTheme.cyan,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isDare ? 'DARE' : 'TRUTH',
                        style: TextStyle(
                          color: isDare ? AppTheme.magenta : AppTheme.cyan,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 3,
                        ),
                      ),
                    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.8, 0.8)),

                    const SizedBox(height: 12),

                    // Player name
                    Text(
                      "${currentPlayer?.name}'s Turn",
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 48),

                    // Question text
                    Text(
                      question?.text ?? 'No question',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

                    const SizedBox(height: 16),

                    // Category badge
                    if (question != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          question.category,
                          style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ).animate().fadeIn(delay: 300.ms),

                    const Spacer(),

                    // Timer auto-starts - no button needed
                    // (Navigates to TimerScreen automatically)
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
