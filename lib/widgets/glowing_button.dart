import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlowingButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isCyan;
  final bool isOutlined;
  final double? width;
  final Gradient? gradient;

  const GlowingButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isCyan = true,
    this.isOutlined = false,
    this.width,
    this.gradient,
  });

  @override
  State<GlowingButton> createState() => _GlowingButtonState();
}

class _GlowingButtonState extends State<GlowingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.6).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCyan ? AppTheme.cyan : AppTheme.magenta;
    final effectiveGradient = widget.gradient ?? 
        (widget.isCyan ? AppTheme.cyanGradient : AppTheme.magentaGradient);
    
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return IgnorePointer(
          ignoring: widget.onPressed == null,
          child: Opacity(
            opacity: widget.onPressed == null ? 0.5 : 1.0,
            child: GestureDetector(
              onTap: widget.onPressed,
              child: Container(
                width: widget.width ?? double.infinity,
                height: 64,
                decoration: BoxDecoration(
                  gradient: widget.gradient != null ? effectiveGradient : null,
                  color: widget.gradient == null ? (widget.isCyan ? AppTheme.cyan : AppTheme.magenta) : null,
                  borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(_glowAnimation.value),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                child: widget.isOutlined
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: color, width: 2),
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                        ),
                        child: Center(
                          child: Text(
                            widget.text,
                            style: TextStyle(
                              color: color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        widget.text,
                        style: const TextStyle(
                          color: AppTheme.background,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
