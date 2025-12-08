import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'voting_screen.dart';

class ClueGivingScreen extends StatefulWidget {
  const ClueGivingScreen({super.key});

  @override
  State<ClueGivingScreen> createState() => _ClueGivingScreenState();
}

class _ClueGivingScreenState extends State<ClueGivingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _beginVoting(BuildContext context) {
    final provider = context.read<UndercoverProvider>();
    provider.startVoting();
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

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header
                    Row(
                      children: [
                        TouchableIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textSecondary,
                          iconSize: 32,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'ROUND ${provider.currentRound}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                              ),
                              const Text(
                                'Clue Giving',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const Spacer(),

                    // Main content
                    Column(
                      children: [
                        Text(
                          'People are giving clues',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: -0.2),

                        const SizedBox(height: 48),

                        // Animated processing indicator
                        AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.magenta.withOpacity(0.3),
                                    AppTheme.magenta.withOpacity(0.1),
                                  ],
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  ...List.generate(8, (index) {
                                    final angle = (index * 45) * 3.14159 / 180;
                                    final radius = 40.0;
                                    final x = radius * (1 + _animationController.value) * 
                                        (index.isEven ? 1 : 0.7) * 
                                        (index % 2 == 0 ? 1 : -1) * 
                                        (index < 4 ? 1 : -1);
                                    final y = radius * (1 + _animationController.value) * 
                                        (index.isOdd ? 1 : 0.7) * 
                                        (index % 2 == 1 ? 1 : -1) * 
                                        (index < 4 ? 1 : -1);
                                    
                                    return Transform.translate(
                                      offset: Offset(x * 0.3, y * 0.3),
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: AppTheme.magenta,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.magenta.withOpacity(0.8),
                                              blurRadius: 8,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppTheme.magenta.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.chat_bubble_outline,
                                      color: AppTheme.magenta,
                                      size: 32,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ).animate().fadeIn(delay: 300.ms).scale(),

                        const SizedBox(height: 48),

                        Text(
                          'Everyone gives their clue verbally',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 500.ms),
                      ],
                    ),

                    const Spacer(),

                    // Begin voting button
                    GlowingButton(
                      text: 'BEGIN VOTING',
                      onPressed: () => _beginVoting(context),
                      gradient: AppTheme.magentaGradient,
                    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),
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
