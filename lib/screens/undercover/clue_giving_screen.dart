import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'voting_screen.dart';

class ClueGivingScreen extends StatefulWidget {
  const ClueGivingScreen({super.key});

  @override
  State<ClueGivingScreen> createState() => _ClueGivingScreenState();
}

class _ClueGivingScreenState extends State<ClueGivingScreen> {
  final TextEditingController _clueController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _clueController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submitClue() {
    final provider = context.read<UndercoverProvider>();
    final currentPlayer = provider.currentPlayer;
    if (currentPlayer != null && _clueController.text.trim().isNotEmpty) {
      provider.submitClue(currentPlayer.id, _clueController.text.trim());
      _clueController.clear();
      
      if (provider.allCluesSubmitted()) {
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
      } else {
        provider.nextPlayer();
        _focusNode.requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        final currentPlayer = provider.currentPlayer;
        if (currentPlayer == null) return const SizedBox.shrink();

        final allCluesSubmitted = provider.allCluesSubmitted();
        final hasSubmittedClue = provider.clues.containsKey(currentPlayer.id);
        final isTieBreak = provider.isTieBreak;
        
        // In tiebreak, only show tied players
        final activePlayers = isTieBreak && provider.tiedPlayers.isNotEmpty
            ? provider.allPlayers.where((p) => provider.tiedPlayers.contains(p.id) && p.isAlive).toList()
            : provider.players;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.chevron_left, size: 32),
                          color: AppTheme.textSecondary,
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
                              Text(
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

                    const SizedBox(height: 32),

                    // Current player
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: AppTheme.magentaGradient,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                        boxShadow: AppTheme.magentaGlow,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.background.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Icon(
                              currentPlayer.icon,
                              color: AppTheme.background,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            currentPlayer.name,
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Give a clue about your word',
                            style: TextStyle(
                              color: AppTheme.background.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn().scale(),

                    const SizedBox(height: 32),

                    // Clue input
                    if (!hasSubmittedClue)
                      Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceLight.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                              border: Border.all(
                                color: AppTheme.magenta.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: _clueController,
                              focusNode: _focusNode,
                              style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18),
                              decoration: const InputDecoration(
                                hintText: 'Type your clue...',
                                hintStyle: TextStyle(color: AppTheme.textMuted),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              onSubmitted: (_) => _submitClue(),
                              maxLength: 50,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlowingButton(
                            text: 'SUBMIT CLUE',
                            onPressed: _submitClue,
                            gradient: AppTheme.magentaGradient,
                          ),
                        ],
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          border: Border.all(
                            color: AppTheme.cyan.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.check_circle,
                              color: AppTheme.cyan,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Clue Submitted!',
                              style: TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              provider.clues[currentPlayer.id] ?? '',
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),

                    const Spacer(),

                    // All clues submitted
                    if (allCluesSubmitted)
                      Column(
                        children: [
                          const Text(
                            'All clues submitted!',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlowingButton(
                            text: 'VIEW CLUES & VOTE',
                            onPressed: () {
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
                            },
                            gradient: AppTheme.magentaGradient,
                          ),
                        ],
                      ).animate().fadeIn().slideY(begin: 0.2),
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

