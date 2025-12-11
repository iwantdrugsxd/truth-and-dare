import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'player_setup_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo/Title
                Text(
                  'PARTIZO',
                  style: TextStyle(
                    color: AppTheme.cyan,
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    shadows: [
                      Shadow(
                        color: AppTheme.cyan.withOpacity(0.5),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  'Choose Your Game',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 24,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                ),
                
                const SizedBox(height: 64),
                
                // Truth and Dare Game Card
                _GameCard(
                  title: 'TRUTH & DARE',
                  description: 'Classic party game with spicy questions',
                  icon: Icons.favorite,
                  color: AppTheme.magenta,
                  gradient: AppTheme.magentaGradient,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PlayerSetupScreen(),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Reveal Me Game Card
                _GameCard(
                  title: 'REVEAL ME',
                  description: 'Psych!-style multiplayer guessing game',
                  icon: Icons.visibility,
                  color: AppTheme.cyan,
                  gradient: AppTheme.cyanGradient,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Reveal Me - Coming soon!'),
                        backgroundColor: AppTheme.cyan,
                      ),
                    );
                  },
                ),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Gradient gradient;
  final VoidCallback onTap;

  const _GameCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
