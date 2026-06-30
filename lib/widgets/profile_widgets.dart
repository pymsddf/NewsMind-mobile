import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';
import '../models/user_model.dart';
import 'vector_button.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel? user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(IntelligenceSpacing.spacious),
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(color: IntelligenceColors.slateGrey, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: IntelligenceColors.electricTeal,
            ),
            child: Center(
              child: Text(
                user?.name.isNotEmpty == true
                    ? user!.name[0].toUpperCase()
                    : '?',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: IntelligenceColors.obsidianBlack,
                ),
              ),
            ),
          ),
          SizedBox(height: IntelligenceSpacing.standard),

          // Name
          Text(
            user?.name ?? 'User',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              fontSize: IntelligenceTypography.headingMd,
              fontWeight: FontWeight.w700,
              color: IntelligenceColors.pureWhite,
            ),
          ),
          SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              fontSize: IntelligenceTypography.bodyMd,
              color: IntelligenceColors.secondaryTextGrey,
            ),
          ),
          SizedBox(height: IntelligenceSpacing.compact),

          // Role badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: IntelligenceSpacing.standard,
              vertical: IntelligenceSpacing.compact,
            ),
            decoration: BoxDecoration(
              color: IntelligenceColors.electricTeal.withValues(alpha: 0.15),
              border: Border.all(
                color: IntelligenceColors.electricTeal.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              user?.role ?? 'REPORTER',
              style: AppTheme.textTheme.labelMedium?.copyWith(
                fontSize: IntelligenceTypography.monoSm,
                fontWeight: FontWeight.w600,
                color: IntelligenceColors.electricTeal,
                letterSpacing: 1,
              ),
            ),
          ),

          // Pro badge
          if (user?.pro == true) ...[
            SizedBox(height: IntelligenceSpacing.compact),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: IntelligenceSpacing.standard,
                vertical: IntelligenceSpacing.compact,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    IntelligenceColors.kineticsOrange,
                    Color(0xFF8A6420) // darker ochre — tonal, matches web warning
                  ],
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.stars_rounded,
                    color: IntelligenceColors.pureWhite,
                    size: 14,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'PRO',
                    style: AppTheme.textTheme.labelMedium?.copyWith(
                      fontSize: IntelligenceTypography.monoSm,
                      fontWeight: FontWeight.w700,
                      color: IntelligenceColors.pureWhite,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(color: IntelligenceColors.slateGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: IntelligenceSpacing.iconMd),
                SizedBox(width: IntelligenceSpacing.compact),
                Text(
                  title,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: IntelligenceTypography.bodyMd,
                    fontWeight: FontWeight.w600,
                    color: IntelligenceColors.pureWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: IntelligenceColors.slateGrey, height: 1),
          ...children,
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(color: IntelligenceColors.slateGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: IntelligenceSpacing.iconMd),
                SizedBox(width: IntelligenceSpacing.compact),
                Text(
                  title,
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: IntelligenceTypography.bodyMd,
                    fontWeight: FontWeight.w600,
                    color: IntelligenceColors.pureWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: IntelligenceColors.slateGrey, height: 1),
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class SubscriptionCard extends StatelessWidget {
  final UserModel? user;
  final VoidCallback onManage;
  final VoidCallback onUpgrade;
  final String Function(DateTime?) formatDate;

  const SubscriptionCard({
    super.key,
    required this.user,
    required this.onManage,
    required this.onUpgrade,
    required this.formatDate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(color: IntelligenceColors.slateGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Row(
              children: [
                Icon(
                  Icons.subscriptions_rounded,
                  color: IntelligenceColors.kineticsOrange,
                  size: IntelligenceSpacing.iconMd,
                ),
                SizedBox(width: IntelligenceSpacing.compact),
                Text(
                  'SUBSCRIPTION',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: IntelligenceTypography.bodyMd,
                    fontWeight: FontWeight.w600,
                    color: IntelligenceColors.pureWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: IntelligenceColors.slateGrey, height: 1),
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Column(
              children: [
                if (user?.pro == true) ...[
                  InfoRow(
                      label: 'Plan', value: user?.planId?.toUpperCase() ?? '-'),
                  InfoRow(
                      label: 'Billing',
                      value: user?.billingCycle?.toUpperCase() ?? '-'),
                  InfoRow(
                      label: 'Expires',
                      value: formatDate(user?.subscriptionEndDate)),
                  SizedBox(height: IntelligenceSpacing.standard),
                ],
                SizedBox(
                  width: double.infinity,
                  child: VectorButton(
                    label: user?.pro == true
                        ? 'MANAGE SUBSCRIPTION'
                        : 'UPGRADE TO PRO',
                    type: user?.pro == true
                        ? VectorButtonType.outline
                        : VectorButtonType.primary,
                    fullWidth: true,
                    onPressed: () {
                      if (user?.pro == true) {
                        onManage();
                      } else {
                        onUpgrade();
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SecurityCard extends StatelessWidget {
  final UserModel? user;
  final ValueChanged<bool> onToggleLoginNotifications;

  const SecurityCard({
    super.key,
    required this.user,
    required this.onToggleLoginNotifications,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(color: IntelligenceColors.slateGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Row(
              children: [
                Icon(
                  Icons.security_rounded,
                  color: IntelligenceColors.electricTeal,
                  size: IntelligenceSpacing.iconMd,
                ),
                SizedBox(width: IntelligenceSpacing.compact),
                Text(
                  'SECURITY SETTINGS',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: IntelligenceTypography.bodyMd,
                    fontWeight: FontWeight.w600,
                    color: IntelligenceColors.pureWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: IntelligenceColors.slateGrey, height: 1),
          SwitchListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: IntelligenceSpacing.standard,
              vertical: IntelligenceSpacing.compact,
            ),
            title: Text(
              'Login Notifications',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.pureWhite,
                fontSize: IntelligenceTypography.bodyMd,
              ),
            ),
            subtitle: Text(
              'Get alerts for login activity',
              style: AppTheme.textTheme.bodyLarge?.copyWith(
                color: IntelligenceColors.secondaryTextGrey,
                fontSize: IntelligenceTypography.bodySm,
              ),
            ),
            activeThumbColor: IntelligenceColors.electricTeal,
            value: user?.loginNotifications ?? true,
            onChanged: onToggleLoginNotifications,
          ),
        ],
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const ActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: IntelligenceSpacing.standard,
        vertical: IntelligenceSpacing.compact,
      ),
      leading: Icon(icon, color: IntelligenceColors.electricTeal, size: 20),
      title: Text(
        title,
        style: AppTheme.textTheme.bodyMedium?.copyWith(
          color: IntelligenceColors.pureWhite,
          fontSize: IntelligenceTypography.bodyMd,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: IntelligenceColors.secondaryTextGrey,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: IntelligenceSpacing.compact),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.textTheme.bodyLarge?.copyWith(
              color: IntelligenceColors.secondaryTextGrey,
              fontSize: IntelligenceTypography.bodyMd,
            ),
          ),
          Text(
            value,
            style: AppTheme.textTheme.labelMedium?.copyWith(
              color: IntelligenceColors.pureWhite,
              fontSize: IntelligenceTypography.monoMd,
            ),
          ),
        ],
      ),
    );
  }
}

class UsageSection extends StatelessWidget {
  final UserModel user;

  const UsageSection({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final usage = user.usage!;
    return Container(
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(color: IntelligenceColors.slateGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Row(
              children: [
                Icon(
                  Icons.analytics_rounded,
                  color: IntelligenceColors.cyberBlue,
                  size: IntelligenceSpacing.iconMd,
                ),
                SizedBox(width: IntelligenceSpacing.compact),
                Text(
                  'USAGE STATS',
                  style: AppTheme.textTheme.bodyMedium?.copyWith(
                    fontSize: IntelligenceTypography.bodyMd,
                    fontWeight: FontWeight.w600,
                    color: IntelligenceColors.pureWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: IntelligenceColors.slateGrey, height: 1),
          Padding(
            padding: EdgeInsets.all(IntelligenceSpacing.standard),
            child: Column(
              children: [
                UsageBar(
                  label: 'VERIFICATIONS',
                  used: usage.verifications.used,
                  limit: usage.verifications.limit,
                ),
                SizedBox(height: IntelligenceSpacing.standard),
                UsageBar(
                  label: 'BIAS ANALYSES',
                  used: usage.biasDetections.used,
                  limit: usage.biasDetections.limit,
                ),
                if (user.role.toLowerCase() != 'basic') ...[
                  SizedBox(height: IntelligenceSpacing.standard),
                  UsageBar(
                    label: 'GENERATIONS',
                    used: usage.newsGenerations.used,
                    limit: usage.newsGenerations.limit,
                    color: IntelligenceColors.electricTeal,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UsageBar extends StatelessWidget {
  final String label;
  final int used;
  final int limit;
  final Color? color;

  const UsageBar({
    super.key,
    required this.label,
    required this.used,
    required this.limit,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isUnlimited = limit < 0;
    final percentage =
        (!isUnlimited && limit > 0) ? (used / limit).clamp(0.0, 1.0) : 0.0;
    final isHighUsage = percentage > 0.8;
    final isMediumUsage = percentage > 0.5;

    Color barColor;
    if (color != null) {
      barColor = color!;
    } else if (isHighUsage) {
      barColor = IntelligenceColors.crimsonSpike;
    } else if (isMediumUsage) {
      barColor = IntelligenceColors.kineticsOrange;
    } else {
      barColor = IntelligenceColors.electricTeal;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTheme.textTheme.labelMedium?.copyWith(
                fontSize: IntelligenceTypography.monoSm,
                color: IntelligenceColors.secondaryTextGrey,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              isUnlimited ? '$used / Unlimited' : '$used / $limit',
              style: AppTheme.textTheme.labelMedium?.copyWith(
                fontSize: IntelligenceTypography.monoSm,
                fontWeight: FontWeight.w600,
                color: IntelligenceColors.pureWhite,
              ),
            ),
          ],
        ),
        SizedBox(height: IntelligenceSpacing.compact),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: IntelligenceColors.slateGrey,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: barColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
