import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/reveal_me_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glowing_button.dart';

class LobbyView extends StatelessWidget {
  const LobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RevealMeProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ROOM CODE',
            textAlign: TextAlign.center,
            style: AppTheme.body(fontSize: 12, color: AppTheme.textMuted, weight: FontWeight.w700, letterSpacing: 3),
          ),
          const SizedBox(height: 8),
          Text(
            provider.gameCode ?? '',
            textAlign: TextAlign.center,
            style: AppTheme.mono(fontSize: 44, letterSpacing: 10, color: AppTheme.textPrimary),
          ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9)),
          const SizedBox(height: 6),
          Text(
            'Everyone types this in to join',
            textAlign: TextAlign.center,
            style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 8),
          if (provider.categories.isNotEmpty)
            Text(
              provider.categories.join(' · '),
              textAlign: TextAlign.center,
              style: AppTheme.body(fontSize: 12, color: AppTheme.magenta, weight: FontWeight.w700),
            )
          else
            Text(
              'All decks',
              textAlign: TextAlign.center,
              style: AppTheme.body(fontSize: 12, color: AppTheme.magenta, weight: FontWeight.w700),
            ),
          const SizedBox(height: 32),
          Text(
            '${provider.players.length} in the room',
            style: AppTheme.body(fontSize: 14, color: AppTheme.textSecondary, weight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...provider.players.asMap().entries.map((entry) {
            final p = entry.value;
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                border: p.id == provider.myPlayerId ? Border.all(color: AppTheme.magenta, width: 1.5) : null,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.id == provider.myPlayerId ? '${p.name} (you)' : p.name,
                      style: AppTheme.body(fontSize: 15, weight: FontWeight.w700),
                    ),
                  ),
                  if (p.isHost)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('HOST', style: AppTheme.body(fontSize: 10, color: AppTheme.amber, weight: FontWeight.w800)),
                    ),
                ],
              ),
            ).animate(delay: (entry.key * 60).ms).fadeIn().slideX(begin: 0.05);
          }),
          const SizedBox(height: 24),
          if (provider.isHost)
            Opacity(
              opacity: provider.players.length >= 2 ? 1 : 0.5,
              child: GlowingButton(
                text: provider.players.length >= 2 ? 'START GAME' : 'NEED 2+ PLAYERS',
                onPressed: provider.players.length >= 2 ? provider.startGame : null,
                gradient: AppTheme.magentaGradient,
                glowColor: AppTheme.magenta,
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
                'Waiting for ${provider.hostName ?? 'the host'} to start...',
                textAlign: TextAlign.center,
                style: AppTheme.body(fontSize: 14, color: AppTheme.textSecondary),
              ),
            ),
        ],
      ),
    );
  }
}
