import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../providers/reveal_me_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/glowing_button.dart';

class AnsweringView extends StatefulWidget {
  const AnsweringView({super.key});

  @override
  State<AnsweringView> createState() => _AnsweringViewState();
}

class _AnsweringViewState extends State<AnsweringView> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _timer;
  int _remaining = 0;
  bool _autoSubmitted = false;
  static const int maxChars = 80;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _ensureTimer(RevealMeProvider provider) {
    if (_timer != null || provider.currentQuestion == null) return;
    final q = provider.currentQuestion!;
    void tick() {
      final elapsed = DateTime.now().difference(q.roundStartedAt).inSeconds;
      final remaining = (q.timerSeconds - elapsed).clamp(0, q.timerSeconds);
      if (mounted) setState(() => _remaining = remaining);
      if (remaining <= 0 && !_autoSubmitted && !provider.answerSubmitted) {
        _autoSubmitted = true;
        final text = _controller.text.trim().isEmpty ? '...' : _controller.text.trim();
        provider.submitAnswer(text);
      }
    }

    tick();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) => tick());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RevealMeProvider>(
      builder: (context, provider, _) {
        final q = provider.currentQuestion;
        if (q == null) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.magenta));
        }
        _ensureTimer(provider);
        final urgent = _remaining <= 10;

        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ROUND ${q.roundNumber} / ${q.totalRounds}',
                    style: AppTheme.body(fontSize: 12, color: AppTheme.textMuted, weight: FontWeight.w700, letterSpacing: 2),
                  ),
                  Text(
                    '$_remaining s',
                    style: AppTheme.mono(fontSize: 16, color: urgent ? AppTheme.pink : AppTheme.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: q.timerSeconds > 0 ? _remaining / q.timerSeconds : 0,
                  minHeight: 6,
                  backgroundColor: AppTheme.cardBackground,
                  valueColor: AlwaysStoppedAnimation(urgent ? AppTheme.pink : AppTheme.magenta),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                q.text,
                textAlign: TextAlign.center,
                style: AppTheme.display(fontSize: 22, weight: FontWeight.w700, height: 1.35),
              ).animate(key: ValueKey(q.id)).fadeIn(duration: 400.ms).slideY(begin: -0.05),
              const SizedBox(height: 32),
              if (!provider.answerSubmitted) ...[
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBackground,
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(color: AppTheme.magenta.withOpacity(0.3), width: 1.5),
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _controller,
                        focusNode: _focus,
                        autofocus: true,
                        maxLength: maxChars,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: AppTheme.body(fontSize: 17, weight: FontWeight.w600),
                        decoration: InputDecoration(
                          hintText: 'Type the funniest thing you\'ve got...',
                          hintStyle: AppTheme.body(fontSize: 15, color: AppTheme.textMuted),
                          border: InputBorder.none,
                          counterText: '',
                        ),
                        onSubmitted: (v) {
                          if (v.trim().isNotEmpty) provider.submitAnswer(v.trim());
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          '${_controller.text.length}/$maxChars',
                          style: AppTheme.body(fontSize: 11, color: AppTheme.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GlowingButton(
                  text: 'LOCK IT IN',
                  onPressed: _controller.text.trim().isEmpty
                      ? null
                      : () => provider.submitAnswer(_controller.text.trim()),
                  gradient: AppTheme.magentaGradient,
                  glowColor: AppTheme.magenta,
                ),
              ] else
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                    border: Border.all(color: AppTheme.cyan.withOpacity(0.4)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTheme.cyan, size: 28),
                      const SizedBox(height: 10),
                      Text('Locked in', style: AppTheme.body(fontSize: 15, weight: FontWeight.w700, color: AppTheme.cyan)),
                      const SizedBox(height: 4),
                      Text(
                        'Waiting for everyone else...',
                        style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        );
      },
    );
  }
}
