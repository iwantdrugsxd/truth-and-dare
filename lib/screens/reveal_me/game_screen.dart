import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/reveal_me_models.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../game_selection_screen.dart';
import 'widgets/lobby_view.dart';
import 'widgets/answering_view.dart';
import 'widgets/reveal_view.dart';
import 'widgets/voting_view.dart';
import 'widgets/results_view.dart';
import 'widgets/finished_view.dart';

class RevealMeGameScreen extends StatefulWidget {
  const RevealMeGameScreen({super.key});

  @override
  State<RevealMeGameScreen> createState() => _RevealMeGameScreenState();
}

class _RevealMeGameScreenState extends State<RevealMeGameScreen> {
  @override
  void dispose() {
    context.read<RevealMeProvider>().stopPolling();
    super.dispose();
  }

  void _leaveGame() {
    context.read<RevealMeProvider>().resetGame();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const GameSelectionScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _leaveGame();
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
          child: SafeArea(
            child: Consumer<RevealMeProvider>(
              builder: (context, provider, _) {
                return Column(
                  children: [
                    _Header(provider: provider, onLeave: _leaveGame),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        child: _bodyFor(provider),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _bodyFor(RevealMeProvider provider) {
    switch (provider.phase) {
      case RevealMePhase.lobby:
        return const LobbyView(key: ValueKey('lobby'));
      case RevealMePhase.answering:
        return const AnsweringView(key: ValueKey('answering'));
      case RevealMePhase.reveal:
        return const RevealShuffleView(key: ValueKey('reveal'));
      case RevealMePhase.voting:
        return const VotingView(key: ValueKey('voting'));
      case RevealMePhase.results:
        return const ResultsView(key: ValueKey('results'));
      case RevealMePhase.finished:
        return const FinishedView(key: ValueKey('finished'));
      case RevealMePhase.none:
        return const Center(
          key: ValueKey('loading'),
          child: CircularProgressIndicator(color: AppTheme.magenta),
        );
    }
  }
}

class _Header extends StatelessWidget {
  final RevealMeProvider provider;
  final VoidCallback onLeave;

  const _Header({required this.provider, required this.onLeave});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onLeave,
            icon: const Icon(Icons.close, color: AppTheme.textSecondary),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  provider.gameCode ?? '',
                  style: AppTheme.mono(fontSize: 13, color: AppTheme.textMuted, letterSpacing: 3),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
