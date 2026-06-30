import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// NewsMind masthead — display-serif wordmark with "AI" set in press-red
/// italic, matching the web app (font-heading bold; `.text-accent italic`).
class NewsMindBrandTitle extends StatelessWidget {
  final double logoSize;
  final double nameSize;

  const NewsMindBrandTitle({
    super.key,
    this.logoSize = 30,
    this.nameSize = 21,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: logoSize,
          height: logoSize,
          child: Image.asset('assets/logo.png', fit: BoxFit.contain),
        ),
        SizedBox(width: AppSpace.sm + 2),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'NewsMind ',
                style: AppType.headline(
                  size: nameSize,
                  weight: FontWeight.w700,
                  color: AppColors.ink,
                  height: 1,
                  letterSpacing: -0.4,
                ),
              ),
              TextSpan(
                text: 'AI',
                style: AppType.headline(
                  size: nameSize,
                  weight: FontWeight.w700,
                  color: AppColors.redline,
                  fontStyle: FontStyle.italic,
                  height: 1,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
