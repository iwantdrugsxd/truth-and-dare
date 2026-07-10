import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/reveal_me_provider.dart';
import '../../../theme/app_theme.dart';

/// A brief, deliberate beat between "everyone's answered" and "vote now" —
/// the moment where names get stripped off the answers.
class RevealShuffleView extends StatefulWidget {
  const RevealShuffleView({super.key});

  @override
  State<RevealShuffleView> createState() => _RevealShuffleViewState();
}

class _RevealShuffleViewState extends State<RevealShuffleView> {
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _advanceTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) context.read<RevealMeProvider>().advanceToVoting();
    });
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = context.watch<RevealMeProvider>().revealAnswers.length;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shuffle_rounded, color: AppTheme.magenta, size: 48)
              .animate(onPlay: (c) => c.repeat())
              .rotate(duration: 1200.ms, curve: Curves.easeInOut),
          const SizedBox(height: 24),
          Text(
            'Shuffling the answers...',
            style: AppTheme.display(fontSize: 20, weight: FontWeight.w700),
          ).animate().fadeIn(),
          const SizedBox(height: 8),
          Text(
            count > 0 ? '$count answers, no names attached' : 'Almost there',
            style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary),
          ).animate().fadeIn(delay: 150.ms),
        ],
      ),
    );
  }
}
