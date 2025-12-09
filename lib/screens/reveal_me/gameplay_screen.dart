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
  bool _hasStarted = true; // CRITICAL: Always true - timer never shows button
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocus = FocusNode();
  bool _isSubmitting = false;
  bool _answerSubmitted = false;
  static const int maxCharacters = 140;
  
  // Real-time timer state (Psych! style)
  DateTime? _serverStartTime;
  int _duration = 30;
  int _remainingSeconds = 30; // Initialize with default value

  @override
  void initState() {
    super.initState();
    // CRITICAL: Start timer initialization IMMEDIATELY
    // Use synchronous initialization where possible to prevent any button from appearing
    _initializeTimerAsync();
  }
  
  // Separate async initialization to prevent blocking
  Future<void> _initializeTimerAsync() async {
    // Small delay to ensure widget is mounted and context is available
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;
    
    final provider = context.read<RevealMeProvider>();
    
    // Refresh to get latest game state
    await provider.refreshGameState();
    
    if (!mounted) return;
    
    // Load existing answer if any
    if (provider.currentAnswer != null) {
      _answerController.text = provider.currentAnswer!;
      if (mounted) {
        setState(() {
          _answerSubmitted = true;
        });
      }
    } else {
      // Initialize timer immediately - NO BUTTON EVER SHOWS
      // Timer starts automatically, no user interaction needed
      _initializeTimer(provider);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    _answerFocus.dispose();
    super.dispose();
  }

  // THE GOLDEN RULE: Real-time synchronized timer (Psych! style)
  // Backend sends: roundStartTime (timestamp) + roundDuration
  // Client calculates: remaining = duration - (now - startTime)
  // NO BUTTON - Timer starts automatically! _hasStarted is always true
  void _initializeTimer(RevealMeProvider provider) {
    if (_answerSubmitted) return;
    
    // Get timer start time and duration from server
    String? timerStartTimeStr = provider.timerStartTime;
    _duration = provider.timerSeconds;
    
    if (timerStartTimeStr != null && timerStartTimeStr.isNotEmpty) {
      try {
        _serverStartTime = DateTime.parse(timerStartTimeStr);
        print('[TIMER] ✅ Auto-started with server time: ${_serverStartTime!.toIso8601String()}, Duration: ${_duration}s');
      } catch (e) {
        print('[TIMER] ❌ Error parsing: $e');
        _serverStartTime = DateTime.now(); // Fallback to local time
      }
    } else {
      print('[TIMER] ⚠️ No server time, using local fallback');
      _serverStartTime = DateTime.now(); // Fallback to local time
    }
    
    // Calculate initial remaining time IMMEDIATELY
    if (_serverStartTime != null) {
      final now = DateTime.now();
      final elapsed = now.difference(_serverStartTime!).inSeconds;
      _remainingSeconds = (_duration - elapsed).clamp(0, _duration);
    } else {
      _remainingSeconds = _duration;
    }
    
    // CRITICAL: Update UI immediately to prevent any visual glitch
    // This ensures timer displays correctly from the first frame
    if (mounted) {
      setState(() {
        // Force UI update with correct timer state
      });
    }
    
    // Start local timer that calculates remaining time
    // Tick every 200ms for smooth UI (Psych! style)
    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (!mounted) {
        _timer?.cancel();
        return;
      }
      
      // THE GOLDEN RULE: Calculate remaining time locally
      // remaining = duration - (now - startTime)
      if (_serverStartTime != null) {
        final now = DateTime.now();
        final elapsed = now.difference(_serverStartTime!).inSeconds;
        final remaining = (_duration - elapsed).clamp(0, _duration);
        
        setState(() {
          _remainingSeconds = remaining;
        });
        
        // Update provider for UI
        provider.setRemainingSeconds(remaining);
        
        // Auto-submit when timer reaches 0
        if (remaining <= 0 && !_answerSubmitted) {
          _timer?.cancel();
          if (_answerController.text.trim().isEmpty) {
            _answerController.text = '...';
          }
          _submitAnswer();
        }
      } else {
        // Fallback: use provider's timer
        provider.tickTimer();
        setState(() {
          _remainingSeconds = provider.remainingSeconds;
        });
        if (provider.remainingSeconds <= 0 && !_answerSubmitted) {
          _timer?.cancel();
          if (_answerController.text.trim().isEmpty) {
            _answerController.text = '...';
          }
          _submitAnswer();
        }
      }
      
      // Check if all players answered (poll every 2 seconds)
      if (mounted && _remainingSeconds % 2 == 0) {
        provider.refreshGameState().then((_) {
          if (mounted && provider.phase == RevealMePhase.reveal) {
            _timer?.cancel();
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
        });
      }
    });
  }

  Future<void> _submitAnswer() async {
    // Allow submission even if empty (will submit "..." if empty)
    final answerText = _answerController.text.trim();
    final finalAnswer = answerText.isEmpty ? '...' : answerText;

    if (_isSubmitting || _answerSubmitted) {
      print('[SUBMIT] Already submitting or submitted, ignoring');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<RevealMeProvider>();
    
    try {
      print('[SUBMIT] Submitting answer: "$finalAnswer"');
      await provider.submitAnswer(finalAnswer);
      setState(() {
        _answerSubmitted = true;
        _isSubmitting = false;
        _answerController.text = finalAnswer; // Update UI with final answer
      });
      print('[SUBMIT] ✅ Answer submitted successfully');
    } catch (e) {
      print('[SUBMIT] ❌ Error: $e');
      setState(() {
        _isSubmitting = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting answer: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final question = provider.currentQuestion;
        if (question == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final roundNumber = provider.currentRound;
        final totalRounds = provider.questionsPerPlayer;
        
        // Use local remaining seconds for display (always use _remainingSeconds since _hasStarted is always true)
        final displaySeconds = _remainingSeconds;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
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

                    // Circular Timer (Psych! style) - Real-time synced
                    // ALWAYS show timer (no conditional rendering to prevent glitches)
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: displaySeconds > 0
                            ? LinearGradient(
                                colors: [
                                  AppTheme.magenta,
                                  AppTheme.cyan,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: displaySeconds == 0
                            ? AppTheme.cardBackground.withOpacity(0.3)
                            : null,
                        border: Border.all(
                          color: displaySeconds > 0
                              ? Colors.transparent
                              : AppTheme.textSecondary.withOpacity(0.3),
                          width: 2,
                        ),
                        boxShadow: displaySeconds > 0
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
                              displaySeconds.toString(),
                              style: TextStyle(
                                color: displaySeconds > 0
                                    ? AppTheme.background
                                    : AppTheme.textSecondary,
                                fontSize: 64,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (displaySeconds > 0)
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
                            maxLength: maxCharacters,
                            maxLines: 3,
                            enabled: !_answerSubmitted && !_isSubmitting,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
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

                    // Submit Button (Psych! style) - Always enabled if not submitted
                    if (!_answerSubmitted)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: _isSubmitting 
                              ? LinearGradient(colors: [AppTheme.magenta.withOpacity(0.5), AppTheme.cyan.withOpacity(0.5)])
                              : AppTheme.magentaGradient,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          boxShadow: _isSubmitting ? null : AppTheme.magentaGlow,
                        ),
                        child: TextButton(
                          onPressed: _isSubmitting 
                              ? null 
                              : () {
                                  print('[SUBMIT BUTTON] Clicked! Answer: "${_answerController.text}"');
                                  _submitAnswer();
                                },
                          child: Text(
                            _isSubmitting ? 'SUBMITTING...' : 'SUBMIT ANSWER',
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
