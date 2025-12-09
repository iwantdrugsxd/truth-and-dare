import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import 'reveal_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RevealMeProvider>();
      
      // Force load question to get timer start time
      await provider.refreshGameState();
      
      // Wait a bit for state to settle, then ensure question is loaded
      await Future.delayed(const Duration(milliseconds: 300));
      
      // If still no question or timer time, try loading directly
      if (provider.currentQuestion == null || provider.timerStartTime == null) {
        // Force a refresh to get the question with timer
        await provider.refreshGameState();
        await Future.delayed(const Duration(milliseconds: 200));
      }
      
      // Load existing answer if any
      if (provider.currentAnswer != null) {
        _answerController.text = provider.currentAnswer!;
        setState(() {
          _answerSubmitted = true;
        });
      } else {
        // Auto-start timer immediately when question loads (Psych! style) - synchronized
        // Small delay to ensure timerStartTime is loaded
        await Future.delayed(const Duration(milliseconds: 100));
        _startTimer();
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
    if (!_hasStarted && !_answerSubmitted) {
      setState(() {
        _hasStarted = true;
      });
      
      // Use synchronized timer start time from server
      DateTime? serverStartTime;
      if (provider.timerStartTime != null) {
        try {
          serverStartTime = DateTime.parse(provider.timerStartTime!);
        } catch (e) {
          print('Error parsing timer start time: $e');
        }
      }
      
      // Calculate remaining time based on server start time (synchronized across all devices)
      int remainingSeconds = provider.timerSeconds;
      if (serverStartTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(serverStartTime).inSeconds;
        remainingSeconds = (provider.timerSeconds - elapsed).clamp(0, provider.timerSeconds);
        
        // Set the remaining seconds in provider
        provider.setRemainingSeconds(remainingSeconds);
        
        print('[TIMER] Server start: ${serverStartTime.toIso8601String()}, Now: ${now.toIso8601String()}, Elapsed: ${elapsed}s, Remaining: ${remainingSeconds}s');
      } else {
        // Fallback: start timer locally if no server time
        provider.startTimer();
        print('[TIMER] No server time, starting local timer');
      }
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        provider.tickTimer();
        
        if (provider.remainingSeconds <= 0) {
          timer.cancel();
          // Auto-submit answer when timer runs out (even if empty)
          if (!_answerSubmitted) {
            if (_answerController.text.trim().isEmpty) {
              // Submit empty answer if nothing entered
              _answerController.text = '...';
            }
            await _submitAnswer();
          }
        }
        
        // Re-sync timer every 5 seconds to stay in sync with server
        if (provider.remainingSeconds % 5 == 0 && provider.timerStartTime != null) {
          try {
            final serverStartTime = DateTime.parse(provider.timerStartTime!);
            final now = DateTime.now();
            final elapsed = now.difference(serverStartTime).inSeconds;
            final syncedRemaining = (provider.timerSeconds - elapsed).clamp(0, provider.timerSeconds);
            if ((syncedRemaining - provider.remainingSeconds).abs() > 1) {
              // Timer is out of sync, resync it
              provider.setRemainingSeconds(syncedRemaining);
              print('[TIMER] Resynced: $syncedRemaining seconds remaining');
            }
          } catch (e) {
            // Ignore sync errors
          }
        }
        
        // Check if all players answered and move to reveal (poll every 2 seconds)
        if (mounted && provider.remainingSeconds % 2 == 0) {
          await provider.refreshGameState();
          if (provider.phase == RevealMePhase.reveal) {
            timer.cancel();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      const RevealScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 500),
                ),
              );
            }
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

  // Note: _nextQuestion is no longer used - game auto-advances when all players answer

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
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: _hasStarted && provider.remainingSeconds > 0
                            ? LinearGradient(
                                colors: [
                                  AppTheme.magenta,
                                  AppTheme.cyan,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: !_hasStarted || provider.remainingSeconds == 0
                            ? AppTheme.cardBackground.withOpacity(0.3)
                            : null,
                        border: Border.all(
                          color: _hasStarted && provider.remainingSeconds > 0
                              ? Colors.transparent
                              : AppTheme.textSecondary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: _hasStarted && provider.remainingSeconds > 0
                            ? [
                                BoxShadow(
                                  color: AppTheme.magenta.withOpacity(0.5),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _hasStarted && provider.remainingSeconds > 0
                                  ? provider.remainingSeconds.toString()
                                  : provider.timerSeconds.toString(),
                              style: TextStyle(
                                color: _hasStarted && provider.remainingSeconds > 0
                                    ? AppTheme.background
                                    : AppTheme.textSecondary,
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (_hasStarted && provider.remainingSeconds > 0)
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
                    ).animate().fadeIn().scale(),

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

                    // Submit Button (Psych! style) - Always show if not submitted
                    if (!_answerSubmitted)
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

