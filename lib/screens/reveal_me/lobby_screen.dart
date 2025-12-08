import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../models/reveal_me_player.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'gameplay_screen.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-refresh when screen is visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RevealMeProvider>();
      provider.refreshGameState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        // Auto-navigate to gameplay if game has started
        if (provider.phase == RevealMePhase.gameplay) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
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
          });
        }
        
        return _LobbyScreenContent();
      },
    );
  }
}

class _LobbyScreenContent extends StatefulWidget {
  @override
  State<_LobbyScreenContent> createState() => _LobbyScreenContentState();
}

class _LobbyScreenContentState extends State<_LobbyScreenContent> {

  void _copyCode(BuildContext context, String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Game code copied!'),
        backgroundColor: AppTheme.magenta,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _removePlayer(BuildContext context, RevealMeProvider provider, String playerId, String playerName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBackground,
        title: Text(
          'Remove Player',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $playerName from the game?',
          style: TextStyle(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await provider.removePlayer(playerId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$playerName removed from game'),
              backgroundColor: AppTheme.magenta,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final isHost = provider.players.any((p) => p.isHost);
        final gameCode = provider.gameCode ?? '';

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
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
                            'GAME LOBBY',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 3,
                            ),
                          ),
                        ),
                        if (isHost)
                          TouchableIconButton(
                            icon: Icons.more_vert,
                            onPressed: () {},
                            color: AppTheme.textSecondary,
                            iconSize: 32,
                          )
                        else
                          const SizedBox(width: 48),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Game Code
                    Center(
                      child: Column(
                        children: [
                          Text(
                            gameCode,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 8,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Share this code to invite friends!',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _copyCode(context, gameCode),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.cyanGradient,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                boxShadow: AppTheme.cyanGlow,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.copy,
                                    color: AppTheme.background,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Tap to Copy',
                                    style: TextStyle(
                                      color: AppTheme.background,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 48),

                    // Players
                    Text(
                      'Players: ${provider.players.length}/12',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Player List
                    ...provider.players.asMap().entries.map((entry) {
                      final index = entry.key;
                      final player = entry.value;
                      final isCurrentUser = player.id == provider.playerId;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          border: Border.all(
                            color: player.isHost
                                ? AppTheme.cyan.withOpacity(0.5)
                                : RevealMePlayer.availableColors[index % RevealMePlayer.availableColors.length].withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: RevealMePlayer.availableColors[index % RevealMePlayer.availableColors.length].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                RevealMePlayer.availableIcons[index % RevealMePlayer.availableIcons.length],
                                color: RevealMePlayer.availableColors[index % RevealMePlayer.availableColors.length],
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        player.name,
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (isCurrentUser) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppTheme.magenta.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'You',
                                            style: TextStyle(
                                              color: AppTheme.magenta,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (player.isHost)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.cyan.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(
                                    color: AppTheme.cyan,
                                    width: 1,
                                  ),
                                ),
                                child: const Text(
                                  'Host',
                                  style: TextStyle(
                                    color: AppTheme.cyan,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            else if (isHost && !isCurrentUser)
                              TouchableIconButton(
                                icon: Icons.close,
                                onPressed: () => _removePlayer(context, provider, player.id, player.name),
                                color: Colors.red,
                                size: 36,
                                iconSize: 20,
                              ),
                          ],
                        ),
                      ).animate(delay: (index * 100).ms).fadeIn().slideX(begin: 0.1);
                    }).toList(),

                    const SizedBox(height: 32),

                    // Start Game Button (Host only)
                    if (isHost && provider.players.length >= 2)
                      GlowingButton(
                        text: 'START GAME',
                        onPressed: () async {
                          try {
                            await provider.startGame();
                            // Poll for phase change to answering
                            Future.delayed(const Duration(milliseconds: 500), () async {
                              await provider.refreshGameState();
                              if (mounted && provider.phase == RevealMePhase.answering) {
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
                            });
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
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2)
                    else if (isHost)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Text(
                          'Waiting for more players...\nNeed at least 2 players to start',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Text(
                          'Waiting for host to start the game...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
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
}

