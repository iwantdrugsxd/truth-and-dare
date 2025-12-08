import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/player_card.dart';
import '../../widgets/touchable_icon_button.dart';
import 'role_reveal_screen.dart';

class UndercoverSetupScreen extends StatefulWidget {
  const UndercoverSetupScreen({super.key});

  @override
  State<UndercoverSetupScreen> createState() => _UndercoverSetupScreenState();
}

class _UndercoverSetupScreenState extends State<UndercoverSetupScreen> {
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
      context.read<UndercoverProvider>().addPlayer(_nameController.text);
      _nameController.clear();
      _focusNode.requestFocus();
    }
  }

  void _startGame() {
    final provider = context.read<UndercoverProvider>();
    if (provider.allPlayers.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Add at least 3 players to start'),
          backgroundColor: AppTheme.magenta,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Check if there's at least one civilian
    if (provider.numUndercover + provider.numMrWhite >= provider.allPlayers.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Need at least one civilian. Reduce undercovers or Mr. White.'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }
    
    try {
      provider.startGame();
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const RoleRevealScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
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
                        TouchableIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textSecondary,
                          iconSize: 32,
                        ),
                    const Expanded(
                      child: Text(
                        'UNDERCOVER SETUP',
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
                  'CREATE GAME',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(
                        color: AppTheme.magenta.withOpacity(0.3),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),

                const SizedBox(height: 24),

                // Game Settings
                Consumer<UndercoverProvider>(
                  builder: (context, provider, _) {
                    return Column(
                      children: [
                        // Number of Players
                        _buildSettingRow(
                          icon: Icons.group,
                          label: 'Number of Players',
                          value: '${provider.allPlayers.length}',
                          onDecrement: provider.allPlayers.length > 3
                              ? () => provider.removePlayer(provider.allPlayers.last.id)
                              : null,
                          onIncrement: provider.allPlayers.length < 12
                              ? () => provider.addPlayer('Player ${provider.allPlayers.length + 1}')
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Number of Undercovers
                        _buildSettingRow(
                          icon: Icons.visibility_off,
                          label: 'Undercover',
                          value: '${provider.numUndercover}',
                          onDecrement: provider.numUndercover > 0
                              ? () => provider.setNumUndercover(provider.numUndercover - 1)
                              : null,
                          onIncrement: provider.numUndercover < 3
                              ? () => provider.setNumUndercover(provider.numUndercover + 1)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Number of Mr. White
                        _buildSettingRow(
                          icon: Icons.help_outline,
                          label: 'Mr. White',
                          value: '${provider.numMrWhite}',
                          onDecrement: provider.numMrWhite > 0
                              ? () => provider.setNumMrWhite(provider.numMrWhite - 1)
                              : null,
                          onIncrement: provider.numMrWhite < 2
                              ? () => provider.setNumMrWhite(provider.numMrWhite + 1)
                              : null,
                        ),
                      ],
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
                            color: AppTheme.magenta.withOpacity(0.3),
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
                        gradient: AppTheme.magentaGradient,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.magenta.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: TouchableIconButton(
                        icon: Icons.person_add,
                        onPressed: _addPlayer,
                        color: AppTheme.background,
                        size: 56,
                        iconSize: 28,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                // Player list
                Expanded(
                  child: Consumer<UndercoverProvider>(
                    builder: (context, provider, _) {
                      if (provider.allPlayers.isEmpty) {
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
                        itemCount: provider.allPlayers.length,
                        itemBuilder: (context, index) {
                          final player = provider.allPlayers[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.cardBackground,
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              border: Border.all(
                                color: player.color.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: player.color.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    player.icon,
                                    color: player.color,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    player.name,
                                    style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                TouchableIconButton(
                                  icon: Icons.delete_outline,
                                  onPressed: () => provider.removePlayer(player.id),
                                  color: AppTheme.textMuted,
                                  tooltip: 'Remove player',
                                ),
                              ],
                            ),
                          ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                        },
                      );
                    },
                  ),
                ),

                // Start button
                Consumer<UndercoverProvider>(
                  builder: (context, provider, _) {
                    final hasEnoughPlayers = provider.allPlayers.length >= 3;
                    final hasCivilians = provider.numUndercover + provider.numMrWhite < provider.allPlayers.length;
                    final canStart = hasEnoughPlayers && hasCivilians;
                    
                    return Column(
                      children: [
                        if (!canStart)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              !hasEnoughPlayers
                                  ? 'Add at least 3 players to start'
                                  : 'Need at least one civilian. Reduce undercovers or Mr. White.',
                              style: TextStyle(
                                color: AppTheme.magenta.withOpacity(0.7),
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        Opacity(
                          opacity: canStart ? 1.0 : 0.5,
                          child: GlowingButton(
                            text: 'START GAME',
                            onPressed: canStart ? _startGame : () {},
                            gradient: AppTheme.magentaGradient,
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

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onDecrement,
    VoidCallback? onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.magenta, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Row(
            children: [
                              TouchableIconButton(
                                icon: Icons.remove,
                                onPressed: onDecrement,
                                color: AppTheme.textSecondary,
                                size: 48,
                                iconSize: 24,
                              ),
              const SizedBox(width: 16),
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 16),
                              TouchableIconButton(
                                icon: Icons.add,
                                onPressed: onIncrement,
                                color: AppTheme.textSecondary,
                                size: 48,
                                iconSize: 24,
                              ),
            ],
          ),
        ],
      ),
    );
  }
}

