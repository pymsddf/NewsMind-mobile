import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// Verdict Desk buttons — solid, softly-rounded, editorial.
///
/// primary   → indigo (brand action)
/// critical  → redline (destructive / false)
/// warning   → caution amber
/// outline   → ink text, hairline border
/// text      → indigo text link
/// criticalAlert → caution→redline wash (high-attention only)
class VectorButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final VectorButtonType type;
  final bool isLoading;
  final IconData? icon;
  final bool fullWidth;

  const VectorButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = VectorButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = _buildButton();
    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }

  static const _padding =
      EdgeInsets.symmetric(horizontal: AppSpace.lg, vertical: 15);
  static final _shape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md));
  static final _textStyle =
      AppType.ui(size: 15, weight: FontWeight.w700, letterSpacing: 0.2);

  Widget _buildButton() {
    switch (type) {
      case VectorButtonType.primary:
        return _solid(AppColors.indigo, AppColors.onAccent);
      case VectorButtonType.critical:
        return _solid(AppColors.redline, AppColors.onAccent);
      case VectorButtonType.warning:
        return _solid(AppColors.caution, AppColors.onAccent);
      case VectorButtonType.outline:
        return _outline();
      case VectorButtonType.text:
        return _text();
      case VectorButtonType.criticalAlert:
        return _gradient();
    }
  }

  Widget _solid(Color bg, Color fg) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: AppColors.rule,
        disabledForegroundColor: AppColors.muted,
        elevation: 0,
        padding: _padding,
        shape: _shape,
        textStyle: _textStyle,
      ),
      child: _content(fg),
    );
  }

  Widget _outline() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: BorderSide(color: AppColors.ruleStrong, width: 1),
        padding: _padding,
        shape: _shape,
        textStyle: _textStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      child: _content(AppColors.ink),
    );
  }

  Widget _text() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.indigo,
        padding: EdgeInsets.symmetric(
            horizontal: AppSpace.md, vertical: AppSpace.sm),
        textStyle: _textStyle.copyWith(fontWeight: FontWeight.w600),
      ),
      child: _content(AppColors.indigo),
    );
  }

  Widget _gradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.caution, AppColors.redline],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.onAccent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: _padding,
          shape: _shape,
          textStyle: _textStyle,
        ),
        child: _content(AppColors.onAccent),
      ),
    );
  }

  Widget _content(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          SizedBox(width: AppSpace.sm),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}

enum VectorButtonType {
  primary,
  critical,
  warning,
  outline,
  text,
  criticalAlert,
}

/// Floating Action Button — softly rounded.
class VectorFAB extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final VectorButtonType type;

  const VectorFAB({
    super.key,
    this.onPressed,
    this.icon = Icons.add,
    this.type = VectorButtonType.primary,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      backgroundColor: _bg(),
      foregroundColor: _fg(),
      child: Icon(icon, size: 24),
    );
  }

  Color _bg() {
    switch (type) {
      case VectorButtonType.primary:
        return AppColors.indigo;
      case VectorButtonType.critical:
      case VectorButtonType.criticalAlert:
        return AppColors.redline;
      case VectorButtonType.warning:
        return AppColors.caution;
      case VectorButtonType.outline:
      case VectorButtonType.text:
        return AppColors.surface;
    }
  }

  Color _fg() {
    switch (type) {
      case VectorButtonType.outline:
      case VectorButtonType.text:
        return AppColors.ink;
      default:
        return AppColors.onAccent;
    }
  }
}
