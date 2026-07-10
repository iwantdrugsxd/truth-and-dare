import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'ticket_shape.dart';

/// The primary call-to-action across Partizo: a wide admission-ticket
/// button with punched side notches. Pass [gradient]/[glowColor] directly,
/// or use the [isCyan] shorthand for the two standard accent treatments.
class GlowingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final LinearGradient? gradient;
  final Color? glowColor;
  final bool? isCyan;
  final bool isOutlined;

  const GlowingButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.gradient,
    this.glowColor,
    this.isCyan,
    this.isOutlined = false,
  });

  LinearGradient get _gradient =>
      gradient ?? (isCyan == false ? AppTheme.magentaGradient : AppTheme.cyanGradient);

  Color get _glowColor =>
      glowColor ?? (isCyan == false ? AppTheme.magenta : AppTheme.cyan);

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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
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
    final enabled = widget.onPressed != null;
    final glowColor = widget._glowColor;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: enabled && !widget.isOutlined
                ? [
                    BoxShadow(
                      color: glowColor.withOpacity(_isPressed ? 0.55 : 0.35),
                      blurRadius: _isPressed ? 28 : 20,
                      spreadRadius: _isPressed ? 3 : 1,
                    ),
                  ]
                : null,
          ),
          child: ClipPath(
            clipper: const TicketClipper(radius: 18, notchRadius: 7, notchesOnSides: true),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 19),
              decoration: BoxDecoration(
                gradient: widget.isOutlined
                    ? null
                    : (enabled
                        ? widget._gradient
                        : LinearGradient(
                            colors: [
                              glowColor.withOpacity(0.25),
                              glowColor.withOpacity(0.15),
                            ],
                          )),
                color: widget.isOutlined ? AppTheme.cardBackground : null,
                border: widget.isOutlined
                    ? Border.all(color: glowColor.withOpacity(0.5), width: 1.5)
                    : null,
              ),
              child: Text(
                widget.text,
                style: AppTheme.display(
                  fontSize: 16,
                  weight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: widget.isOutlined
                      ? glowColor
                      : (enabled ? AppTheme.backgroundDeep : AppTheme.textMuted),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
