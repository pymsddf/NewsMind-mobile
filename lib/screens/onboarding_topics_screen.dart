import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../theme/intelligence_design_system.dart';
import '../config/topics.dart';
import '../providers/auth_provider.dart';
import '../services/news_service.dart';
import '../widgets/newsmind_brand_title.dart';
import '../utils/upgrade_helper.dart';

/// Topic picker. Two modes:
///  - onboarding (default): first-login pick that opens the app on save.
///  - edit ([isEdit] = true): reached from Profile → My Topics. Pre-selects the
///    current topics. Non-Pro users get one free change; after that, saving
///    requires Pro.
class OnboardingTopicsScreen extends StatefulWidget {
  final bool isEdit;
  const OnboardingTopicsScreen({super.key, this.isEdit = false});

  @override
  State<OnboardingTopicsScreen> createState() => _OnboardingTopicsScreenState();
}

class _OnboardingTopicsScreenState extends State<OnboardingTopicsScreen> {
  final Set<String> _selected = {};
  bool _saving = false;
  bool _loading = false;
  // Edit-mode gate: whether the user may still change topics without Pro.
  bool _canEditFree = true;
  bool _pro = false;

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) _loadCurrent();
  }

  Future<void> _loadCurrent() async {
    setState(() => _loading = true);
    final status = await NewsService.getTopicsStatus();
    if (!mounted) return;
    setState(() {
      _selected
        ..clear()
        ..addAll(List<String>.from(status['topics'] as List));
      _canEditFree = status['canEditFree'] == true;
      _pro = status['pro'] == true;
      _loading = false;
    });
  }

  void _toggle(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
      } else if (_selected.length < Topics.maxSelection) {
        _selected.add(id);
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text('Pick up to ${Topics.maxSelection} topics',
                style: AppType.ui(size: 13, color: AppColors.onAccent)),
            backgroundColor: AppColors.ink,
            behavior: SnackBarBehavior.floating,
          ));
      }
    });
  }

  void _snack(String msg, {bool error = true}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:
          Text(msg, style: AppType.ui(size: 13, color: AppColors.onAccent)),
      backgroundColor: error ? AppColors.redline : AppColors.verified,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _continue() async {
    if (_selected.isEmpty || _saving) return;

    if (widget.isEdit) {
      await _saveEdit();
      return;
    }

    // Onboarding flow: initial pick opens the app.
    setState(() => _saving = true);
    final ok = await NewsService.saveTopics(_selected.toList());
    if (!mounted) return;
    if (ok) {
      context.read<AuthProvider>().markOnboarded();
      context.go('/home');
    } else {
      setState(() => _saving = false);
      _snack('Could not save topics. Try again.');
    }
  }

  Future<void> _saveEdit() async {
    // Already out of free changes → straight to the upgrade prompt.
    if (!_canEditFree) {
      await UpgradeHelper.showUpgradeRequiredDialog(context,
          featureLabel: 'changing your topics again');
      return;
    }

    setState(() => _saving = true);
    final res = await NewsService.updateTopics(_selected.toList());
    if (!mounted) return;
    setState(() => _saving = false);

    if (res['success'] == true) {
      _snack('Topics updated.', error: false);
      Navigator.of(context).pop(true); // signal the caller to refresh
    } else if (res['requiresPro'] == true) {
      setState(() => _canEditFree = false);
      await UpgradeHelper.showUpgradeRequiredDialog(context,
          featureLabel: 'changing your topics again');
    } else {
      _snack(res['message']?.toString() ?? 'Could not save topics. Try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpace.md, AppSpace.lg, AppSpace.md, AppSpace.sm),
              child: Row(
                children: [
                  if (widget.isEdit)
                    Padding(
                      padding: EdgeInsets.only(right: AppSpace.xs),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Icon(Icons.arrow_back_rounded,
                            color: AppColors.ink, size: 24),
                      ),
                    ),
                  NewsMindBrandTitle(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                  AppSpace.md, AppSpace.sm, AppSpace.md, AppSpace.xs),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: widget.isEdit ? 'Edit your ' : 'Choose your ',
                    style: AppType.headline(
                        size: 28,
                        weight: FontWeight.w800,
                        color: AppColors.ink,
                        height: 1.1,
                        letterSpacing: -0.6),
                  ),
                  TextSpan(
                    text: 'topics',
                    style: AppType.headline(
                        size: 28,
                        weight: FontWeight.w800,
                        color: AppColors.redline,
                        fontStyle: FontStyle.italic,
                        height: 1.1,
                        letterSpacing: -0.6),
                  ),
                ]),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpace.md),
              child: Text(
                'Pick up to ${Topics.maxSelection}. Your daily feed is built from these.',
                style: AppType.display(
                    size: 15, color: AppColors.graphite, height: 1.5),
              ),
            ),
            if (widget.isEdit && !_loading) _buildEditNotice(),
            SizedBox(height: AppSpace.md),
            if (_loading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.indigo),
                ),
              )
            else
              Expanded(
                child: GridView.count(
                  padding: EdgeInsets.fromLTRB(
                      AppSpace.md, 0, AppSpace.md, AppSpace.md),
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpace.sm + 4,
                  crossAxisSpacing: AppSpace.sm + 4,
                  childAspectRatio: 1.5,
                  children: Topics.all.map(_buildTopicCard).toList(),
                ),
              ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard(NewsTopic t) {
    final selected = _selected.contains(t.id);
    return GestureDetector(
      onTap: () => _toggle(t.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(AppSpace.md),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.rule,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(t.icon,
                    color: selected ? AppColors.onAccent : AppColors.graphite,
                    size: 24),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.onAccent, size: 20),
              ],
            ),
            Text(
              t.label,
              style: AppType.headline(
                size: 18,
                weight: FontWeight.w700,
                color: selected ? AppColors.onAccent : AppColors.ink,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final count = _selected.length;
    final canContinue = count > 0 && !_saving;
    return Container(
      padding: EdgeInsets.fromLTRB(
          AppSpace.md, AppSpace.sm, AppSpace.md, AppSpace.md),
      decoration: BoxDecoration(
        color: AppColors.paper,
        border: Border(top: BorderSide(color: AppColors.rule, width: 1)),
      ),
      child: Row(
        children: [
          Text(
            '$count / ${Topics.maxSelection} selected',
            style: AppType.data(
                size: 12, color: AppColors.muted, letterSpacing: 0.3),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: canContinue ? _continue : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.onAccent,
              disabledBackgroundColor: AppColors.ruleStrong,
              padding: EdgeInsets.symmetric(
                  horizontal: AppSpace.xl, vertical: AppSpace.md),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
            child: _saving
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.onAccent),
                  )
                : Text(
                    !widget.isEdit
                        ? 'Continue'
                        : (_canEditFree ? 'Save' : 'Upgrade to Pro'),
                    style: AppType.ui(size: 15, weight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  /// Edit-mode banner explaining the one-free-change rule / Pro state.
  Widget _buildEditNotice() {
    final (String text, Color fg, IconData icon) = _pro
        ? (
            'Pro: unlimited topic changes.',
            AppColors.verified,
            Icons.workspace_premium_rounded
          )
        : _canEditFree
            ? (
                'This is your one free change. Further changes need Pro.',
                AppColors.caution,
                Icons.info_outline_rounded
              )
            : (
                'You\'ve used your free change. Upgrade to Pro to change topics.',
                AppColors.redline,
                Icons.lock_outline_rounded
              );
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpace.md, AppSpace.sm, AppSpace.md, 0),
      child: Container(
        padding: EdgeInsets.all(AppSpace.sm + 2),
        decoration: BoxDecoration(
          color: fg.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: fg.withValues(alpha: 0.35), width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: fg, size: 18),
            SizedBox(width: AppSpace.sm),
            Expanded(
              child: Text(text,
                  style: AppType.ui(
                      size: 12.5, color: fg, weight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
