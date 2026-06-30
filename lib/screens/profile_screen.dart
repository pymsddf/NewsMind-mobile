import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_controller.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/sharp_input.dart';
import '../widgets/vector_button.dart';
import '../models/user_model.dart';
import '../services/subscription_service.dart';
import '../services/news_service.dart';
import '../utils/upgrade_helper.dart';
import '../widgets/promo_code_dialog.dart';
import '../widgets/profile_widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/error_text.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _refreshUser() async {
    await context.read<AuthProvider>().loadUser();
  }

  /// Open the topic editor only if the user can still change topics — a free
  /// user gets one change after onboarding; after that the section is locked
  /// behind Pro (prompt to redeem a code instead of opening the editor).
  Future<void> _openMyTopics() async {
    final status = await NewsService.getTopicsStatus();
    if (!mounted) return;
    final canOpen = status['canEditFree'] == true || status['pro'] == true;
    if (canOpen) {
      context.push('/topics');
    } else {
      await UpgradeHelper.showUpgradeRequiredDialog(context,
          featureLabel: 'changing your topics');
    }
  }

  void _showEditNameDialog(String currentName) {
    _nameController.text = currentName;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: IntelligenceColors.surfaceDark,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: IntelligenceColors.slateGrey),
        ),
        title: Text(
          'Edit Name',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: IntelligenceColors.pureWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: SizedBox(
          width: 200,
          child: SharpInput(
            label: 'Name',
            hint: 'Enter your name',
            controller: _nameController,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.secondaryTextGrey,
              ),
            ),
          ),
          VectorButton(
            label: 'Save',
            type: VectorButtonType.primary,
            onPressed: () {
              Navigator.pop(context);
              _updateProfile({'name': _nameController.text});
            },
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();
    showDialog(
      context: context,
      builder: (context) {
        bool showCurrentPassword = false;
        bool showNewPassword = false;
        bool showConfirmPassword = false;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: IntelligenceColors.surfaceDark,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: IntelligenceColors.slateGrey),
              ),
              title: Text(
                'Change Password',
                style: AppTheme.textTheme.bodyMedium?.copyWith(
                  color: IntelligenceColors.pureWhite,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SharpInput(
                    label: 'Current Password',
                    hint: 'Enter current password',
                    controller: _currentPasswordController,
                    obscureText: !showCurrentPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: showCurrentPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () => setDialogState(
                        () => showCurrentPassword = !showCurrentPassword),
                  ),
                  SizedBox(height: IntelligenceSpacing.standard),
                  SharpInput(
                    label: 'New Password',
                    hint: 'Enter new password',
                    controller: _newPasswordController,
                    obscureText: !showNewPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: showNewPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () => setDialogState(
                        () => showNewPassword = !showNewPassword),
                  ),
                  SizedBox(height: IntelligenceSpacing.standard),
                  SharpInput(
                    label: 'Confirm New Password',
                    hint: 'Confirm new password',
                    controller: _confirmPasswordController,
                    obscureText: !showConfirmPassword,
                    prefixIcon: Icons.lock_outlined,
                    suffixIcon: showConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    onSuffixTap: () => setDialogState(
                        () => showConfirmPassword = !showConfirmPassword),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: IntelligenceColors.secondaryTextGrey,
                    ),
                  ),
                ),
                VectorButton(
                  label: 'Update',
                  type: VectorButtonType.primary,
                  onPressed: () {
                    if (_newPasswordController.text !=
                        _confirmPasswordController.text) {
                      _showSnack('Passwords do not match');
                      return;
                    }
                    Navigator.pop(context);
                    _updateProfile({
                      'currentPassword': _currentPasswordController.text,
                      'newPassword': _newPasswordController.text,
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateProfile(Map<String, dynamic> data) async {
    try {
      final result = await UserService.updateProfile(data);
      if (result['success'] == true) {
        if (!mounted) return;
        await Provider.of<AuthProvider>(context, listen: false).loadUser();
        if (!mounted) return;
        _showSnack(result['message'] ?? 'Profile updated successfully',
            isError: false);
      } else {
        _showSnack(result['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      _showSnack(friendlyError(e));
    }
  }

  Future<void> _updateSecurity(String setting, dynamic value) async {
    final response = await UserService.updateSecurity(setting, value);
    if (!mounted) return;

    if (response['success'] == true) {
      await _refreshUser();
      _showSnack('Settings updated!', isError: false);
    } else {
      _showSnack(response['message'] ?? 'Failed to update settings');
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (ctx) {
        int rating = 0;
        final commentController = TextEditingController();
        return StatefulBuilder(
            builder: (context, setDialogState) => AlertDialog(
                  backgroundColor: IntelligenceColors.surfaceDark,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: IntelligenceColors.slateGrey),
                  ),
                  title: Text(
                    'Logout',
                    style: AppTheme.textTheme.bodyMedium?.copyWith(
                      color: IntelligenceColors.pureWhite,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: SizedBox(
                    width: 320,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Please rate your experience before logout',
                          style: AppTheme.textTheme.bodyLarge?.copyWith(
                            color: IntelligenceColors.secondaryTextGrey,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (index) {
                            final star = index + 1;
                            return IconButton(
                              icon: Icon(
                                rating >= star
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: rating >= star
                                    ? IntelligenceColors.electricTeal
                                    : IntelligenceColors.secondaryTextGrey,
                              ),
                              onPressed: () =>
                                  setDialogState(() => rating = star),
                            );
                          }),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: commentController,
                          maxLines: 3,
                          style: AppTheme.textTheme.bodyMedium?.copyWith(
                            color: IntelligenceColors.pureWhite,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Optional comment',
                            hintStyle: AppTheme.textTheme.bodyMedium?.copyWith(
                              color: IntelligenceColors.secondaryTextGrey,
                            ),
                            filled: true,
                            fillColor: IntelligenceColors.obsidianBlack,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: Text(
                        'Cancel',
                        style: AppTheme.textTheme.bodyMedium?.copyWith(
                          color: IntelligenceColors.secondaryTextGrey,
                        ),
                      ),
                    ),
                    VectorButton(
                      label: 'Logout',
                      type: VectorButtonType.critical,
                      onPressed: () async {
                        final authProvider = context.read<AuthProvider>();
                        Navigator.pop(ctx);
                        await AuthService.submitLogoutFeedback(
                          rating: rating == 0 ? null : rating,
                          comment: commentController.text,
                        );
                        await authProvider.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
                    ),
                  ],
                ));
      },
    );
  }

  Future<void> _handleUpgrade(BuildContext context, UserModel? user) async {
    if (user == null) return;

    final billingCycle = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IntelligenceColors.surfaceDark,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: IntelligenceColors.slateGrey),
        ),
        title: Text(
          'Choose Plan',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: IntelligenceColors.pureWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Pro Monthly',
                  style: TextStyle(color: IntelligenceColors.pureWhite)),
              subtitle: Text('₹249 + GST',
                  style:
                      TextStyle(color: IntelligenceColors.secondaryTextGrey)),
              onTap: () => Navigator.pop(ctx, 'monthly'),
            ),
            ListTile(
              title: Text('Pro Yearly',
                  style: TextStyle(color: IntelligenceColors.pureWhite)),
              subtitle: Text('₹2390.4 + GST (20% off)',
                  style:
                      TextStyle(color: IntelligenceColors.secondaryTextGrey)),
              onTap: () => Navigator.pop(ctx, 'yearly'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: IntelligenceColors.secondaryTextGrey)),
          ),
        ],
      ),
    );

    if (billingCycle == null) return;

    try {
      final url = await SubscriptionService.getCheckoutUrl(
        planId: 'pro',
        billingCycle: billingCycle,
        userId: user.id ?? '',
      );

      if (url != null) {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          _showSnack('Could not launch payment page');
        }
      } else {
        _showSnack('Failed to generate payment session');
      }
    } catch (e) {
      _showSnack(friendlyError(e));
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: AppTheme.textTheme.labelMedium?.copyWith(),
        ),
        backgroundColor: isError
            ? IntelligenceColors.crimsonSpike
            : IntelligenceColors.electricTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeController = context.watch<ThemeController>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(IntelligenceSpacing.standard),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header - centered
            Center(child: ProfileHeader(user: user)),
            SizedBox(height: IntelligenceSpacing.spacious),

            // Usage Stats
            if (user?.usage != null) ...[
              UsageSection(user: user!),
              SizedBox(height: IntelligenceSpacing.spacious),
            ],

            // Account Settings
            SettingsCard(
              title: 'ACCOUNT SETTINGS',
              icon: Icons.settings_rounded,
              iconColor: IntelligenceColors.electricTeal,
              children: [
                ActionTile(
                    icon: Icons.edit_rounded,
                    title: 'Edit Name',
                    onTap: () => _showEditNameDialog(user?.name ?? '')),
                Divider(color: IntelligenceColors.slateGrey, height: 1),
                ActionTile(
                    icon: Icons.lock_outlined,
                    title: 'Change Password',
                    onTap: _showChangePasswordDialog),
                Divider(color: IntelligenceColors.slateGrey, height: 1),
                ActionTile(
                    icon: Icons.interests_rounded,
                    title: 'My Topics',
                    onTap: _openMyTopics),
                Divider(color: IntelligenceColors.slateGrey, height: 1),
                ActionTile(
                    icon: Icons.workspace_premium_rounded,
                    title: 'Redeem promo code',
                    onTap: () => showPromoCodeDialog(context)),
              ],
            ),
            SizedBox(height: IntelligenceSpacing.standard),

            // Appearance
            SettingsCard(
              title: 'APPEARANCE',
              icon: Icons.palette_outlined,
              iconColor: IntelligenceColors.cyberBlue,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: IntelligenceSpacing.standard,
                    vertical: IntelligenceSpacing.compact,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        themeController.isDark
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: IntelligenceColors.secondaryTextGrey,
                        size: 20,
                      ),
                      SizedBox(width: IntelligenceSpacing.standard),
                      Expanded(
                        child: Text(
                          'Dark mode',
                          style: AppTheme.textTheme.titleMedium,
                        ),
                      ),
                      Switch(
                        value: themeController.isDark,
                        onChanged: (v) => themeController.setDark(v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: IntelligenceSpacing.standard),

            // Account Info
            InfoCard(
              title: 'ACCOUNT INFO',
              icon: Icons.info_outline_rounded,
              iconColor: IntelligenceColors.cyberBlue,
              children: [
                InfoRow(label: 'Email', value: user?.email ?? '-'),
                InfoRow(
                    label: 'Verified',
                    value: user?.isAccountVerified == true ? 'Yes ✓' : 'No'),
                InfoRow(
                    label: 'Member Since', value: _formatDate(user?.createdAt)),
              ],
            ),
            SizedBox(height: IntelligenceSpacing.standard),

            // Subscription
            SubscriptionCard(
              user: user,
              onManage: () => _handleUpgrade(context, user),
              onUpgrade: () => _handleUpgrade(context, user),
              formatDate: _formatDate,
            ),
            SizedBox(height: IntelligenceSpacing.standard),

            // Security Settings
            SecurityCard(
              user: user,
              onToggleLoginNotifications: (val) =>
                  _updateSecurity('loginNotifications', val),
            ),
            SizedBox(height: IntelligenceSpacing.standard),

            // Logout Button
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: IntelligenceColors.surfaceDark,
                border: Border.all(
                  color: IntelligenceColors.crimsonSpike.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _handleLogout,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: IntelligenceSpacing.standard,
                      horizontal: IntelligenceSpacing.standard,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: IntelligenceColors.crimsonSpike,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'LOGOUT',
                          style: AppTheme.textTheme.labelMedium?.copyWith(
                            color: IntelligenceColors.crimsonSpike,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 40),
            SizedBox(height: IntelligenceSpacing.spacious * 2),
          ],
        ),
      ),
    );
  }
}
