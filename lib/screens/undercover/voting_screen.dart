import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/undercover_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'elimination_screen.dart';

class VotingScreen extends StatefulWidget {
  const VotingScreen({super.key});

  @override
  State<VotingScreen> createState() => _VotingScreenState();
}

class _VotingScreenState extends State<VotingScreen> {
  String? _selectedPlayerId;

  void _submitVote() {
    final provider = context.read<UndercoverProvider>();
    final currentPlayer = provider.currentPlayer;
    if (currentPlayer != null && _selectedPlayerId != null && _selectedPlayerId != currentPlayer.id) {
      provider.submitVote(currentPlayer.id, _selectedPlayerId!);
      _selectedPlayerId = null;
      
      if (provider.allVotesSubmitted()) {
        provider.processElimination();
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const EliminationScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      } else {
        provider.nextPlayer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UndercoverProvider>(
      builder: (context, provider, _) {
        final currentPlayer = provider.currentPlayer;
        if (currentPlayer == null) return const SizedBox.shrink();

        final allVotesSubmitted = provider.allVotesSubmitted();
        final hasVoted = provider.votes.containsKey(currentPlayer.id);
        final isTieBreak = provider.isTieBreak;
        
        // In tiebreak, only show tied players
        final votingTargets = isTieBreak && provider.tiedPlayers.isNotEmpty
            ? provider.allPlayers.where((p) => provider.tiedPlayers.contains(p.id) && p.isAlive).toList()
            : provider.players.where((p) => p.id != currentPlayer.id).toList();

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
                        TouchableIconButton(
                          icon: Icons.chevron_left,
                          onPressed: () => Navigator.pop(context),
                          color: AppTheme.textSecondary,
                          iconSize: 32,
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                isTieBreak ? 'TIEBREAK' : 'VOTING ROUND ${provider.currentRound}',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 3,
                                ),
                              ),
                              const Text(
                                'Who is the Undercover?',
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

                    const SizedBox(height: 24),

                    const SizedBox(height: 8),

                    // Show clues
                    if (!isTieBreak)
                      Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.only(bottom: 24),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Clues:',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...provider.players.map((p) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Row(
                                  children: [
                                    Icon(p.icon, color: p.color, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '${p.name}: "${p.clue ?? "No clue"}"',
                                        style: const TextStyle(
                                          color: AppTheme.textPrimary,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ).animate().fadeIn(),

                    // Current player
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        gradient: AppTheme.magentaGradient,
                        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      ),
                      child: Row(
                        children: [
                          Icon(currentPlayer.icon, color: AppTheme.background, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            currentPlayer.name,
                            style: const TextStyle(
                              color: AppTheme.background,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(),

                    // Player list for voting
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: votingTargets.length,
                        itemBuilder: (context, index) {
                          final player = votingTargets[index];
                          final isSelected = _selectedPlayerId == player.id;
                          final hasVotedForThis = provider.votes[currentPlayer.id] == player.id;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                            onTap: hasVoted ? null : () {
                              setState(() {
                                _selectedPlayerId = player.id;
                              });
                            },
                            borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.magenta.withOpacity(0.2)
                                    : AppTheme.cardBackground,
                                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.magenta
                                      : AppTheme.surfaceLight,
                                  width: isSelected ? 2 : 1,
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
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.name,
                                          style: const TextStyle(
                                            color: AppTheme.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (player.clue != null)
                                          Text(
                                            '"${player.clue}"',
                                            style: const TextStyle(
                                              color: AppTheme.textMuted,
                                              fontSize: 12,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (hasVotedForThis)
                                    Icon(
                                      Icons.check_circle,
                                      color: AppTheme.cyan,
                                      size: 24,
                                    )
                                  else if (isSelected)
                                    Icon(
                                      Icons.radio_button_checked,
                                      color: AppTheme.magenta,
                                      size: 24,
                                    )
                                  else
                                    Icon(
                                      Icons.radio_button_unchecked,
                                      color: AppTheme.textMuted,
                                      size: 24,
                                    ),
                                ],
                              ),
                            ),
                            ),
                          ).animate(delay: (index * 50).ms).fadeIn();
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Submit vote button
                    if (!hasVoted && !allVotesSubmitted)
                      Opacity(
                        opacity: _selectedPlayerId != null && _selectedPlayerId != currentPlayer.id ? 1.0 : 0.5,
                        child: GlowingButton(
                          text: 'CONFIRM VOTE',
                          onPressed: _selectedPlayerId != null && _selectedPlayerId != currentPlayer.id
                              ? _submitVote
                              : () {},
                          gradient: AppTheme.magentaGradient,
                        ),
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else if (hasVoted)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle, color: AppTheme.cyan, size: 24),
                            const SizedBox(width: 8),
                            const Text(
                              'Vote submitted!',
                              style: TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(),

                    if (allVotesSubmitted)
                      GlowingButton(
                        text: 'VIEW RESULTS',
                        onPressed: () {
                          provider.processElimination();
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  const EliminationScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                              transitionDuration: const Duration(milliseconds: 500),
                            ),
                          );
                        },
                        gradient: AppTheme.magentaGradient,
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

