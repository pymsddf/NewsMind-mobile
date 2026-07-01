import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/subscription_service.dart';
import '../theme/intelligence_design_system.dart';
import 'sharp_input.dart';

/// Prompt for an admin-issued promo code and redeem it to activate Pro.
/// Returns true if Pro was activated. Refreshes the signed-in user on success.
Future<bool> showPromoCodeDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => const _PromoCodeDialog(),
  );
  return result ?? false;
}

class _PromoCodeDialog extends StatefulWidget {
  const _PromoCodeDialog();

  @override
  State<_PromoCodeDialog> createState() => _PromoCodeDialogState();
}

class _PromoCodeDialogState extends State<_PromoCodeDialog> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _redeem() async {
    final code = _controller.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Enter a promo code');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await SubscriptionService.redeemPromoCode(code);
    if (!mounted) return;

    if (res['success'] == true) {
      // Pull fresh user state so `pro` is reflected everywhere immediately.
      await context.read<AuthProvider>().refreshUser();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(res['message']?.toString() ?? 'Pro activated.',
            style: AppType.ui(size: 13, color: AppColors.onAccent)),
        backgroundColor: AppColors.verified,
        behavior: SnackBarBehavior.floating,
      ));
      Navigator.of(context).pop(true);
    } else {
      setState(() {
        _loading = false;
        _error = res['message']?.toString() ?? 'Invalid promo code';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      title: Row(
        children: [
          Icon(Icons.workspace_premium_rounded,
              color: AppColors.redline, size: 24),
          SizedBox(width: AppSpace.sm),
          Text('Activate Pro',
              style: AppType.headline(
                  size: 20, weight: FontWeight.w700, color: AppColors.ink)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Enter your promo code to unlock Pro.',
            style: AppType.display(
                size: 14, color: AppColors.graphite, height: 1.4),
          ),
          SizedBox(height: AppSpace.md),
          SharpInput(
            label: 'Promo code',
            hint: 'e.g. NOTIZZ-PRO',
            controller: _controller,
            enabled: !_loading,
          ),
          if (_error != null) ...[
            SizedBox(height: AppSpace.sm),
            Text(_error!,
                style: AppType.ui(size: 12.5, color: AppColors.redline)),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _loading ? null : () => Navigator.of(context).pop(false),
          child: Text('Cancel',
              style: AppType.ui(size: 14, color: AppColors.graphite)),
        ),
        ElevatedButton(
          onPressed: _loading ? null : _redeem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.onAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md)),
          ),
          child: _loading
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.onAccent),
                )
              : Text('Redeem',
                  style: AppType.ui(size: 14, weight: FontWeight.w700)),
        ),
      ],
    );
  }
}
