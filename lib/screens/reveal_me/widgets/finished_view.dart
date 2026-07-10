import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/reveal_me_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glowing_button.dart';
import '../../game_selection_screen.dart';
import '../entry_screen.dart';

class FinishedView extends StatefulWidget {
  const FinishedView({super.key});

  @override
  State<FinishedView> createState() => _FinishedViewState();
}

class _FinishedViewState extends State<FinishedView> {
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 2));
    WidgetsBinding.instance.addPostFrameCallback((_) => _confetti.play());
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RevealMeProvider>();
    final standings = provider.standings;
    if (standings.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.magenta));
    }

    final winner = standings.first;
    final mostConsistent = ([...standings]..sort((a, b) => b.questionsAnswered.compareTo(a.questionsAnswered))).first;
    final fastest = provider.fastestThinker;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            children: [
              Text(
                'KING OF COMEDY',
                textAlign: TextAlign.center,
                style: AppTheme.body(fontSize: 12, color: AppTheme.amber, weight: FontWeight.w700, letterSpacing: 3),
              ).animate().fadeIn(),
              const SizedBox(height: 12),
              const Text('👑', style: TextStyle(fontSize: 56)).animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.5, 0.5)),
              const SizedBox(height: 12),
              Text(
                winner.name,
                textAlign: TextAlign.center,
                style: AppTheme.display(fontSize: 32, weight: FontWeight.w800),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 4),
              Text(
                '${winner.score.toStringAsFixed(0)} points',
                style: AppTheme.mono(fontSize: 16, color: AppTheme.magenta),
              ).animate().fadeIn(delay: 250.ms),
              const SizedBox(height: 32),
              if (mostConsistent.questionsAnswered > 0)
                _AwardRow(emoji: '🎯', title: 'Most Consistent', name: mostConsistent.name)
                    .animate()
                    .fadeIn(delay: 350.ms)
                    .slideX(begin: -0.05),
              if (fastest != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _AwardRow(emoji: '⚡', title: 'Fastest Thinker', name: fastest),
                ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.05),
              const SizedBox(height: 32),
              Text('FINAL STANDINGS', style: AppTheme.body(fontSize: 12, color: AppTheme.textMuted, weight: FontWeight.w700, letterSpacing: 2)),
              const SizedBox(height: 16),
              ...standings.asMap().entries.map((entry) {
                final index = entry.key;
                final p = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: index == 0 ? AppTheme.amber.withOpacity(0.12) : AppTheme.cardBackground,
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: index == 0 ? Border.all(color: AppTheme.amber.withOpacity(0.5)) : null,
                    ),
                    child: Row(
                      children: [
                        SizedBox(width: 28, child: Text('${index + 1}', style: AppTheme.mono(fontSize: 14, color: AppTheme.textMuted))),
                        Expanded(child: Text(p.name, style: AppTheme.body(fontSize: 15, weight: FontWeight.w700))),
                        Text(p.score.toStringAsFixed(0), style: AppTheme.mono(fontSize: 15, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ).animate(delay: (500 + index * 80).ms).fadeIn();
              }),
              const SizedBox(height: 28),
              GlowingButton(
                text: 'PLAY AGAIN',
                onPressed: () {
                  provider.resetGame();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const RevealMeEntryScreen()),
                    (route) => false,
                  );
                },
                gradient: AppTheme.magentaGradient,
                glowColor: AppTheme.magenta,
              ),
              const SizedBox(height: 12),
              GlowingButton(
                text: 'BACK TO GAMES',
                onPressed: () {
                  provider.resetGame();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
                    (route) => false,
                  );
                },
                glowColor: AppTheme.textMuted,
                isOutlined: true,
              ),
            ],
          ),
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 40,
          maxBlastForce: 26,
          minBlastForce: 10,
          gravity: 0.22,
          colors: const [AppTheme.magenta, AppTheme.cyan, AppTheme.amber, AppTheme.pink],
        ),
      ],
    );
  }
}

class _AwardRow extends StatelessWidget {
  final String emoji;
  final String title;
  final String name;

  const _AwardRow({required this.emoji, required this.title, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTheme.body(fontSize: 11, color: AppTheme.textMuted, weight: FontWeight.w700, letterSpacing: 1)),
                Text(name, style: AppTheme.body(fontSize: 15, weight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
