import 'dart:async';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../models/reveal_me_models.dart';
import '../../../providers/reveal_me_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glowing_button.dart';

class ResultsView extends StatefulWidget {
  const ResultsView({super.key});

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  int _revealedCount = 0;
  bool _showLeaderboard = false;
  Timer? _timer;
  late final ConfettiController _confetti;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _timer = Timer.periodic(const Duration(milliseconds: 1600), (t) {
      final results = context.read<RevealMeProvider>().results;
      if (_revealedCount >= results.length) {
        t.cancel();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) setState(() => _showLeaderboard = true);
        });
        return;
      }
      setState(() => _revealedCount++);
      final justRevealed = results[_revealedCount - 1];
      if (justRevealed.votes > 0 && _revealedCount == results.length) {
        _confetti.play();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RevealMeProvider>();
    final results = provider.results;

    if (results.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.magenta));
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: _showLeaderboard
              ? _Leaderboard(provider: provider)
              : _RevealSequence(results: results.take(_revealedCount).toList()),
        ),
        ConfettiWidget(
          confettiController: _confetti,
          blastDirectionality: BlastDirectionality.explosive,
          numberOfParticles: 24,
          maxBlastForce: 22,
          minBlastForce: 8,
          gravity: 0.25,
          colors: const [AppTheme.magenta, AppTheme.cyan, AppTheme.amber, AppTheme.pink],
        ),
      ],
    );
  }
}

class _RevealSequence extends StatelessWidget {
  final List<RevealMeRoundResult> results;
  const _RevealSequence({required this.results});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Opening the envelope...',
          textAlign: TextAlign.center,
          style: AppTheme.body(fontSize: 12, color: AppTheme.textMuted, weight: FontWeight.w700, letterSpacing: 2),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final r = results[results.length - 1 - index];
              final isLatest = index == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isLatest ? AppTheme.magenta.withOpacity(0.15) : AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(color: isLatest ? AppTheme.magenta : AppTheme.surfaceLight, width: isLatest ? 2 : 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.answerText, style: AppTheme.body(fontSize: 16, weight: FontWeight.w600, height: 1.35)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.how_to_vote_rounded, size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${r.votes} ${r.votes == 1 ? 'vote' : 'votes'} · ${r.playerName}',
                            style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary, weight: FontWeight.w700),
                          ),
                        ],
                      ),
                      if (r.fastBonus || r.perfectBonus || r.comebackBonus) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: [
                            if (r.fastBonus) const _Badge(label: 'FAST +50', color: AppTheme.cyan),
                            if (r.perfectBonus) const _Badge(label: 'PERFECT ROUND +300', color: AppTheme.amber),
                            if (r.comebackBonus) const _Badge(label: 'COMEBACK +150', color: AppTheme.pink),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
            },
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.16), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: AppTheme.body(fontSize: 10, color: color, weight: FontWeight.w800)),
    );
  }
}

class _Leaderboard extends StatelessWidget {
  final RevealMeProvider provider;
  const _Leaderboard({required this.provider});

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final standings = provider.standings;
    final canContinue = provider.isHost;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('STANDINGS', textAlign: TextAlign.center, style: AppTheme.display(fontSize: 22, weight: FontWeight.w700)),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.builder(
            itemCount: standings.length,
            itemBuilder: (context, index) {
              final p = standings[index];
              final isMe = p.id == provider.myPlayerId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: isMe ? Border.all(color: AppTheme.magenta, width: 1.5) : null,
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 32,
                        child: Text(
                          index < 3 ? _medals[index] : '${index + 1}',
                          style: AppTheme.display(fontSize: 16, weight: FontWeight.w700),
                        ),
                      ),
                      Expanded(
                        child: Text(p.name, style: AppTheme.body(fontSize: 15, weight: FontWeight.w700)),
                      ),
                      Text(
                        p.score.toStringAsFixed(0),
                        style: AppTheme.mono(fontSize: 16, color: AppTheme.magenta),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (index * 90).ms).fadeIn().slideX(begin: 0.06);
            },
          ),
        ),
        const SizedBox(height: 12),
        if (canContinue)
          GlowingButton(
            text: 'NEXT ROUND',
            onPressed: provider.nextRound,
            gradient: AppTheme.magentaGradient,
            glowColor: AppTheme.magenta,
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.cardBackground, borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium)),
            child: Text(
              'Waiting for the host to continue...',
              textAlign: TextAlign.center,
              style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ),
      ],
    );
  }
}

