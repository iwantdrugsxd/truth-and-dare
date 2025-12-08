import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'rating_screen.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen> {
  Timer? _timer;
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    final provider = context.read<RevealMeProvider>();
    if (!_hasStarted) {
      setState(() {
        _hasStarted = true;
      });
      provider.startTimer();
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        provider.tickTimer();
        if (provider.remainingSeconds == 0) {
          timer.cancel();
        }
      });
    }
  }

  void _nextQuestion() {
    final provider = context.read<RevealMeProvider>();
    _timer?.cancel();
    provider.moveToRating();
    
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RatingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final currentPlayer = provider.currentPlayer;
        final question = provider.currentQuestion;
        final questionNumber = provider.currentQuestionIndex + 1;
        final totalQuestions = provider.questionsPerPlayer;
        final playerNumber = provider.currentPlayerIndex + 1;
        final totalPlayers = provider.players.length;

        if (currentPlayer == null || question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                    // Header
                    Row(
                      children: [
                        Text(
                          'Question $questionNumber of $totalQuestions',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        TouchableIconButton(
                          icon: Icons.close,
                          onPressed: () {},
                          color: AppTheme.textSecondary,
                          iconSize: 28,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Current Player
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.magentaGradient,
                        boxShadow: AppTheme.magentaGlow,
                      ),
                      child: Center(
                        child: Text(
                          currentPlayer.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.background,
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "It's ${currentPlayer.name}'s turn!",
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(
                          color: AppTheme.magenta.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.magenta.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.magentaGradient,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              question.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.background,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            question.question,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 48),

                    // Timer
                    if (_hasStarted)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildTimeBox('00', 'Hours'),
                            const SizedBox(width: 12),
                            _buildTimeBox('00', 'Minutes'),
                            const SizedBox(width: 12),
                            _buildTimeBox(
                              provider.remainingSeconds.toString().padLeft(2, '0'),
                              'Seconds',
                              isActive: true,
                            ),
                          ],
                        ),
                      ).animate().fadeIn()
                    else
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Text(
                          'Tap "Start Timer" when ready to answer',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 48),

                    // Action Button
                    if (!_hasStarted)
                      GlowingButton(
                        text: 'START TIMER',
                        onPressed: _startTimer,
                        gradient: AppTheme.magentaGradient,
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else
                      GlowingButton(
                        text: 'NEXT QUESTION',
                        onPressed: _nextQuestion,
                        gradient: AppTheme.magentaGradient,
                      ).animate().fadeIn().slideY(begin: 0.2),

                    const SizedBox(height: 24),

                    // Progress
                    Text(
                      'Player $playerNumber of $totalPlayers',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeBox(String value, String label, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.magenta.withOpacity(0.2)
            : AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
        border: Border.all(
          color: isActive
              ? AppTheme.magenta
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: isActive ? AppTheme.magenta : AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

