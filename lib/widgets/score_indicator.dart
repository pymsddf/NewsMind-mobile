import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../theme/intelligence_design_system.dart';

class ScoreIndicator extends StatelessWidget {
  final int score;
  final double size;
  final String? label;
  final Color? color;

  const ScoreIndicator({
    super.key,
    required this.score,
    this.size = 100,
    this.label,
    this.color,
  });

  Color get _color {
    if (color != null) return color!;
    if (score >= 80) return AppTheme.success;
    if (score >= 50) return AppTheme.warning;
    return AppTheme.error;
  }

  @override
  Widget build(BuildContext context) {
    // Just the ring with the score centered inside it.
    final circle = SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _CirclePainter(
              progress: score / 100,
              color: _color,
              backgroundColor: AppColors.rule,
            ),
          ),
          Text(
            '$score',
            style: AppType.data(
              size: size * 0.34,
              weight: FontWeight.w600,
              color: _color,
            ),
          ),
        ],
      ),
    );

    if (label == null) return circle;

    // The label sits BELOW the circle (not inside) so a long word like
    // "CREDIBILITY" has room to render in full.
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        SizedBox(height: 8),
        Text(
          label!.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppType.ui(
            size: 10,
            weight: FontWeight.w700,
            color: AppColors.muted,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _CirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CirclePainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 10) / 2;

    // Draw background circle
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
