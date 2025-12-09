import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'voting_screen.dart';

class RevealScreen extends StatefulWidget {
  const RevealScreen({super.key});

  @override
  State<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends State<RevealScreen> {
  Timer? _pollTimer;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RevealMeProvider>();
      await provider.refreshGameState();
      
      // Auto-advance to voting after 3 seconds (all players see answers)
      Future.delayed(const Duration(seconds: 3), () async {
        if (mounted && provider.phase == RevealMePhase.reveal) {
          // Check if we should move to voting
          await provider.refreshGameState();
          if (mounted && provider.phase == RevealMePhase.voting) {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    const VotingScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
          }
        }
      });
      
      // Poll for phase changes
      _pollTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        final currentProvider = context.read<RevealMeProvider>();
        await currentProvider.refreshGameState();
        
        if (mounted && currentProvider.phase == RevealMePhase.voting) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const VotingScreen(),
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
                        Text(
                          'Round ${provider.currentRound}',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Question
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(
                          color: AppTheme.magenta.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppTheme.magentaGradient,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              question.category.toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.background,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            question.question,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 32),

                    // Title
                    Text(
                      'Revealing answers...',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${answers.length} of ${answers.length} revealed',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Answer Cards Grid (2 columns, Psych! style)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: answers.length,
                      itemBuilder: (context, index) {
                        final answer = answers[index];
                        // Alternate colors for visual variety
                        final colors = [
                          [AppTheme.magenta, AppTheme.magenta.withOpacity(0.8)],
                          [AppTheme.cyan, AppTheme.cyan.withOpacity(0.8)],
                        ];
                        final colorPair = colors[index % 2];
                        
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorPair[0].withOpacity(0.3),
                                colorPair[1].withOpacity(0.2),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            border: Border.all(
                              color: colorPair[0].withOpacity(0.5),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorPair[0].withOpacity(0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              answer['answer_text'] ?? '',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ).animate(delay: (index * 200).ms).fadeIn().scale(begin: const Offset(0.8, 0.8));
                      },
                    ),

                    const SizedBox(height: 32),

                    // Continue Button
                    GlowingButton(
                      text: 'CONTINUE TO VOTING',
                      onPressed: () async {
                        // Advance to voting phase
                        try {
                          await provider.advanceToVoting();
                          await provider.refreshGameState();
                          if (mounted && provider.phase == RevealMePhase.voting) {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (context, animation, secondaryAnimation) =>
                                    const VotingScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                                transitionDuration: const Duration(milliseconds: 500),
                              ),
                            );
                          }
                        } catch (e) {
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
                      },
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


