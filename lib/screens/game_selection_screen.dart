import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../widgets/ticket_shape.dart';
import 'player_setup_screen.dart';
import 'undercover/undercover_setup_screen.dart';
import 'reveal_me/entry_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const _Bokeh(color: AppTheme.magenta, top: -60, right: -50, size: 220),
            const _Bokeh(color: AppTheme.amber, top: 140, left: -70, size: 180),
            const _Bokeh(color: AppTheme.cyan, bottom: -40, right: -60, size: 200),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    Text(
                      'TONIGHT\'S LINEUP',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        weight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ).animate().fadeIn(duration: 500.ms),

                    const SizedBox(height: 12),

                    Text(
                      'PARTIZO',
                      textAlign: TextAlign.center,
                      style: AppTheme.display(
                        fontSize: 46,
                        weight: FontWeight.w800,
                      ),
                    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.15, curve: Curves.easeOutCubic),

                    const SizedBox(height: 10),

                    Text(
                      'Pass the phone. Pick a game.\nSomeone\'s getting caught tonight.',
                      textAlign: TextAlign.center,
                      style: AppTheme.body(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                        weight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ).animate().fadeIn(delay: 150.ms, duration: 600.ms),

                    const SizedBox(height: 40),

                    _GameTicket(
                      title: 'TRUTH & DARE',
                      description: 'Spin, confess, or take the dare',
                      icon: Icons.local_fire_department_rounded,
                      stubColor: AppTheme.magenta,
                      stubGradient: AppTheme.magentaGradient,
                      glow: AppTheme.magentaGlow,
                      tag: 'CLASSIC',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PlayerSetupScreen()),
                        );
                      },
                    ).animate().fadeIn(delay: 250.ms, duration: 500.ms).slideX(begin: -0.08),

                    const SizedBox(height: 18),

                    _GameTicket(
                      title: 'UNDERCOVER',
                      description: 'Everyone gets a word. One of you is lying',
                      icon: Icons.badge_rounded,
                      stubColor: AppTheme.purple,
                      stubGradient: const LinearGradient(
                        colors: [Color(0xFF7A52E8), AppTheme.purple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      glow: AppTheme.magentaGlow,
                      tag: '3-12 PLAYERS',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const UndercoverSetupScreen()),
                        );
                      },
                    ).animate().fadeIn(delay: 350.ms, duration: 500.ms).slideX(begin: -0.08),

                    const SizedBox(height: 18),

                    _GameTicket(
                      title: 'REVEAL ME',
                      description: 'Same question, anonymous answers, funniest wins',
                      icon: Icons.theater_comedy_rounded,
                      stubColor: AppTheme.cyan,
                      stubGradient: AppTheme.cyanGradient,
                      glow: AppTheme.cyanGlow,
                      tag: 'ONLINE ROOMS',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RevealMeEntryScreen()),
                        );
                      },
                    ).animate().fadeIn(delay: 450.ms, duration: 500.ms).slideX(begin: -0.08),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GameTicket extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color stubColor;
  final Gradient? stubGradient;
  final List<BoxShadow>? glow;
  final String tag;
  final bool muted;
  final VoidCallback onTap;

  const _GameTicket({
    required this.title,
    required this.description,
    required this.icon,
    required this.stubColor,
    required this.stubGradient,
    required this.glow,
    required this.tag,
    required this.onTap,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: muted ? 0.72 : 1,
      child: TicketCard(
        onTap: onTap,
        stubColor: stubColor,
        stubGradient: stubGradient,
        glow: glow,
        stub: Icon(icon, color: muted ? AppTheme.textMuted : Colors.white, size: 34),
        body: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: AppTheme.display(
                      fontSize: 17,
                      weight: FontWeight.w700,
                      color: muted ? AppTheme.textSecondary : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    tag,
                    style: AppTheme.mono(
                      fontSize: 10,
                      color: muted ? AppTheme.textMuted : stubColor,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: muted ? AppTheme.textMuted : AppTheme.textSecondary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _Bokeh extends StatelessWidget {
  final Color color;
  final double size;
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _Bokeh({
    required this.color,
    required this.size,
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.28), color.withOpacity(0.0)],
            ),
          ),
        ),
      ),
    );
  }
}
