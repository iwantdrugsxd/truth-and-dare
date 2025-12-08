import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/touchable_icon_button.dart';
import 'lobby_screen.dart';

class CreateGameScreen extends StatefulWidget {
  const CreateGameScreen({super.key});

  @override
  State<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends State<CreateGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  int _questionsPerPlayer = 3;
  int _timerSeconds = 30;

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _createGame() async {
    final provider = context.read<RevealMeProvider>();
    
    try {
      await provider.createGame(
        questionsPerPlayer: _questionsPerPlayer,
        timerSeconds: _timerSeconds,
      );
      
      if (mounted) {
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
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
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
                        'CREATE GAME',
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
                  'Create Game',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn().slideX(begin: -0.1),

                const SizedBox(height: 32),

                // Game Settings
                Text(
                  'Game Settings',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                // Questions per player
                _buildSettingRow(
                  icon: Icons.help_outline,
                  label: 'Questions per Player',
                  value: '$_questionsPerPlayer',
                  onDecrement: _questionsPerPlayer > 1
                      ? () => setState(() => _questionsPerPlayer--)
                      : null,
                  onIncrement: _questionsPerPlayer < 10
                      ? () => setState(() => _questionsPerPlayer++)
                      : null,
                ),

                const SizedBox(height: 16),

                // Timer
                _buildSettingRow(
                  icon: Icons.timer,
                  label: 'Time per Answer (seconds)',
                  value: '$_timerSeconds',
                  onDecrement: _timerSeconds > 10
                      ? () => setState(() => _timerSeconds -= 5)
                      : null,
                  onIncrement: _timerSeconds < 120
                      ? () => setState(() => _timerSeconds += 5)
                      : null,
                ),

                const SizedBox(height: 48),

                // Create button
                GlowingButton(
                  text: 'CREATE GAME',
                  onPressed: _createGame,
                  gradient: AppTheme.magentaGradient,
                ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onDecrement,
    VoidCallback? onIncrement,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.magenta, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TouchableIconButton(
            icon: Icons.remove,
            onPressed: onDecrement,
            color: AppTheme.textSecondary,
            size: 40,
            iconSize: 20,
          ),
          const SizedBox(width: 16),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 16),
          TouchableIconButton(
            icon: Icons.add,
            onPressed: onIncrement,
            color: AppTheme.textSecondary,
            size: 40,
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

