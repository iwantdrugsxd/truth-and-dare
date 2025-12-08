import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glowing_button.dart';
import '../widgets/player_card.dart';
import 'spin_bottle_screen.dart';

class PlayerSetupScreen extends StatefulWidget {
  const PlayerSetupScreen({super.key});

  @override
  State<PlayerSetupScreen> createState() => _PlayerSetupScreenState();
}

class _PlayerSetupScreenState extends State<PlayerSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addPlayer() {
    if (_nameController.text.trim().isNotEmpty) {
      context.read<GameProvider>().addPlayer(_nameController.text);
      _nameController.clear();
      _focusNode.requestFocus();
    }
  }

  void _startGame() {
    final provider = context.read<GameProvider>();
    if (provider.players.length >= 2) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const SpinBottleScreen(),
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.chevron_left, size: 32),
                      color: AppTheme.textSecondary,
                    ),
                    const Expanded(
                      child: Text(
                        'PLAYER SETUP',
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
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 32),

                // Title
                Text(
                  'ASSEMBLE YOUR CREW',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: AppTheme.cyan.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                const SizedBox(height: 8),

                // Player count
                Consumer<GameProvider>(
                  builder: (context, provider, _) {
                    return Text(
                      '${provider.players.length}/8 Players',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 14,
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 24),

                // Input field
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          border: Border.all(
                            color: AppTheme.cyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: TextField(
                          controller: _nameController,
                          focusNode: _focusNode,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          decoration: const InputDecoration(
                            hintText: 'Enter Player Name...',
                            hintStyle: TextStyle(color: AppTheme.textMuted),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onSubmitted: (_) => _addPlayer(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.cyanGradient,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyan.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: _addPlayer,
                        icon: const Icon(
                          Icons.person_add,
                          color: AppTheme.background,
                        ),
                        padding: const EdgeInsets.all(14),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                // Player list
                Expanded(
                  child: Consumer<GameProvider>(
                    builder: (context, provider, _) {
                      if (provider.players.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.group_add,
                                size: 64,
                                color: AppTheme.textMuted.withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Add players to begin',
                                style: TextStyle(
                                  color: AppTheme.textMuted,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: provider.players.length,
                        itemBuilder: (context, index) {
                          final player = provider.players[index];
                          return PlayerCard(
                            player: player,
                            onRemove: () => provider.removePlayer(player.id),
                          ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                        },
                      );
                    },
                  ),
                ),

                // Start button
                Consumer<GameProvider>(
                  builder: (context, provider, _) {
                    final canStart = provider.players.length >= 2;
                    return Column(
                      children: [
                        if (!canStart)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Add at least 2 players to start',
                              style: TextStyle(
                                color: AppTheme.cyan.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          ),
                        Opacity(
                          opacity: canStart ? 1.0 : 0.5,
                          child: GlowingButton(
                            text: 'START GAME',
                            onPressed: canStart ? _startGame : () {},
                          ),
                        ),
                      ],
                    );
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
