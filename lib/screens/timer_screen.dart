import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/question.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glowing_button.dart';
import 'spin_bottle_screen.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> with SingleTickerProviderStateMixin {
  late int _remainingSeconds;
  late int _totalSeconds;
  Timer? _timer;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    final provider = context.read<GameProvider>();
    _totalSeconds = provider.timerSeconds > 0 ? provider.timerSeconds : 30;
    _remainingSeconds = _totalSeconds;

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  void _complete() {
    _timer?.cancel();
    context.read<GameProvider>().completeChallenge();
    _navigateToSpin();
  }

  void _forfeit() {
    _timer?.cancel();
    context.read<GameProvider>().forfeitChallenge();
    _navigateToSpin();
  }

  void _navigateToSpin() {
    Navigator.pushAndRemoveUntil(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const SpinBottleScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
      (route) => route.isFirst,
    );
  }

  String _formatTime(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalSeconds > 0 ? _remainingSeconds / _totalSeconds : 0.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, provider, _) {
              final currentPlayer = provider.currentPlayer;
              final question = provider.currentQuestion;
              final isDare = question?.type == QuestionType.dare;
              final accent = isDare ? AppTheme.magenta : AppTheme.cyan;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 28),
                          color: AppTheme.textSecondary,
                        ),
                        Expanded(
                          child: Text(
                            "${currentPlayer?.name.toUpperCase() ?? ''}'S TURN",
                            textAlign: TextAlign.center,
                            style: AppTheme.body(
                              fontSize: 13,
                              color: accent,
                              weight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const Spacer(),

                    Text(
                      isDare ? 'DARE' : 'TRUTH',
                      style: AppTheme.display(fontSize: 22, color: accent, letterSpacing: 6),
                    ).animate().fadeIn(delay: 100.ms),

                    const SizedBox(height: 48),

                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return SizedBox(
                          width: 260,
                          height: 260,
                          child: CustomPaint(
                            painter: TimerCirclePainter(
                              progress: progress,
                              color: accent,
                              pulseValue: _pulseController.value,
                            ),
                            child: Center(
                              child: Text(
                                _formatTime(_remainingSeconds),
                                style: AppTheme.mono(fontSize: 52, color: AppTheme.textPrimary),
                              ),
                            ),
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.9, 0.9)),

                    const Spacer(),

                    GlowingButton(
                      text: 'COMPLETE',
                      onPressed: _complete,
                      gradient: AppTheme.cyanGradient,
                      glowColor: AppTheme.cyan,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    GlowingButton(
                      text: 'FORFEIT',
                      onPressed: _forfeit,
                      glowColor: AppTheme.textMuted,
                      isOutlined: true,
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 32),
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

class TimerCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double pulseValue;

  TimerCirclePainter({required this.progress, required this.color, required this.pulseValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    canvas.drawCircle(center, radius, bgPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 + (pulseValue * 0.2))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final sweepAngle = 2 * pi * progress;
    const startAngle = -pi / 2;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, glowPaint);
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant TimerCirclePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.pulseValue != pulseValue;
  }
}
