import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'lobby_screen.dart';

class JoinGameScreen extends StatefulWidget {
  const JoinGameScreen({super.key});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _codeFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  bool _codeEntered = false;

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _codeFocus.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _findGame() {
    if (_codeController.text.trim().length == 6) {
      setState(() {
        _codeEntered = true;
      });
      _nameFocus.requestFocus();
    }
  }

  void _joinGame() {
    if (_codeController.text.trim().length != 6 || _nameController.text.trim().isEmpty) {
      return;
    }

    final provider = context.read<RevealMeProvider>();
    final success = provider.joinGame(
      _codeController.text.trim().toUpperCase(),
      _nameController.text.trim(),
    );

    if (success) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const LobbyScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invalid code or name already taken'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    TouchableIconButton(
                      icon: Icons.chevron_left,
                      onPressed: () => Navigator.pop(context),
                      color: AppTheme.textSecondary,
                      iconSize: 32,
                    ),
                    const Expanded(
                      child: Text(
                        'JOIN GAME',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Join Game',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),

                const SizedBox(height: 32),

                if (!_codeEntered) ...[
                  // Game Code Input
                  Text(
                    'Enter the code from the host\'s screen',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: Border.all(
                        color: AppTheme.magenta.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _codeController,
                      focusNode: _codeFocus,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 4,
                      ),
                      textAlign: TextAlign.center,
                      textCapitalization: TextCapitalization.characters,
                      maxLength: 6,
                      decoration: const InputDecoration(
                        hintText: 'A1B2C3',
                        hintStyle: TextStyle(color: AppTheme.textMuted),
                        border: InputBorder.none,
                        counterText: '',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onSubmitted: (_) => _findGame(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlowingButton(
                    text: 'FIND GAME',
                    onPressed: _codeController.text.trim().length == 6 ? _findGame : null,
                    gradient: AppTheme.magentaGradient,
                  ),
                ] else ...[
                  // Name Input
                  Text(
                    'Almost there! What should we call you?',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                      border: Border.all(
                        color: AppTheme.magenta.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _nameController,
                      focusNode: _nameFocus,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18),
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: TextStyle(color: AppTheme.textMuted),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      onSubmitted: (_) => _joinGame(),
                      autofocus: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  GlowingButton(
                    text: 'LET\'S GO!',
                    onPressed: _nameController.text.trim().isNotEmpty ? _joinGame : null,
                    gradient: AppTheme.magentaGradient,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

