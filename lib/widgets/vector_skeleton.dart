import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// Vector Skeleton Loader - High-fidelity animated vector skeleton screens
/// 
/// Transforms from: Generic gray boxes
/// Transforms to: High-fidelity animated vector skeleton screens 
///                showing precise structure

class VectorSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const VectorSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.borderRadius = 0,
  });

  @override
  State<VectorSkeleton> createState() => _VectorSkeletonState();
}

class _VectorSkeletonState extends State<VectorSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
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
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
                widget.borderRadius > 0 ? widget.borderRadius : AppRadius.sm),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.paperAlt,
                AppColors.paperAlt,
                AppColors.rule,
                AppColors.paperAlt,
                AppColors.paperAlt,
              ],
              stops: [
                (_animation.value - 0.3).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 0.1).clamp(0.0, 1.0),
                (_animation.value + 0.3).clamp(0.0, 1.0),
                (_animation.value + 0.5).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// News Card Skeleton - Shows precise structure
class NewsCardSkeleton extends StatelessWidget {
  NewsCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(IntelligenceSpacing.standard),
      margin: EdgeInsets.symmetric(
        vertical: IntelligenceSpacing.compact,
      ),
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: IntelligenceColors.slateGrey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: Timestamp + Source
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              VectorSkeleton(width: 80, height: 14),
              VectorSkeleton(width: 48, height: 12),
            ],
          ),
          SizedBox(height: IntelligenceSpacing.standard),
          
          // Headline skeleton
          VectorSkeleton(height: 20),
          SizedBox(height: IntelligenceSpacing.compact),
          VectorSkeleton(height: 20),
          SizedBox(height: IntelligenceSpacing.compact),
          VectorSkeleton(width: 200, height: 20),
          
          SizedBox(height: IntelligenceSpacing.standard),
          
          // Tags skeleton
          Row(
            children: [
              VectorSkeleton(width: 60, height: 20),
              SizedBox(width: IntelligenceSpacing.compact),
              VectorSkeleton(width: 80, height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

/// Alert Card Skeleton
class AlertCardSkeleton extends StatelessWidget {
  AlertCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: IntelligenceSpacing.compact,
      ),
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border(
          left: BorderSide(
            color: AppColors.rule,
            width: 4,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(IntelligenceSpacing.standard),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot placeholder
            SizedBox(width: 16),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VectorSkeleton(width: 60, height: 12),
                  SizedBox(height: 8),
                  VectorSkeleton(height: 16),
                  SizedBox(height: 4),
                  VectorSkeleton(width: 250, height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Form Skeleton - For loading states
class FormSkeleton extends StatelessWidget {
  FormSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(IntelligenceSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label placeholder
          VectorSkeleton(width: 100, height: 14),
          SizedBox(height: IntelligenceSpacing.compact),
          
          // Input placeholder
          VectorSkeleton(height: 48),
          
          SizedBox(height: IntelligenceSpacing.standard),
          
          // Label placeholder
          VectorSkeleton(width: 80, height: 14),
          SizedBox(height: IntelligenceSpacing.compact),
          
          // Input placeholder
          VectorSkeleton(height: 48),
          
          SizedBox(height: IntelligenceSpacing.spacious),
          
          // Button placeholder
          VectorSkeleton(height: 52),
        ],
      ),
    );
  }
}

/// Screen Skeleton - Full screen loading state
class ScreenSkeleton extends StatelessWidget {
  final bool showHeader;
  final int cardCount;

  const ScreenSkeleton({
    super.key,
    this.showHeader = true,
    this.cardCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(IntelligenceSpacing.standard),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          if (showHeader) ...[
            VectorSkeleton(width: 200, height: 28),
            SizedBox(height: IntelligenceSpacing.compact),
            VectorSkeleton(width: 150, height: 16),
            SizedBox(height: IntelligenceSpacing.spacious),
          ],
          
          // Cards
          ...List.generate(cardCount, (index) => NewsCardSkeleton()),
        ],
      ),
    );
  }
}
