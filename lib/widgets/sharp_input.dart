import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';

/// Form field — clean white well on paper, hairline border that warms to
/// indigo on focus. Softly rounded (Verdict Desk).
class SharpInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final int maxLines;
  final bool enabled;
  final FocusNode? focusNode;

  const SharpInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.maxLines = 1,
    this.enabled = true,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpace.sm),
            child: Text(
              label!.toUpperCase(),
              style: AppType.ui(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.graphite,
                letterSpacing: 1.0,
              ),
            ),
          ),
        Focus(
          child: Builder(
            builder: (context) {
              final isFocused = Focus.of(context).hasFocus;
              return AnimatedContainer(
                duration: Duration(milliseconds: 160),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isFocused ? AppColors.indigo : AppColors.ruleStrong,
                    width: isFocused ? 1.6 : 1,
                  ),
                ),
                child: TextFormField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  validator: validator,
                  onChanged: onChanged,
                  maxLines: maxLines,
                  enabled: enabled,
                  focusNode: focusNode,
                  cursorColor: AppColors.indigo,
                  style: AppType.ui(size: 15, color: AppColors.ink),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppType.ui(size: 15, color: AppColors.muted),
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: AppSpace.md, vertical: 14),
                    prefixIcon: prefixIcon != null
                        ? Icon(prefixIcon,
                            size: 20,
                            color: isFocused
                                ? AppColors.indigo
                                : AppColors.muted)
                        : null,
                    suffixIcon: suffixIcon != null
                        ? IconButton(
                            icon: Icon(suffixIcon,
                                size: 20,
                                color: isFocused
                                    ? AppColors.indigo
                                    : AppColors.muted),
                            onPressed: onSuffixTap,
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Mono input — for numeric/technical data entry.
class MonoInput extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool enabled;

  const MonoInput({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null)
          Padding(
            padding: EdgeInsets.only(bottom: AppSpace.sm),
            child: Text(
              label!.toUpperCase(),
              style: AppType.ui(
                size: 11,
                weight: FontWeight.w600,
                color: AppColors.graphite,
                letterSpacing: 1.0,
              ),
            ),
          ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          enabled: enabled,
          cursorColor: AppColors.indigo,
          style: AppType.data(size: 14, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppType.data(size: 14, color: AppColors.muted),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.all(AppSpace.md),
            border: b(AppColors.ruleStrong, 1),
            enabledBorder: b(AppColors.ruleStrong, 1),
            focusedBorder: b(AppColors.indigo, 1.6),
          ),
        ),
      ],
    );
  }
}

/// Selection item — option row with marker, used for tone/style pickers.
class SelectionItem extends StatelessWidget {
  final int number;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectionItem({
    super.key,
    required this.number,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 140),
        padding: EdgeInsets.all(AppSpace.md),
        margin: EdgeInsets.only(bottom: AppSpace.sm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.indigoSoft : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.indigo : AppColors.rule,
            width: isSelected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.indigo : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: AppColors.indigo, width: 1.4),
              ),
              child: Text(
                '$number',
                style: AppType.data(
                  size: 12,
                  weight: FontWeight.w600,
                  color: isSelected ? AppColors.onAccent : AppColors.indigo,
                ),
              ),
            ),
            SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                label,
                style: AppType.ui(
                  size: 14,
                  weight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.ink : AppColors.graphite,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_rounded,
                  color: AppColors.indigo, size: 20),
          ],
        ),
      ),
    );
  }
}
