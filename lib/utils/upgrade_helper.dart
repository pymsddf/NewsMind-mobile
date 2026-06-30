import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/promo_code_dialog.dart';

class UpgradeHelper {
  static bool isUsageLimitError(Object error) {
    final text = error.toString().toLowerCase();
    return text.contains('usage_limit') ||
        text.contains('usage limit') ||
        text.contains('upgrade_required') ||
        text.contains('upgraderequired') ||
        text.contains('limit exceeded') ||
        text.contains('429');
  }

  static Future<void> showUpgradeRequiredDialog(
    BuildContext context, {
    required String featureLabel,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IntelligenceColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(IntelligenceSpacing.standard),
        ),
        title: Row(
          children: [
            Icon(
              Icons.stars_rounded,
              color: IntelligenceColors.kineticsOrange,
              size: 28,
            ),
            SizedBox(width: IntelligenceSpacing.compact),
            Text(
              'Upgrade Required',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.pureWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'You have reached your free plan limit for $featureLabel. Upgrade to Pro to continue.',
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            color: IntelligenceColors.secondaryTextGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Later',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.secondaryTextGrey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: IntelligenceColors.electricTeal,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await showPromoCodeDialog(context);
            },
            child: Text(
              'Enter promo code',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.obsidianBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
