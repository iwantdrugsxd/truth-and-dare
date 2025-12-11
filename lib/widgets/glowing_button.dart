import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient gradient;
  final Color glowColor;

  const GlowingButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.gradient,
    required this.glowColor,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = true);
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      setState(() => _isPressed = false);
      _controller.reverse();
      widget.onPressed?.call();
    }
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            gradient: widget.onPressed != null 
                ? widget.gradient 
                : LinearGradient(
                    colors: [
                      widget.glowColor.withOpacity(0.3),
                      widget.glowColor.withOpacity(0.2),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: widget.glowColor.withOpacity(_isPressed ? 0.6 : 0.4),
                      blurRadius: _isPressed ? 30 : 20,
                      spreadRadius: _isPressed ? 4 : 2,
                    ),
                  ]
                : [],
          ),
          child: Text(
            widget.text,
            style: AppTheme.labelLarge.copyWith(
              fontSize: 18,
              color: widget.onPressed != null 
                  ? AppTheme.darkBackground 
                  : AppTheme.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

