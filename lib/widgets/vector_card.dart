import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// Card — a clean white sheet on paper with a hairline rule and a whisper of
/// shadow for lift. Softly rounded (Verdict Desk).
class VectorCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final bool showBorder;
  final VoidCallback? onTap;
  final Color? borderColor;

  const VectorCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.showBorder = true,
    this.onTap,
    this.borderColor,
  });

  static const cardShadow = [
    BoxShadow(
      color: Color(0x0F16182D),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? EdgeInsets.all(AppSpace.md),
      margin: margin ?? EdgeInsets.symmetric(vertical: AppSpace.sm),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: cardShadow,
        border: showBorder
            ? Border.all(color: borderColor ?? AppColors.rule, width: 1)
            : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: cardContent,
        ),
      );
    }
    return cardContent;
  }
}

/// News card — dateline + serif headline + verdict metrics.
class NewsCard extends StatelessWidget {
  final String timestamp;
  final String headline;
  final double? biasScore;
  final double? credibilityScore;
  final VoidCallback? onTap;
  final String? source;
  final List<String>? tags;

  const NewsCard({
    super.key,
    required this.timestamp,
    required this.headline,
    this.biasScore,
    this.credibilityScore,
    this.onTap,
    this.source,
    this.tags,
  });

  @override
  Widget build(BuildContext context) {
    return VectorCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                timestamp,
                style: AppType.data(
                    size: 12, weight: FontWeight.w500, color: AppColors.graphite),
              ),
              if (source != null)
                Text(
                  source!.toUpperCase(),
                  style: AppType.ui(
                      size: 10,
                      weight: FontWeight.w600,
                      color: AppColors.muted,
                      letterSpacing: 1),
                ),
            ],
          ),
          SizedBox(height: AppSpace.sm),
          Text(
            headline,
            style: AppType.display(
                size: 18, weight: FontWeight.w600, color: AppColors.ink, height: 1.3),
          ),
          if (tags != null || biasScore != null || credibilityScore != null) ...[
            SizedBox(height: AppSpace.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (tags != null)
                  Expanded(
                    child: Wrap(
                      spacing: AppSpace.sm,
                      runSpacing: AppSpace.sm,
                      children: tags!.map(_buildTag).toList(),
                    ),
                  ),
                if (biasScore != null || credibilityScore != null)
                  Row(
                    children: [
                      if (biasScore != null) ...[
                        _metric('BIAS', biasScore!,
                            biasScore! > 0.6 ? AppColors.caution : AppColors.verified),
                        SizedBox(width: AppSpace.md),
                      ],
                      if (credibilityScore != null)
                        _metric('CRED', credibilityScore!, AppColors.verified),
                    ],
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.paperAlt,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.rule),
      ),
      child: Text(
        tag.toUpperCase(),
        style: AppType.ui(size: 10, weight: FontWeight.w600, color: AppColors.graphite, letterSpacing: 0.6),
      ),
    );
  }

  Widget _metric(String label, double value, Color color) {
    final percentage = (value * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label,
            style: AppType.ui(size: 9, weight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.8)),
        Text('$percentage%',
            style: AppType.data(size: 14, weight: FontWeight.w600, color: color)),
      ],
    );
  }
}

/// Alert card — color-coded left rule by alert type.
class AlertCard extends StatelessWidget {
  final String timestamp;
  final String title;
  final String? description;
  final AlertType alertType;
  final bool isRead;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.timestamp,
    required this.title,
    this.description,
    required this.alertType,
    this.isRead = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getAlertColor();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: AppSpace.sm),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.rule),
          boxShadow: VectorCard.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(AppRadius.md)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(AppSpace.md),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(right: AppSpace.sm, top: 6),
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle),
                        ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(timestamp,
                                style: AppType.data(
                                    size: 11, color: AppColors.muted)),
                            SizedBox(height: 4),
                            Text(title,
                                style: AppType.ui(
                                    size: 14,
                                    weight: FontWeight.w600,
                                    color: AppColors.ink)),
                            if (description != null) ...[
                              SizedBox(height: 4),
                              Text(description!,
                                  style: AppType.display(
                                      size: 13,
                                      color: AppColors.graphite,
                                      height: 1.4)),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getAlertColor() {
    switch (alertType) {
      case AlertType.factAlert:
        return AppColors.redline;
      case AlertType.biasAlert:
        return AppColors.caution;
      case AlertType.generationAlert:
        return AppColors.neutral;
      case AlertType.verificationAlert:
        return AppColors.verified;
    }
  }
}

enum AlertType {
  factAlert,
  biasAlert,
  generationAlert,
  verificationAlert,
}

/// Stat card — segmented usage bar.
class StatCard extends StatelessWidget {
  final String label;
  final int current;
  final int total;
  final Color? activeColor;

  const StatCard({
    super.key,
    required this.label,
    required this.current,
    required this.total,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.indigo;
    return VectorCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
              style: AppType.ui(
                  size: 10,
                  weight: FontWeight.w600,
                  color: AppColors.muted,
                  letterSpacing: 1)),
          SizedBox(height: AppSpace.sm),
          Row(
            children: List.generate(total, (index) {
              return Expanded(
                child: Container(
                  height: 8,
                  margin: EdgeInsets.only(right: index < total - 1 ? 3 : 0),
                  decoration: BoxDecoration(
                    color: index < current ? color : AppColors.rule,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: AppSpace.sm),
          Text('$current / $total',
              style: AppType.data(
                  size: 13, weight: FontWeight.w600, color: AppColors.ink)),
        ],
      ),
    );
  }
}
