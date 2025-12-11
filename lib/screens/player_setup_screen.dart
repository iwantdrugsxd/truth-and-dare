import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/game_provider.dart';
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
    
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.players.length >= 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Maximum 8 players allowed', style: TextStyle(color: AppTheme.textPrimary)),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    gameProvider.addPlayer(name);
    _nameController.clear();
    _focusNode.requestFocus();
  }

  void _startGame() {
    final gameProvider = context.read<GameProvider>();
    if (gameProvider.players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least 2 players to start', style: TextStyle(color: AppTheme.textPrimary)),
          backgroundColor: Colors.orange,
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
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
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
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                
                const SizedBox(height: 8),
                
                // Player count
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    return Text(
                      '${gameProvider.players.length}/8 Players',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                      ),
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
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter Player Name...',
                          hintStyle: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                        textCapitalization: TextCapitalization.words,
                        onSubmitted: (_) => _addPlayer(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.cyanGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.cyanGlow,
                      ),
                      child: IconButton(
                        onPressed: _addPlayer,
                        icon: const Icon(Icons.person_add, color: AppTheme.background),
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 24),
                
                // Player list
                Expanded(
                  child: Consumer<GameProvider>(
                    builder: (context, gameProvider, child) {
                      if (gameProvider.players.isEmpty) {
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
                        itemCount: gameProvider.players.length,
                        itemBuilder: (context, index) {
                          final player = gameProvider.players[index];
                          return PlayerCard(
                            player: player,
                            onRemove: () => gameProvider.removePlayer(player.id),
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
                Consumer<GameProvider>(
                  builder: (context, gameProvider, child) {
                    if (gameProvider.players.length < 2) {
                      return Text(
                        'Add at least 2 players to start',
                        style: const TextStyle(
                          color: AppTheme.cyan,
                          fontSize: 16,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms, color: AppTheme.cyan.withOpacity(0.3));
                    }
                    return const SizedBox.shrink();
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Start button
                GlowingButton(
                  text: 'START GAME',
                  onPressed: _startGame,
                  gradient: AppTheme.cyanGradient,
                  glowColor: AppTheme.cyan,
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

