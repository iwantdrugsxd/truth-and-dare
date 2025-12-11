import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glowing_button.dart';
import 'truth_dare_selection_screen.dart';

class SpinBottleScreen extends StatefulWidget {
  const SpinBottleScreen({super.key});

  @override
  State<SpinBottleScreen> createState() => _SpinBottleScreenState();
}

class _SpinBottleScreenState extends State<SpinBottleScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isSpinning = false;
  double _currentRotation = 0;
  int? _selectedPlayerIndex;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _spinBottle() {
    if (_isSpinning) return;

    final provider = context.read<GameProvider>();
    final playerCount = provider.players.length;
    if (playerCount == 0) return;

    setState(() {
      _isSpinning = true;
      _selectedPlayerIndex = null;
    });

    // Calculate random final rotation
    final random = Random();
    final targetPlayerIndex = random.nextInt(playerCount);
    final anglePerPlayer = (2 * pi) / playerCount;
    final targetAngle = targetPlayerIndex * anglePerPlayer;
    final fullSpins = 3 + random.nextInt(3); // 3-5 full spins
    final finalRotation = (fullSpins * 2 * pi) + targetAngle + (pi / 2);

    _spinAnimation = Tween<double>(
      begin: _currentRotation,
      end: finalRotation,
    ).animate(CurvedAnimation(
      parent: _spinController,
      curve: Curves.easeOutCubic,
    ));

    _spinController.reset();
    _spinController.forward().then((_) {
      setState(() {
        _isSpinning = false;
        _currentRotation = finalRotation;
        _selectedPlayerIndex = targetPlayerIndex;
      });
      
      // Update provider
      provider.spinBottle();
      
      // Navigate after short delay
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TruthDareSelectionScreen(),
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<GameProvider>(
            builder: (context, provider, _) {
              final players = provider.players;
              final currentPlayer = _selectedPlayerIndex != null
                  ? players[_selectedPlayerIndex! % players.length]
                  : null;

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, size: 32),
                          color: AppTheme.textSecondary,
                        ),
                        const Expanded(
                          child: Text(
                            'Truth or Dare',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.settings, size: 24),
                          color: AppTheme.textSecondary,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),

                  // Turn indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      currentPlayer != null
                          ? "${currentPlayer.name}'s Turn!"
                          : 'Spin to Pick!',
                      style: TextStyle(
                        color: currentPlayer?.color ?? AppTheme.cyan,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: (currentPlayer?.color ?? AppTheme.cyan)
                                .withOpacity(0.5),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),

                  const Text(
                    'Swipe the bottle or tap the button below',
                    style: TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Bottle spinner area
                  Expanded(
                    child: Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Player avatars around the circle
                          ...List.generate(players.length, (index) {
                            final angle = (index * 2 * pi / players.length) - (pi / 2);
                            const radius = 140.0;
                            final x = cos(angle) * radius;
                            final y = sin(angle) * radius;
                            final player = players[index];
                            final isSelected = _selectedPlayerIndex == index;

                            return Positioned(
                              left: MediaQuery.of(context).size.width / 2 + x - 25,
                              top: 150 + y - 25,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? player.color
                                      : player.color.withOpacity(0.3),
                                  border: Border.all(
                                    color: isSelected
                                        ? player.color
                                        : player.color.withOpacity(0.5),
                                    width: isSelected ? 3 : 2,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: player.color.withOpacity(0.6),
                                            blurRadius: 20,
                                            spreadRadius: 3,
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Icon(
                                    player.icon,
                                    color: isSelected
                                        ? AppTheme.background
                                        : player.color,
                                    size: 24,
                                  ),
                                ),
                              ),
                            );
                          }),

                          // Center platform - seamless with background
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  AppTheme.surfaceLight.withOpacity(0.4),
                                  AppTheme.background.withOpacity(0.0),
                                ],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                          ),
                          // Circle border only (no square background)
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.cyan.withOpacity(0.25),
                                width: 1.5,
                              ),
                            ),
                          ),

                          // Spinning bottle
                          AnimatedBuilder(
                            animation: _spinController,
                            builder: (context, child) {
                              final rotation = _isSpinning
                                  ? _spinAnimation.value
                                  : _currentRotation;
                              return Transform.rotate(
                                angle: rotation,
                                child: SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: CustomPaint(
                                    painter: BottlePainter(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Spin button
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Opacity(
                      opacity: _isSpinning ? 0.5 : 1.0,
                      child: GlowingButton(
                        text: 'SPIN THE BOTTLE',
                        onPressed: _isSpinning ? () {} : _spinBottle,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.cyan
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final glowPaint = Paint()
      ..color = AppTheme.cyan.withOpacity(0.3)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Bottle body
    path.moveTo(centerX - 8, centerY + 40);
    path.lineTo(centerX - 12, centerY + 10);
    path.lineTo(centerX - 5, centerY - 20);
    path.lineTo(centerX - 3, centerY - 45);
    path.lineTo(centerX + 3, centerY - 45);
    path.lineTo(centerX + 5, centerY - 20);
    path.lineTo(centerX + 12, centerY + 10);
    path.lineTo(centerX + 8, centerY + 40);
    path.close();

    // Draw glow
    canvas.drawPath(path, glowPaint);
    // Draw bottle
    canvas.drawPath(path, paint);

    // Arrow indicator at top
    final arrowPaint = Paint()
      ..color = AppTheme.cyan
      ..style = PaintingStyle.fill;

    final arrowPath = Path();
    arrowPath.moveTo(centerX, centerY - 55);
    arrowPath.lineTo(centerX - 6, centerY - 45);
    arrowPath.lineTo(centerX + 6, centerY - 45);
    arrowPath.close();

    canvas.drawPath(arrowPath, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
