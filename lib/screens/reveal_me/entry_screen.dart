import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../providers/reveal_me_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glowing_button.dart';
import '../../widgets/ticket_shape.dart';
import 'host_setup_screen.dart';
import 'join_screen.dart';

class RevealMeEntryScreen extends StatefulWidget {
  const RevealMeEntryScreen({super.key});

  @override
  State<RevealMeEntryScreen> createState() => _RevealMeEntryScreenState();
}

class _RevealMeEntryScreenState extends State<RevealMeEntryScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<RevealMeProvider>();
      await provider.restoreSession();
      if (provider.playerName != null) {
        _nameController.text = provider.playerName!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a name so people know it was you.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await context.read<RevealMeProvider>().joinAsGuest(name);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _submitting = false);
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
            child: Consumer<RevealMeProvider>(
              builder: (context, provider, _) {
                if (provider.playerName != null && !_submitting) {
                  return _ChooseModeView(name: provider.playerName!);
                }
                return _buildNameEntry();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameEntry() {
    return Column(
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
        Icon(Icons.theater_comedy_rounded, color: AppTheme.magenta, size: 56)
            .animate()
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8)),
        const SizedBox(height: 24),
        Text(
          'REVEAL ME',
          textAlign: TextAlign.center,
          style: AppTheme.display(fontSize: 34, weight: FontWeight.w800),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 10),
        Text(
          "Same question. Anonymous answers.\nFunniest one wins.",
          textAlign: TextAlign.center,
          style: AppTheme.body(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 40),
        TextField(
          controller: _nameController,
          textCapitalization: TextCapitalization.words,
          textAlign: TextAlign.center,
          style: AppTheme.display(fontSize: 20, weight: FontWeight.w700),
          decoration: InputDecoration(
            hintText: 'Your name',
            hintStyle: AppTheme.body(fontSize: 18, color: AppTheme.textMuted),
          ),
          onSubmitted: (_) => _continue(),
        ).animate().fadeIn(delay: 200.ms),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, textAlign: TextAlign.center, style: AppTheme.body(fontSize: 13, color: AppTheme.pink)),
        ],
        const SizedBox(height: 28),
        Opacity(
          opacity: _submitting ? 0.6 : 1,
          child: GlowingButton(
            text: _submitting ? 'ONE SEC...' : 'CONTINUE',
            onPressed: _submitting ? null : _continue,
            gradient: AppTheme.magentaGradient,
            glowColor: AppTheme.magenta,
          ),
        ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
        const Spacer(),
      ],
    );
  }
}

class _ChooseModeView extends StatelessWidget {
  final String name;
  const _ChooseModeView({required this.name});

  @override
  Widget build(BuildContext context) {
    return Column(
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
        Text(
          "Hey $name",
          textAlign: TextAlign.center,
          style: AppTheme.display(fontSize: 28, weight: FontWeight.w700),
        ).animate().fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Host a room or hop into one',
          textAlign: TextAlign.center,
          style: AppTheme.body(fontSize: 14, color: AppTheme.textSecondary),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 40),
        TicketCard(
          stubColor: AppTheme.magenta,
          stubGradient: AppTheme.magentaGradient,
          glow: AppTheme.magentaGlow,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RevealMeHostSetupScreen()),
          ),
          stub: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 32),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('HOST A GAME', style: AppTheme.display(fontSize: 16, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Pick a deck, get a room code', style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.08),
        const SizedBox(height: 18),
        TicketCard(
          stubColor: AppTheme.cyan,
          stubGradient: AppTheme.cyanGradient,
          glow: AppTheme.cyanGlow,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RevealMeJoinScreen()),
          ),
          stub: const Icon(Icons.keyboard_rounded, color: Colors.white, size: 32),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('JOIN A GAME', style: AppTheme.display(fontSize: 16, weight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Enter the room code', style: AppTheme.body(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.08),
        const Spacer(),
      ],
    );
  }
}
