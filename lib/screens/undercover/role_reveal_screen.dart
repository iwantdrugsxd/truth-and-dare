import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../models/undercover_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'game_start_screen.dart';

class RoleRevealScreen extends StatefulWidget {
  const RoleRevealScreen({super.key});

  @override
  State<RoleRevealScreen> createState() => _RoleRevealScreenState();
}

class _RoleRevealScreenState extends State<RoleRevealScreen>
    with SingleTickerProviderStateMixin {
  int _currentRevealIndex = 0;
  bool _roleRevealed = false;
  late AnimationController _flipController;
  bool _isFlipped = false;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  void _getRole() {
    if (_isFlipped) return; // Prevent multiple taps
    
    final provider = context.read<UndercoverProvider>();
    final player = provider.allPlayers[_currentRevealIndex];
    
    // Start flip animation
    _flipController.forward().then((_) {
      provider.markRoleRevealed(player.id);
      setState(() {
        _roleRevealed = true;
        _isFlipped = true;
      });
    });
  }

  void _nextPlayer() {
    final provider = context.read<UndercoverProvider>();
    if (_currentRevealIndex < provider.allPlayers.length - 1) {
      setState(() {
        _currentRevealIndex++;
        _roleRevealed = false;
        _isFlipped = false;
        _flipController.reset();
      });
    } else {
      // All players revealed, go to game start screen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const GameStartScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        if (_currentRevealIndex >= provider.allPlayers.length) {
          return const SizedBox.shrink();
        }

        final player = provider.allPlayers[_currentRevealIndex];

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // Header
                    Row(
                      children: [
                        TouchableIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textSecondary,
                          iconSize: 32,
                        ),
                        const Expanded(
                          child: Text(
                            'ROLE REVEAL',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),

                    const Spacer(),

                    if (!_roleRevealed) ...[
                      // Instruction
                      Text(
                        'Pass the Phone',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(begin: -0.2),

                      const SizedBox(height: 16),

                      Text(
                        'Tap your name to get your role',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 64),

                      // Flippable card
                      GestureDetector(
                        onTap: _getRole,
                        child: AnimatedBuilder(
                          animation: _flipController,
                          builder: (context, child) {
                            final angle = _flipController.value * 3.14159;
                            final isHalfFlipped = _flipController.value >= 0.5;
                            
                            return Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()
                                ..setEntry(3, 2, 0.001)
                                ..rotateY(angle),
                              child: isHalfFlipped
                                  ? _buildRoleCard(player)
                                  : _buildPlayerCard(player),
                            );
                          },
                        ),
                      ).animate().fadeIn(delay: 300.ms).scale(),
                    ] else ...[
                      // Role revealed
                      Text(
                        'Your Role',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn().slideY(begin: -0.2),

                      const SizedBox(height: 48),

                      // Role card
                      _buildRoleCard(player).animate().fadeIn(delay: 200.ms).scale(),

                      const SizedBox(height: 48),

                      // Next button
                      GlowingButton(
                        text: 'NEXT',
                        onPressed: _nextPlayer,
                        gradient: AppTheme.magentaGradient,
                        glowColor: AppTheme.magenta,
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                    ],

                    const Spacer(),

                    // Progress indicator
                    Text(
                      '${_currentRevealIndex + 1} / ${provider.allPlayers.length}',
                      style: TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerCard(UndercoverPlayer player) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppTheme.magentaGradient,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        boxShadow: AppTheme.magentaGlow,
      ),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.3),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              player.icon,
              color: AppTheme.background,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            player.name,
            style: const TextStyle(
              color: AppTheme.background,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppTheme.background.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              border: Border.all(
                color: AppTheme.background,
                width: 2,
              ),
            ),
            child: const Text(
              'GET ROLE',
              style: TextStyle(
                color: AppTheme.background,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: 3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard(UndercoverPlayer player) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: _getRoleColor(player.role).withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
        border: Border.all(
          color: _getRoleColor(player.role),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: _getRoleColor(player.role).withOpacity(0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _getRoleColor(player.role),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              player.roleName.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.background,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
              ),
            ),
          ),
          if (player.word != null) ...[
            const SizedBox(height: 32),
            Text(
              'Your Word',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
              ),
              child: Text(
                player.word!,
                style: TextStyle(
                  color: _getRoleColor(player.role),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: 32),
            Text(
              'You have no word!',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Guess the civilian word if eliminated',
              style: TextStyle(
                color: AppTheme.textMuted,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Color _getRoleColor(UndercoverRole role) {
    switch (role) {
      case UndercoverRole.civilian:
        return AppTheme.cyan;
      case UndercoverRole.undercover:
        return Colors.red;
      case UndercoverRole.mrWhite:
        return Colors.orange;
    }
  }
}
