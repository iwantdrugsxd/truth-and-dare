import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glowing_button.dart';
import 'question_display_screen.dart';

class TruthDareSelectionScreen extends StatefulWidget {
  const TruthDareSelectionScreen({super.key});

  @override
  State<TruthDareSelectionScreen> createState() => _TruthDareSelectionScreenState();
}

class _TruthDareSelectionScreenState extends State<TruthDareSelectionScreen> {
  int _minutes = 0;
  int _seconds = 30;

  void _selectTruth() {
    final provider = context.read<GameProvider>();
    provider.setTimerSeconds(_minutes * 60 + _seconds);
    provider.selectTruth();
    _navigateToQuestion();
  }

  void _selectDare() {
    final provider = context.read<GameProvider>();
    provider.setTimerSeconds(_minutes * 60 + _seconds);
    provider.selectDare();
    _navigateToQuestion();
  }

  void _navigateToQuestion() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const QuestionDisplayScreen(),
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
          child: Consumer<GameProvider>(
            builder: (context, provider, _) {
              final currentPlayer = provider.currentPlayer;

              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, size: 32),
                          color: AppTheme.textSecondary,
                        ),
                        Expanded(
                          child: Text(
                            "${currentPlayer?.name.toUpperCase() ?? ''}'S TURN",
                            textAlign: TextAlign.center,
                            style: AppTheme.body(
                              fontSize: 13,
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
                      'CHOOSE YOUR FATE',
                      textAlign: TextAlign.center,
                      style: AppTheme.display(fontSize: 27, weight: FontWeight.w700),
                    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 8),

                    Text(
                      'Set the clock, then pick your poison',
                      style: AppTheme.body(fontSize: 14, color: AppTheme.textSecondary),
                    ).animate().fadeIn(delay: 150.ms),

                    const SizedBox(height: 40),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimerPicker('Minutes', _minutes, 59, (val) {
                          setState(() => _minutes = val);
                        }),
                        const SizedBox(width: 20),
                        _buildTimerPicker('Seconds', _seconds, 59, (val) {
                          setState(() => _seconds = val);
                        }),
                      ],
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const Spacer(),

                    GlowingButton(
                      text: 'TRUTH',
                      onPressed: _selectTruth,
                      gradient: AppTheme.cyanGradient,
                      glowColor: AppTheme.cyan,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    GlowingButton(
                      text: 'DARE',
                      onPressed: _selectDare,
                      gradient: AppTheme.magentaGradient,
                      glowColor: AppTheme.magenta,
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

  Widget _buildTimerPicker(String label, int value, int maxVal, Function(int) onChanged) {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(color: AppTheme.magenta.withOpacity(0.3), width: 1),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  if (value < maxVal) onChanged(value + 1);
                },
                child: const Icon(Icons.keyboard_arrow_up, color: AppTheme.textSecondary, size: 20),
              ),
              Text(value.toString().padLeft(2, '0'), style: AppTheme.mono(fontSize: 24)),
              GestureDetector(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                child: const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary, size: 20),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: AppTheme.body(fontSize: 12, color: AppTheme.textMuted)),
      ],
    );
  }
}
