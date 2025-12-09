import 'dart:async';
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
import 'reveal_screen.dart';
import 'voting_screen.dart';
import 'round_results_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RevealMeProvider>();
      await provider.refreshGameState();
      
      // Auto-navigate based on phase
      if (mounted) {
        _checkPhaseAndNavigate(provider);
      }
      
      // Set up periodic check for phase changes
      Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!mounted) {
          timer.cancel();
          return;
        }
        
        final currentProvider = context.read<RevealMeProvider>();
        await currentProvider.refreshGameState();
        
        if (mounted) {
          _checkPhaseAndNavigate(currentProvider);
        }
      });
    });
  }
  
  void _checkPhaseAndNavigate(RevealMeProvider provider) {
    if (!mounted) return;
    
    switch (provider.phase) {
      case RevealMePhase.answering:
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
        break;
      case RevealMePhase.reveal:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RevealScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        break;
      case RevealMePhase.voting:
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
        break;
      case RevealMePhase.roundResults:
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const RoundResultsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        // Auto-navigate based on phase (Psych-style)
        if (provider.phase == RevealMePhase.answering || provider.phase == RevealMePhase.gameplay) {
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
        } else if (provider.phase == RevealMePhase.reveal) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RevealScreen()),
              );
            }
          });
        } else if (provider.phase == RevealMePhase.voting) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VotingScreen()),
              );
            }
          });
        } else if (provider.phase == RevealMePhase.roundResults) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const RoundResultsScreen()),
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
        final isHost = provider.isHost; // Use provider's isHost property
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

                    // Game Code Card (Psych! style - matches image)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.magenta.withOpacity(0.2),
                            AppTheme.cyan.withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        border: Border.all(
                          color: AppTheme.magenta.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'GAME CODE',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            gameCode,
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Share code to invite friends!',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: () => _copyCode(context, gameCode),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.magenta.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.share,
                                color: AppTheme.textPrimary,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 48),

                    // Players (Psych! style)
                    Text(
                      'Players (${provider.players.length}/8)',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
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
                            // Player Avatar (Psych! style)
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    RevealMePlayer.availableColors[index % RevealMePlayer.availableColors.length],
                                    RevealMePlayer.availableColors[index % RevealMePlayer.availableColors.length].withOpacity(0.7),
                                  ],
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  player.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
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
                                        style: TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      if (player.isHost) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: Colors.amber,
                                              width: 1,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                                size: 14,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'Host',
                                                style: TextStyle(
                                                  color: Colors.amber,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (!player.isHost && isHost && !isCurrentUser)
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

                    if (provider.players.length < 2)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          'Waiting for more players...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Start Game Button (Psych! style)
                    if (isHost && provider.players.length >= 2)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          gradient: AppTheme.magentaGradient,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          boxShadow: AppTheme.magentaGlow,
                        ),
                        child: TextButton(
                          onPressed: () async {
                            try {
                              // Show loading
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Starting game...'),
                                  backgroundColor: Colors.blue,
                                  behavior: SnackBarBehavior.floating,
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              
                              await provider.startGame();
                              
                              // Refresh state and check phase
                              await provider.refreshGameState();
                              
                              // If phase changed to answering, navigate
                              if (mounted) {
                                if (provider.phase == RevealMePhase.answering) {
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
                                } else {
                                  // Phase didn't change, try again after delay
                                  Future.delayed(const Duration(milliseconds: 1000), () async {
                                    if (mounted) {
                                      await provider.refreshGameState();
                                      if (provider.phase == RevealMePhase.answering) {
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
                                  });
                                }
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error starting game: ${e.toString().replaceAll('Exception: ', '').replaceAll('Network error: ', '')}'),
                                    backgroundColor: Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 5),
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'START GAME',
                            style: TextStyle(
                              color: AppTheme.background,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
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

