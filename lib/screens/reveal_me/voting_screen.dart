import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'round_results_screen.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? _selectedAnswerId;
  bool _isSubmitting = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RevealMeProvider>();
      await provider.refreshGameState();
      setState(() {
        _selectedAnswerId = provider.selectedAnswerId;
      });
      
      // Poll for phase changes (when all players voted)
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        final currentProvider = context.read<RevealMeProvider>();
        await currentProvider.refreshGameState();
        
        if (mounted && currentProvider.phase == RevealMePhase.roundResults) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RoundResultsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
      });
    });
  }
  
  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _submitVote() async {
    if (_selectedAnswerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer to vote for'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final provider = context.read<RevealMeProvider>();
    
    try {
      await provider.submitVote(_selectedAnswerId!);
      
      // Poll for results
      Future.delayed(const Duration(seconds: 2), () async {
        await provider.refreshGameState();
        if (mounted && provider.phase == RevealMePhase.roundResults) {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const RoundResultsScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 500),
            ),
          );
        }
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

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final question = provider.currentQuestion;
        final answers = provider.revealAnswers;

        if (question == null || answers.isEmpty) {
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
                        TouchableIconButton(
                          icon: Icons.close,
                          onPressed: () {},
                          color: AppTheme.textSecondary,
                          iconSize: 28,
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Question
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Text(
                        question.question,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Voting Prompt
                    Text(
                      'Vote for the Best Answer',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap an answer to vote',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Answer Cards (Selectable)
                    ...answers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final answer = entry.value;
                      final answerId = answer['id'] as String?;
                      final isSelected = _selectedAnswerId == answerId;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAnswerId = answerId;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? AppTheme.magentaGradient
                                : LinearGradient(
                                    colors: [
                                      AppTheme.cardBackground,
                                      AppTheme.cardBackground,
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.magenta
                                  : AppTheme.magenta.withOpacity(0.3),
                              width: isSelected ? 3 : 2,
                            ),
                            boxShadow: isSelected
                                ? AppTheme.magentaGlow
                                : [],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  answer['answer_text'] ?? '',
                                  style: TextStyle(
                                    color: isSelected
                                        ? AppTheme.background
                                        : AppTheme.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 12),
                                Icon(
                                  Icons.check_circle,
                                  color: AppTheme.background,
                                  size: 28,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                    }).toList(),

                    const SizedBox(height: 32),

                    // Submit Vote Button
                    if (_isSubmitting)
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppTheme.magenta,
                        ),
                      )
                    else
                      GlowingButton(
                        text: _selectedAnswerId != null
                            ? 'SUBMIT VOTE'
                            : 'SELECT AN ANSWER TO VOTE',
                        onPressed: _selectedAnswerId != null ? _submitVote : null,
                        gradient: AppTheme.magentaGradient,
                      ).animate().fadeIn().slideY(begin: 0.2),
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


