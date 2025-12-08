import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'gameplay_screen.dart';
import 'results_screen.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  double _currentRating = 5.0;
  bool _hasRated = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final currentPlayer = provider.currentPlayer;
        final question = provider.currentQuestion;
        final ratingsCount = provider.currentRatings.length;
        final totalRatingsNeeded = provider.players.length - 1;

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
                    Text(
                      question.question,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 48),

                    // Player Being Rated
                    Container(
                      width: 120,
                      height: 120,
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
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentPlayer.name,
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'is being rated...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Rating Prompt
                    Text(
                      'How spicy was that?',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Rating Slider
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                      ),
                      child: Column(
                        children: [
                          // Slider
                          Slider(
                            value: _currentRating,
                            min: 1,
                            max: 10,
                            divisions: 9,
                            activeColor: _getRatingColor(_currentRating),
                            inactiveColor: AppTheme.textMuted.withOpacity(0.3),
                            onChanged: (value) {
                              setState(() {
                                _currentRating = value;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Rating Display
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mild',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.yellow,
                                      Colors.orange,
                                      Colors.pink,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: AppTheme.background,
                                        fontSize: 32,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.local_fire_department,
                                      color: AppTheme.background,
                                      size: 28,
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Spicy',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 32),

                    // Submit Rating Button
                    if (!_hasRated)
                      GlowingButton(
                        text: 'LOCK IN YOUR RATING',
                        onPressed: () async {
                          setState(() {
                            _hasRated = true;
                          });
                          
                          try {
                            await provider.submitRating(_currentRating);
                            
                            // Poll for other players' ratings
                            Timer.periodic(const Duration(seconds: 2), (timer) async {
                              if (!mounted) {
                                timer.cancel();
                                return;
                              }
                              
                              try {
                                await provider.refreshGameState();
                                
                                if (provider.allRatingsSubmitted) {
                                  timer.cancel();
                                  
                                  if (mounted) {
                                    await provider.finishRating();
                                    
                                    if (mounted) {
                                      if (provider.phase == RevealMePhase.results) {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                const ResultsScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(opacity: animation, child: child);
                                            },
                                            transitionDuration: const Duration(milliseconds: 500),
                                          ),
                                        );
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation, secondaryAnimation) =>
                                                const GameplayScreen(),
                                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                              return FadeTransition(opacity: animation, child: child);
                                            },
                                            transitionDuration: const Duration(milliseconds: 500),
                                          ),
                                        );
                                      }
                                    }
                                  }
                                }
                              } catch (e) {
                                print('Error polling ratings: $e');
                              }
                            });
                          } catch (e) {
                            if (mounted) {
                              setState(() {
                                _hasRated = false;
                              });
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
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Waiting for ${totalRatingsNeeded - ratingsCount} more players...',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Player avatars
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ...List.generate(
                                  totalRatingsNeeded - ratingsCount,
                                  (index) => Container(
                                    margin: const EdgeInsets.only(left: 8),
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.cardBackground,
                                      border: Border.all(
                                        color: AppTheme.textMuted,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: AppTheme.textMuted,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Color _getRatingColor(double rating) {
    if (rating <= 3) return Colors.yellow;
    if (rating <= 6) return Colors.orange;
    if (rating <= 8) return Colors.deepOrange;
    return Colors.red;
  }
}

