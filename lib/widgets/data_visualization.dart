import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

// ============================================================================
// Verdict Desk data visualisation — precise 2D charts, no gloss.
// ============================================================================

/// Bias "lean" spectrum — a calm track that warms toward the edges, with an
/// ink needle marking where the content sits. Signature bias readout.
class BiasSpectrum extends StatelessWidget {
  final double biasValue; // -1.0 (left) .. 0 (neutral) .. 1.0 (right)
  final double width;

  const BiasSpectrum({
    super.key,
    required this.biasValue,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('UNBIASED',
                style: AppType.ui(
                    size: 10, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 1)),
            Spacer(),
            Text('NEUTRAL',
                style: AppType.ui(
                    size: 10, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 1)),
            Spacer(),
            Text('BIASED',
                style: AppType.ui(
                    size: 10, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 1)),
          ],
        ),
        SizedBox(height: AppSpace.sm),
        SizedBox(
          width: width,
          height: 18,
          child: CustomPaint(painter: _BiasSpectrumPainter(biasValue: biasValue)),
        ),
        SizedBox(height: AppSpace.sm),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _getBiasColor().withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(_getBiasLabel(),
                style: AppType.ui(
                    size: 12, weight: FontWeight.w700, color: _getBiasColor(), letterSpacing: 0.5)),
          ),
        ),
      ],
    );
  }

  String _getBiasLabel() {
    final score = (biasValue + 1) / 2; // 0 = unbiased .. 1 = heavily biased
    if (score < 0.34) return 'LOW BIAS';
    if (score < 0.67) return 'MODERATE BIAS';
    return 'HIGH BIAS';
  }

  Color _getBiasColor() {
    final score = (biasValue + 1) / 2;
    if (score < 0.34) return AppColors.verified;
    if (score < 0.67) return AppColors.caution;
    return AppColors.redline;
  }
}

class _BiasSpectrumPainter extends CustomPainter {
  final double biasValue;
  _BiasSpectrumPainter({required this.biasValue});

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.height / 2 - 3, size.width, 6),
      Radius.circular(3),
    );
    // Calm centre that warms toward either edge.
    final gradient = LinearGradient(
      colors: [AppColors.caution, AppColors.verified, AppColors.caution],
      stops: const [0.0, 0.5, 1.0],
    );
    canvas.drawRRect(
      track,
      Paint()
        ..shader = gradient.createShader(
            Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Centre tick
    final centreX = size.width / 2;
    canvas.drawLine(
      Offset(centreX, 2),
      Offset(centreX, size.height - 2),
      Paint()
        ..color = AppColors.surface.withValues(alpha: 0.7)
        ..strokeWidth = 1,
    );

    // Needle marker
    final normalized = (biasValue.clamp(-1.0, 1.0) + 1) / 2;
    final markerX = size.width * normalized;
    final needle = Paint()..color = AppColors.ink;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(markerX - 2, 0, 4, size.height),
        Radius.circular(2),
      ),
      needle,
    );
    // Diamond head
    final path = Path()
      ..moveTo(markerX, -1)
      ..lineTo(markerX + 5, 4)
      ..lineTo(markerX, 9)
      ..lineTo(markerX - 5, 4)
      ..close();
    canvas.drawPath(path, needle);
  }

  @override
  bool shouldRepaint(covariant _BiasSpectrumPainter old) =>
      old.biasValue != biasValue;
}

/// Segmented level bar — LOW | MED | HIGH.
class SegmentedBar extends StatelessWidget {
  final int level; // 0 = LOW, 1 = MED, 2 = HIGH
  final String? label;
  final Color? activeColor;

  const SegmentedBar({
    super.key,
    required this.level,
    this.label,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpace.sm),
            child: Text(label!.toUpperCase(),
                style: AppType.ui(
                    size: 10, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 1)),
          ),
        Row(
          children: [
            _segment('LOW', level >= 0, first: true),
            SizedBox(width: 3),
            _segment('MED', level >= 1),
            SizedBox(width: 3),
            _segment('HIGH', level >= 2, last: true),
          ],
        ),
      ],
    );
  }

  Widget _segment(String text, bool isActive,
      {bool first = false, bool last = false}) {
    return Expanded(
      child: Container(
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? (activeColor ?? AppColors.redline) : AppColors.paperAlt,
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(first ? AppRadius.sm : 0),
            right: Radius.circular(last ? AppRadius.sm : 0),
          ),
        ),
        child: Text(text,
            style: AppType.ui(
                size: 10,
                weight: FontWeight.w700,
                color: isActive ? AppColors.onAccent : AppColors.muted,
                letterSpacing: 0.6)),
      ),
    );
  }
}

/// Credibility dial — a clean progress ring with the percentage at its core.
class CredibilityArc extends StatelessWidget {
  final double score; // 0.0 to 1.0
  final double size;

  const CredibilityArc({super.key, required this.score, this.size = 120});

  static Color colorFor(double s) {
    if (s >= 0.8) return AppColors.verified;
    if (s >= 0.5) return AppColors.caution;
    return AppColors.redline;
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (score * 100).toInt();
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
              size: Size(size, size),
              painter: _CredibilityArcPainter(score: score)),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$percentage%',
                  style: AppType.data(
                      size: size * 0.22,
                      weight: FontWeight.w600,
                      color: colorFor(score))),
              SizedBox(height: 2),
              // Constrained + scaleDown so the label stays legible on one line
              // at small dial sizes (was rendering garbled at ~7px).
              SizedBox(
                width: size * 0.82,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('CREDIBILITY',
                      style: AppType.ui(
                          size: 9,
                          weight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CredibilityArcPainter extends CustomPainter {
  final double score;
  _CredibilityArcPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    const strokeWidth = 9.0;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = AppColors.rule
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * score.clamp(0.0, 1.0),
      false,
      Paint()
        ..color = CredibilityArc.colorFor(score)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CredibilityArcPainter old) =>
      old.score != score;
}

/// Vertical sparkline — compact trend line.
class VerticalSparkline extends StatelessWidget {
  final List<double> data;
  final double width;
  final double height;
  final Color? color;

  const VerticalSparkline({
    super.key,
    required this.data,
    this.width = 32,
    this.height = 64,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox.shrink();
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        size: Size(width, height),
        painter: _SparklinePainter(data: data, color: color ?? AppColors.caution),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  _SparklinePainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    final maxVal = data.reduce(math.max);
    final minVal = data.reduce(math.min);
    final range = maxVal - minVal;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    final stepX = data.length > 1 ? size.width / (data.length - 1) : 0.0;
    for (var i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedY = range > 0 ? (data[i] - minVal) / range : 0.5;
      final y = size.height - (normalizedY * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => true;
}

/// Intelligence block — compact mono metadata strip.
class IntelligenceBlock extends StatelessWidget {
  final String biasIndicator;
  final String factCheckIndicator;
  final String generationIndicator;
  final String dateTime;

  const IntelligenceBlock({
    super.key,
    required this.biasIndicator,
    required this.factCheckIndicator,
    required this.generationIndicator,
    required this.dateTime,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.paperAlt,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _indicator('B', biasIndicator, AppColors.caution),
          SizedBox(width: AppSpace.sm),
          _indicator('F', factCheckIndicator, AppColors.verified),
          SizedBox(width: AppSpace.sm),
          _indicator('G', generationIndicator, AppColors.neutral),
          SizedBox(width: AppSpace.md),
          Text(dateTime, style: AppType.data(size: 10, color: AppColors.muted)),
        ],
      ),
    );
  }

  Widget _indicator(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label: ', style: AppType.data(size: 10, color: AppColors.muted)),
        Text(value.toUpperCase(),
            style: AppType.data(size: 10, weight: FontWeight.w600, color: color)),
      ],
    );
  }
}
