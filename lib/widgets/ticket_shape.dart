import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Cuts two small circular "punch" notches out of a rounded-rect shape,
/// like a torn admission ticket. [notchesOnSides] punches the left/right
/// edges at vertical-center (used for wide CTA buttons); otherwise the
/// notches sit on the top/bottom edges at [stubFraction] of the width,
/// where a ticket would be torn from its stub.
class TicketClipper extends CustomClipper<Path> {
  final double radius;
  final double notchRadius;
  final bool notchesOnSides;
  final double stubFraction;

  const TicketClipper({
    this.radius = 20,
    this.notchRadius = 8,
    this.notchesOnSides = true,
    this.stubFraction = 0.28,
  });

  @override
  Path getClip(Size size) {
    final base = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(radius),
      ));

    final notches = Path();
    if (notchesOnSides) {
      final midY = size.height / 2;
      notches.addOval(Rect.fromCircle(center: Offset(0, midY), radius: notchRadius));
      notches.addOval(Rect.fromCircle(center: Offset(size.width, midY), radius: notchRadius));
    } else {
      final stubX = size.width * stubFraction;
      notches.addOval(Rect.fromCircle(center: Offset(stubX, 0), radius: notchRadius));
      notches.addOval(Rect.fromCircle(center: Offset(stubX, size.height), radius: notchRadius));
    }

    return Path.combine(PathOperation.difference, base, notches);
  }

  @override
  bool shouldReclip(covariant TicketClipper oldClipper) =>
      oldClipper.radius != radius ||
      oldClipper.notchRadius != notchRadius ||
      oldClipper.notchesOnSides != notchesOnSides ||
      oldClipper.stubFraction != stubFraction;
}

/// A thin dashed perforation line, the "tear here" mark of a ticket stub.
class DashedDivider extends StatelessWidget {
  final Axis axis;
  final Color color;
  final double thickness;

  const DashedDivider({
    super.key,
    this.axis = Axis.vertical,
    this.color = AppTheme.textMuted,
    this.thickness = 1.5,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: axis == Axis.vertical ? Size(thickness, double.infinity) : Size(double.infinity, thickness),
      painter: _DashedLinePainter(axis: axis, color: color, thickness: thickness),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Axis axis;
  final Color color;
  final double thickness;

  _DashedLinePainter({required this.axis, required this.color, required this.thickness});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.35)
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round;

    const dash = 5.0;
    const gap = 5.0;
    if (axis == Axis.vertical) {
      double y = 0;
      while (y < size.height) {
        canvas.drawLine(Offset(size.width / 2, y), Offset(size.width / 2, y + dash), paint);
        y += dash + gap;
      }
    } else {
      double x = 0;
      while (x < size.width) {
        canvas.drawLine(Offset(x, size.height / 2), Offset(x + dash, size.height / 2), paint);
        x += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedLinePainter oldDelegate) => false;
}

/// A stub-style ticket card: a notched stamp/icon column on the left,
/// torn from the body content by a dashed perforation.
class TicketCard extends StatelessWidget {
  final Widget stub;
  final Widget body;
  final Color stubColor;
  final Gradient? stubGradient;
  final VoidCallback? onTap;
  final List<BoxShadow>? glow;
  final double stubWidth;

  const TicketCard({
    super.key,
    required this.stub,
    required this.body,
    required this.stubColor,
    this.stubGradient,
    this.onTap,
    this.glow,
    this.stubWidth = 92,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: glow,
        ),
        child: ClipPath(
          clipper: const TicketClipper(
            radius: 22,
            notchRadius: 9,
            notchesOnSides: false,
            stubFraction: 0.0,
          ),
          child: Container(
            color: AppTheme.cardBackground,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    width: stubWidth,
                    decoration: BoxDecoration(
                      color: stubGradient == null ? stubColor : null,
                      gradient: stubGradient,
                    ),
                    alignment: Alignment.center,
                    child: stub,
                  ),
                  SizedBox(
                    width: 18,
                    child: CustomPaint(
                      painter: _StubNotchPainter(color: AppTheme.background),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(2, 18, 20, 18),
                      child: body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the punched notches + dashed tear-line for [TicketCard]'s divider
/// column, since the outer [TicketClipper] only cuts the outer silhouette.
class _StubNotchPainter extends CustomPainter {
  final Color color;
  const _StubNotchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final notchPaint = Paint()..color = color;
    canvas.drawCircle(Offset(cx, 0), 9, notchPaint);
    canvas.drawCircle(Offset(cx, size.height), 9, notchPaint);

    final dashPaint = Paint()
      ..color = AppTheme.textMuted.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 5.0;
    double y = 14;
    while (y < size.height - 14) {
      canvas.drawLine(Offset(cx, y), Offset(cx, y + dash), dashPaint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _StubNotchPainter oldDelegate) => false;
}
