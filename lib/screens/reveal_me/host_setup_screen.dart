import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'game_screen.dart';

const List<Map<String, dynamic>> kRevealMeDecks = [
  {'name': 'Classic', 'icon': Icons.style_rounded},
  {'name': 'Adults', 'icon': Icons.local_bar_rounded},
  {'name': 'College', 'icon': Icons.school_rounded},
  {'name': 'Dark Humor', 'icon': Icons.dark_mode_rounded},
  {'name': 'Relationships', 'icon': Icons.favorite_rounded},
  {'name': 'Roast', 'icon': Icons.whatshot_rounded},
  {'name': 'Indian', 'icon': Icons.celebration_rounded},
  {'name': 'Office', 'icon': Icons.work_rounded},
  {'name': 'Movies', 'icon': Icons.movie_rounded},
];

class RevealMeHostSetupScreen extends StatefulWidget {
  const RevealMeHostSetupScreen({super.key});

  @override
  State<RevealMeHostSetupScreen> createState() => _RevealMeHostSetupScreenState();
}

class _RevealMeHostSetupScreenState extends State<RevealMeHostSetupScreen> {
  final Set<String> _selected = {};
  int _rounds = 6;
  int _timerSeconds = 30;
  bool _creating = false;
  String? _error;

  Future<void> _create() async {
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      await context.read<RevealMeProvider>().createGame(
            categories: _selected.toList(),
            questionsPerPlayer: _rounds,
            timerSeconds: _timerSeconds,
          );
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RevealMeGameScreen()));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                    ),
                    Expanded(
                      child: Text(
                        'HOST A GAME',
                        textAlign: TextAlign.center,
                        style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary, weight: FontWeight.w700, letterSpacing: 2.5),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pick your decks', style: AppTheme.display(fontSize: 22, weight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          'Leave all unpicked for a mix of everything',
                          style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary),
                        ),
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: kRevealMeDecks.map((deck) {
                            final name = deck['name'] as String;
                            final selected = _selected.contains(name);
                            return _DeckChip(
                              label: name,
                              icon: deck['icon'] as IconData,
                              selected: selected,
                              onTap: () => setState(() {
                                if (selected) {
                                  _selected.remove(name);
                                } else {
                                  _selected.add(name);
                                }
                              }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                        _StepperRow(
                          label: 'Rounds',
                          value: _rounds,
                          min: 3,
                          max: 15,
                          onChanged: (v) => setState(() => _rounds = v),
                        ),
                        const SizedBox(height: 16),
                        _StepperRow(
                          label: 'Seconds to write',
                          value: _timerSeconds,
                          min: 15,
                          max: 90,
                          step: 5,
                          onChanged: (v) => setState(() => _timerSeconds = v),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, textAlign: TextAlign.center, style: AppTheme.body(fontSize: 13, color: AppTheme.pink)),
                  ),
                ],
                Opacity(
                  opacity: _creating ? 0.6 : 1,
                  child: GlowingButton(
                    text: _creating ? 'CREATING ROOM...' : 'CREATE ROOM',
                    onPressed: _creating ? null : _create,
                    gradient: AppTheme.magentaGradient,
                    glowColor: AppTheme.magenta,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeckChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _DeckChip({required this.label, required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.magenta.withOpacity(0.18) : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: selected ? AppTheme.magenta : AppTheme.surfaceLight, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? AppTheme.magenta : AppTheme.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTheme.body(
                fontSize: 13,
                weight: FontWeight.w700,
                color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final int step;
  final ValueChanged<int> onChanged;

  const _StepperRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTheme.body(fontSize: 15, weight: FontWeight.w600))),
          IconButton(
            onPressed: value - step >= min ? () => onChanged(value - step) : null,
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.textSecondary),
          ),
          SizedBox(
            width: 32,
            child: Text('$value', textAlign: TextAlign.center, style: AppTheme.mono(fontSize: 16)),
          ),
          IconButton(
            onPressed: value + step <= max ? () => onChanged(value + step) : null,
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
