import 'package:flutter/material.dart';

/// Soft leaf silhouettes in the top-right and bottom-left corners, painted
/// behind a page body. Purely decorative: ignores touches and semantics.
class LeafBackdrop extends StatelessWidget {
  const LeafBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primaryContainer;
    return ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(painter: _LeafPainter(color), size: Size.infinite),
      ),
    );
  }
}

class _LeafPainter extends CustomPainter {
  final Color color;

  const _LeafPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    _leaf(
      canvas,
      Offset(size.width - 26, 52),
      length: 176,
      width: 60,
      angle: -0.55,
      opacity: 0.55,
    );
    _leaf(
      canvas,
      Offset(size.width - 96, 24),
      length: 118,
      width: 44,
      angle: -1.15,
      opacity: 0.32,
    );
    _leaf(
      canvas,
      Offset(24, size.height - 26),
      length: 160,
      width: 56,
      angle: 0.6,
      opacity: 0.5,
    );
    _leaf(
      canvas,
      Offset(92, size.height - 6),
      length: 112,
      width: 42,
      angle: 1.2,
      opacity: 0.28,
    );
  }

  // A leaf is two symmetric curves between the tips, plus a lighter midrib.
  void _leaf(
    Canvas canvas,
    Offset center, {
    required double length,
    required double width,
    required double angle,
    required double opacity,
  }) {
    final half = length / 2;
    final path = Path()
      ..moveTo(0, -half)
      ..quadraticBezierTo(width, -half * 0.15, 0, half)
      ..quadraticBezierTo(-width, -half * 0.15, 0, -half)
      ..close();

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..drawPath(path, Paint()..color = color.withValues(alpha: opacity))
      ..drawLine(
        Offset(0, -half * 0.75),
        Offset(0, half * 0.9),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_LeafPainter oldDelegate) => oldDelegate.color != color;
}
