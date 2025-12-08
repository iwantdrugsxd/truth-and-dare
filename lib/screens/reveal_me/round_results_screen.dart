import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'gameplay_screen.dart';
import 'results_screen.dart';

class RoundResultsScreen extends StatefulWidget {
  const RoundResultsScreen({super.key});

  @override
  State<RoundResultsScreen> createState() => _RoundResultsScreenState();
}

class _RoundResultsScreenState extends State<RoundResultsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RevealMeProvider>();
      provider.refreshGameState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final roundResults = provider.roundResults;
        final roundNumber = provider.currentRound;
        final totalRounds = provider.questionsPerPlayer;

        if (roundResults == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final results = List<Map<String, dynamic>>.from((roundResults['results'] as List?) ?? []);
        results.sort((a, b) => (b['votes'] as int).compareTo(a['votes'] as int));

        final winner = results.isNotEmpty ? results[0] : null;

        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        TouchableIconButton(
                          icon: Icons.close,
                          onPressed: () {},
                          color: AppTheme.textSecondary,
                          iconSize: 28,
                        ),
                        const Spacer(),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Round Info
                    Text(
                      'Round $roundNumber Results',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 48),

                    // Winner Card
                    if (winner != null && winner['votes'] > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppTheme.magentaGradient,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusLarge),
                          boxShadow: AppTheme.magentaGlow,
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: AppTheme.background,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Round Winner!',
                              style: const TextStyle(
                                color: AppTheme.background,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              winner['playerName'] ?? 'Unknown',
                              style: const TextStyle(
                                color: AppTheme.background,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '"${winner['answerText']}"',
                              style: TextStyle(
                                color: AppTheme.background.withOpacity(0.9),
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.background.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${winner['votes']} votes • +${winner['points']} points',
                                style: const TextStyle(
                                  color: AppTheme.background,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(height: 32),
                    ],

                    // All Results
                    Text(
                      'All Answers',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),

                    ...results.map((result) {
                      final isWinner = winner != null && result == winner && (winner['votes'] as int) > 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isWinner
                              ? AppTheme.magenta.withOpacity(0.2)
                              : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          border: Border.all(
                            color: isWinner
                                ? AppTheme.magenta
                                : AppTheme.magenta.withOpacity(0.3),
                            width: isWinner ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    result['playerName'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    result['answerText'] ?? '',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 14,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              children: [
                                Text(
                                  '${result['votes']}',
                                  style: TextStyle(
                                    color: AppTheme.magenta,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  'votes',
                                  style: TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn().slideX(begin: 0.1);
                    }).toList(),

                    const SizedBox(height: 48),

                    // Next Round Button
                    if (provider.isHost)
                      GlowingButton(
                        text: roundNumber >= totalRounds
                            ? 'VIEW FINAL LEADERBOARD'
                            : 'NEXT ROUND',
                        onPressed: () async {
                          try {
                            await provider.nextRound();
                            if (mounted) {
                              if (provider.phase == RevealMePhase.results) {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation, secondaryAnimation) =>
                                        const ResultsScreen(),
                                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                    transitionDuration: const Duration(milliseconds: 500),
                                  ),
                                );
                              } else {
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
                        gradient: AppTheme.cyanGradient,
                      ).animate().fadeIn().slideY(begin: 0.2)
                    else
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Text(
                          'Waiting for host to continue...',
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

