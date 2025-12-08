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
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 30;

  void _selectTruth() {
    final provider = context.read<GameProvider>();
    provider.setTimerSeconds(_hours * 3600 + _minutes * 60 + _seconds);
    provider.selectTruth();
    _navigateToQuestion();
  }

  void _selectDare() {
    final provider = context.read<GameProvider>();
    provider.setTimerSeconds(_hours * 3600 + _minutes * 60 + _seconds);
    provider.selectDare();
    _navigateToQuestion();
  }

  void _navigateToQuestion() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const QuestionDisplayScreen(),
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
              final currentPlayer = provider.currentPlayer;
              
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
                        Expanded(
                          child: Text(
                            "${currentPlayer?.name.toUpperCase()}'S TURN",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ).animate().fadeIn(duration: 400.ms),

                    const Spacer(),

                    // Title
                    Text(
                      'CHOOSE YOUR FATE',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            color: AppTheme.cyan.withOpacity(0.3),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.9, 0.9)),

                    const SizedBox(height: 48),

                    // Timer picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTimerPicker('Hours', _hours, (val) {
                          setState(() => _hours = val);
                        }),
                        const SizedBox(width: 16),
                        _buildTimerPicker('Minutes', _minutes, (val) {
                          setState(() => _minutes = val);
                        }),
                        const SizedBox(width: 16),
                        _buildTimerPicker('Seconds', _seconds, (val) {
                          setState(() => _seconds = val);
                        }),
                      ],
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                    const Spacer(),

                    // Truth button
                    GlowingButton(
                      text: 'TRUTH',
                      onPressed: _selectTruth,
                      isCyan: true,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                    const SizedBox(height: 16),

                    // Dare button
                    GlowingButton(
                      text: 'DARE',
                      onPressed: _selectDare,
                      isCyan: false,
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

  Widget _buildTimerPicker(String label, int value, Function(int) onChanged) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight.withOpacity(0.5),
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
            border: Border.all(
              color: AppTheme.cyan.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  final maxVal = label == 'Hours' ? 23 : 59;
                  if (value < maxVal) onChanged(value + 1);
                },
                child: Icon(
                  Icons.keyboard_arrow_up,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              Text(
                value.toString().padLeft(2, '0'),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (value > 0) onChanged(value - 1);
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
