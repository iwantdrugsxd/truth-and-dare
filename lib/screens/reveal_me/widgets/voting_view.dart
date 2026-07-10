import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/reveal_me_provider.dart';
import '../../../theme/app_theme.dart';

class VotingView extends StatelessWidget {
  const VotingView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RevealMeProvider>();
    final answers = provider.revealAnswers;
    final voted = provider.votedAnswerId != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            voted ? 'Vote locked in' : "Which one's funniest?",
            textAlign: TextAlign.center,
            style: AppTheme.display(fontSize: 22, weight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            voted ? 'Waiting for everyone else to vote...' : "Tap one — you can't vote for your own",
            textAlign: TextAlign.center,
            style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: answers.length,
              itemBuilder: (context, index) {
                final card = answers[index];
                final isMine = provider.myAnswer != null && card.text == provider.myAnswer;
                final isVotedByMe = card.id == provider.votedAnswerId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Opacity(
                    opacity: isMine && !voted ? 0.45 : 1,
                    child: GestureDetector(
                      onTap: (isMine || voted) ? null : () => provider.submitVote(card.id),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isVotedByMe ? AppTheme.magenta.withOpacity(0.18) : AppTheme.cardBackground,
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          border: Border.all(
                            color: isVotedByMe ? AppTheme.magenta : AppTheme.surfaceLight,
                            width: isVotedByMe ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                card.text,
                                style: AppTheme.body(fontSize: 16, weight: FontWeight.w600, height: 1.4),
                              ),
                            ),
                            if (isMine)
                              Padding(
                                padding: const EdgeInsets.only(left: 8),
                                child: Text('YOURS', style: AppTheme.body(fontSize: 10, color: AppTheme.textMuted, weight: FontWeight.w700)),
                              )
                            else if (isVotedByMe)
                              Icon(Icons.check_circle_rounded, color: AppTheme.magenta, size: 22),
                          ],
                        ),
                      ),
                    ),
                  ),
                ).animate(delay: (index * 80).ms).fadeIn().slideY(begin: 0.08);
              },
            ),
          ),
        ],
      ),
    );
  }
}
