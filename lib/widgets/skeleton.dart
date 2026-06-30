import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/intelligence_design_system.dart';

/// Wraps skeleton placeholder content in a shimmer sweep. Theme-aware (colours
/// come from [AppColors], so it adapts to light/dark).
class Skeleton extends StatelessWidget {
  final Widget child;
  const Skeleton({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.rule,
      highlightColor: AppColors.paperAlt,
      child: child,
    );
  }
}

/// A single rounded placeholder block. Use inside a [Skeleton].
class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  const SkeletonBox({super.key, this.width, this.height = 12, this.radius = 6});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.ruleStrong,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
