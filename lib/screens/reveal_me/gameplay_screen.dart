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
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocus = FocusNode();
  bool _isSubmitting = false;
  bool _answerSubmitted = false;
  static const int maxCharacters = 140;

  @override
  void initState() {
    super.initState();
    // Load question when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RevealMeProvider>();
      provider.refreshGameState();
      // Load existing answer if any
      if (provider.currentAnswer != null) {
        _answerController.text = provider.currentAnswer!;
        setState(() {
          _answerSubmitted = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _answerFocus.dispose();
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
          // Auto-submit answer if timer runs out
          if (!_answerSubmitted && _answerController.text.trim().isNotEmpty) {
            _submitAnswer();
          }
        }
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an answer'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_isSubmitting || _answerSubmitted) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<RevealMeProvider>();
    
    try {
      await provider.submitAnswer(_answerController.text.trim());
      setState(() {
        _answerSubmitted = true;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _nextQuestion() async {
    final provider = context.read<RevealMeProvider>();
    
    // Ensure answer is submitted before moving to next
    if (!_answerSubmitted && _answerController.text.trim().isNotEmpty) {
      await _submitAnswer();
    }
    
    if (!_answerSubmitted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please submit your answer first'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    _timer?.cancel();
    await provider.moveToRating();
    
    if (mounted) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final question = provider.currentQuestion;
        final roundNumber = provider.currentRound;
        final totalRounds = provider.questionsPerPlayer;

        if (question == null) {
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
                    // Header - Round indicator (Psych! style)
                    Row(
                      children: [
                        Text(
                          'Round $roundNumber of $totalRounds',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress bar (Psych! style)
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: roundNumber / totalRounds,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.magentaGradient,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Question (Psych! style - large, centered)
                    Text(
                      question.question,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Circular Timer (Psych! style)
                    if (_hasStarted)
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.magenta,
                              AppTheme.cyan,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.magenta.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                provider.remainingSeconds.toString(),
                                style: const TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 64,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const Text(
                                'S',
                                style: TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn().scale()
                    else
                      Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.cardBackground.withOpacity(0.3),
                          border: Border.all(
                            color: AppTheme.textSecondary.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${provider.timerSeconds}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 64,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 48),

                    // Answer Input (Psych! style)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        border: Border.all(
                          color: AppTheme.magenta.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _answerController,
                            focusNode: _answerFocus,
                            maxLines: 4,
                            maxLength: maxCharacters,
                            enabled: !_answerSubmitted && _hasStarted,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Type your witty answer here...',
                              hintStyle: TextStyle(
                                color: AppTheme.textSecondary.withOpacity(0.5),
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              counterText: '',
                            ),
                            onChanged: (value) {
                              setState(() {});
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_answerController.text.length}/$maxCharacters characters',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                              if (_answerSubmitted)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.cyan.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: AppTheme.cyan,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Submitted',
                                        style: TextStyle(
                                          color: AppTheme.cyan,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button (Psych! style)
                    if (!_answerSubmitted && _hasStarted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.magentaGradient,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          boxShadow: AppTheme.magentaGlow,
                        ),
                        child: TextButton(
                          onPressed: _isSubmitting ? null : _submitAnswer,
                          child: Text(
                            _isSubmitting ? 'SUBMITTING...' : 'SUBMIT ANSWER',
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else if (!_hasStarted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.magentaGradient,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          boxShadow: AppTheme.magentaGlow,
                        ),
                        child: TextButton(
                          onPressed: _startTimer,
                          child: const Text(
                            'START TIMER',
                            style: TextStyle(
                              color: AppTheme.background,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Text(
                          'Waiting for all players to answer...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
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

}

