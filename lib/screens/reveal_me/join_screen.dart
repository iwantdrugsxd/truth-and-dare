import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import 'game_screen.dart';

class RevealMeJoinScreen extends StatefulWidget {
  const RevealMeJoinScreen({super.key});

  @override
  State<RevealMeJoinScreen> createState() => _RevealMeJoinScreenState();
}

class _RevealMeJoinScreenState extends State<RevealMeJoinScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _joining = false;
  String? _error;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'That code looks too short.');
      return;
    }
    setState(() {
      _joining = true;
      _error = null;
    });
    try {
      await context.read<RevealMeProvider>().joinGame(code);
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const RevealMeGameScreen()));
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _joining = false);
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
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                const Spacer(),
                Text('JOIN A GAME', textAlign: TextAlign.center, style: AppTheme.display(fontSize: 26, weight: FontWeight.w700))
                    .animate()
                    .fadeIn(),
                const SizedBox(height: 8),
                Text(
                  "Ask the host for the room code",
                  textAlign: TextAlign.center,
                  style: AppTheme.body(fontSize: 14, color: AppTheme.textSecondary),
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 40),
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 6,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                    UpperCaseTextFormatter(),
                  ],
                  style: AppTheme.mono(fontSize: 34, letterSpacing: 8),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••••',
                    hintStyle: AppTheme.mono(fontSize: 34, color: AppTheme.textMuted, letterSpacing: 8),
                  ),
                  onSubmitted: (_) => _join(),
                ).animate().fadeIn(delay: 150.ms),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Text(_error!, textAlign: TextAlign.center, style: AppTheme.body(fontSize: 13, color: AppTheme.pink)),
                ],
                const SizedBox(height: 32),
                Opacity(
                  opacity: _joining ? 0.6 : 1,
                  child: GlowingButton(
                    text: _joining ? 'JOINING...' : 'JOIN ROOM',
                    onPressed: _joining ? null : _join,
                    gradient: AppTheme.cyanGradient,
                    glowColor: AppTheme.cyan,
                  ),
                ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.2),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
