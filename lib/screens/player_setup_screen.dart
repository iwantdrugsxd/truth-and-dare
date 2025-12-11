import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_state.dart';
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
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    
    final gameState = context.read<GameState>();
    if (gameState.playerCount >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum 8 players allowed', style: AppTheme.bodyMedium),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }
    
    gameState.addPlayer(name);
    _nameController.clear();
    _focusNode.requestFocus();
  }

  void _startGame() {
    final gameState = context.read<GameState>();
    if (gameState.playerCount < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Add at least 2 players to start', style: AppTheme.bodyMedium),
          backgroundColor: AppTheme.warningOrange,
        ),
      );
      return;
    }
    
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Header
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        'PLAYER SETUP',
                        style: AppTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                
                const SizedBox(height: 32),
                
                // Title
                Text(
                  'ASSEMBLE YOUR CREW',
                  style: AppTheme.displayLarge,
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                
                const SizedBox(height: 8),
                
                // Player count
                Consumer<GameState>(
                  builder: (context, gameState, child) {
                    return Text(
                      '${gameState.playerCount}/8 Players',
                      style: AppTheme.bodyMedium,
                    );
                  },
                ).animate().fadeIn(delay: 300.ms),
                
                const SizedBox(height: 24),
                
                // Input field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        focusNode: _focusNode,
                        style: AppTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Enter Player Name...',
                          hintStyle: AppTheme.bodyMedium.copyWith(color: AppTheme.textMuted),
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cyanGlow,
                      ),
                      child: IconButton(
                        onPressed: _addPlayer,
                        icon: const Icon(Icons.person_add, color: AppTheme.darkBackground),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 24),
                
                // Player list
                Expanded(
                  child: Consumer<GameState>(
                    builder: (context, gameState, child) {
                      if (gameState.players.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.group_add,
                                size: 64,
                                color: AppTheme.textMuted.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Add players to begin',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        itemCount: gameState.players.length,
                        itemBuilder: (context, index) {
                          final player = gameState.players[index];
                          return PlayerCard(
                            player: player,
                            onRemove: () => gameState.removePlayer(player.id),
                          ).animate(delay: Duration(milliseconds: 100 * index))
                            .fadeIn()
                            .slideX(begin: 0.1);
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Info text
                Consumer<GameState>(
                  builder: (context, gameState, child) {
                    if (gameState.playerCount < 2) {
                      return Text(
                        'Add at least 2 players to start',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryCyan,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms, color: AppTheme.primaryCyan.withOpacity(0.3));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Start button
                GlowingButton(
                  text: 'START GAME',
                  onPressed: _startGame,
                  gradient: AppTheme.primaryGradient,
                  glowColor: AppTheme.primaryCyan,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

