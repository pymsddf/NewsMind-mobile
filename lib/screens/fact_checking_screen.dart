import 'package:flutter/material.dart';
import '../services/verification_service.dart';
import '../models/verification_model.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/sharp_input.dart';
import '../widgets/vector_button.dart';
import '../widgets/vector_card.dart';
import '../widgets/data_visualization.dart';
import '../widgets/verdict_stamp.dart';
import '../widgets/feedback_rating.dart';
import '../utils/share_util.dart';
import '../utils/upgrade_helper.dart';
import '../utils/error_text.dart';
import '../widgets/notizz_brand_title.dart';
import '../widgets/brand_icon.dart';

/// Fact Verification — the verdict desk. A claim goes in; a stamped verdict,
/// credibility dial, editor's summary, findings and sources come back.
class FactCheckingScreen extends StatefulWidget {
  final String? initialText;
  final VerificationModel? initialResult;
  final bool showHeader;

  const FactCheckingScreen({
    super.key,
    this.initialText,
    this.initialResult,
    this.showHeader = true,
  });

  @override
  State<FactCheckingScreen> createState() => FactCheckingScreenState();
}

class FactCheckingScreenState extends State<FactCheckingScreen> {
  final _claimController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isVerifying = false;
  VerificationModel? _result;
  bool _showFlash = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      _claimController.text = widget.initialText!;
    }
    if (widget.initialResult != null) {
      _result = widget.initialResult;
    }
  }

  void prefill(String text, VerificationModel? result) {
    setState(() {
      _claimController.text = text;
      _result = result;
      _isVerifying = false;
    });

    if (result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            300,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _verify() async {
    if (_claimController.text.trim().isEmpty) {
      _showSnack('Enter a claim or article to verify');
      return;
    }

    setState(() {
      _isVerifying = true;
      _result = null;
    });

    try {
      final result =
          await VerificationService.verifyContent(_claimController.text.trim());

      setState(() => _showFlash = true);
      await Future.delayed(Duration(milliseconds: 300));

      setState(() {
        _result = result;
        _isVerifying = false;
        _showFlash = false;
      });
    } catch (e) {
      setState(() => _isVerifying = false);
      if (UpgradeHelper.isUsageLimitError(e)) {
        _showUpgradeDialog();
      } else {
        _showSnack(friendlyError(e));
      }
    }
  }

  Future<void> _showUpgradeDialog() async {
    await UpgradeHelper.showUpgradeRequiredDialog(
      context,
      featureLabel: 'fact checking',
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: AppType.ui(size: 13, color: AppColors.onAccent)),
        backgroundColor: isError ? AppColors.redline : AppColors.verified,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _claimController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if (widget.showHeader)
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.paper,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              title: NotizzBrandTitle(),
              actions: [
                if (_result != null)
                  IconButton(
                    icon: Icon(Icons.ios_share_rounded, color: AppColors.ink),
                    onPressed: () => ShareUtil.shareVerification(_result!),
                  ),
              ],
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!widget.showHeader) ...[
                    Text('Fact verification',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 4),
                    Text(
                      'Submit a claim and we’ll weigh the evidence.',
                      style: AppType.display(
                          size: 15, color: AppColors.graphite, height: 1.4),
                    ),
                    SizedBox(height: AppSpace.lg),
                  ],
                  VectorCard(
                    margin: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DeskLabel('The claim'),
                        SizedBox(height: AppSpace.md),
                        SharpInput(
                          hint: 'Paste the statement or article to check…',
                          controller: _claimController,
                          maxLines: 5,
                        ),
                        SizedBox(height: AppSpace.md),
                        VectorButton(
                          label: 'Weigh the evidence',
                          icon: Icons.balance_rounded,
                          type: VectorButtonType.primary,
                          fullWidth: true,
                          isLoading: _isVerifying,
                          onPressed: _verify,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpace.lg),
                  if (_result != null) ...[
                    _buildVerdictSection(),
                    if (_result!.historyId != null)
                      FeedbackRating(historyId: _result!.historyId!),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerdictSection() {
    final r = _result!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // The verdict: stamp + credibility dial
        VectorCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(AppSpace.lg),
          child: Column(
            children: [
              VerdictStamp(
                verdict: r.verdict,
                confidence: r.confidence,
                flash: _showFlash,
              ),
              SizedBox(height: AppSpace.lg),
              CredibilityArc(
                  score: (r.credibilityScore / 100).clamp(0, 1), size: 128),
            ],
          ),
        ),
        SizedBox(height: AppSpace.md),

        // Editor's summary
        if (r.summary.isNotEmpty)
          VectorCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeskLabel("Editor's summary"),
                SizedBox(height: AppSpace.md),
                Text(
                  r.summary,
                  style: AppType.display(
                      size: 16, color: AppColors.ink, height: 1.55),
                ),
              ],
            ),
          ),
        if (r.summary.isNotEmpty) const SizedBox(height: AppSpace.md),

        // Findings as proof-marks
        if (r.keyFindings.isNotEmpty)
          VectorCard(
            margin: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DeskLabel('Findings'),
                SizedBox(height: AppSpace.md),
                ...r.keyFindings.map((f) => ProofMark(
                      text: f,
                      color: Verdict.of(r.verdict).color,
                      icon: Icons.edit_note_rounded,
                    )),
              ],
            ),
          ),
        if (r.keyFindings.isNotEmpty) const SizedBox(height: AppSpace.md),

        // Sources
        VectorCard(
          margin: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeskLabel('Sources · ${r.evidence.length}',
                  accent: AppColors.neutral),
              SizedBox(height: AppSpace.md),
              ..._buildSourceList(),
            ],
          ),
        ),
        SizedBox(height: AppSpace.md),

        _buildSocialShareSection(),
      ],
    );
  }

  Widget _buildSocialShareSection() {
    return VectorCard(
      margin: EdgeInsets.zero,
      backgroundColor: AppColors.surfaceAlt,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DeskLabel('Share verdict'),
          SizedBox(height: AppSpace.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildShareIcon(
                  const BrandIcon(Brand.whatsapp, color: Color(0xFF25D366)),
                  'WhatsApp',
                  Color(0xFF25D366),
                  SharePlatform.whatsapp),
              _buildShareIcon(
                  const BrandIcon(Brand.linkedin, color: Color(0xFF0077B5)),
                  'LinkedIn',
                  Color(0xFF0077B5),
                  SharePlatform.linkedin),
              _buildShareIcon(
                  const BrandIcon(Brand.facebook, color: Color(0xFF1877F2)),
                  'Facebook',
                  Color(0xFF1877F2),
                  SharePlatform.facebook),
              _buildShareIcon(
                  Icon(Icons.share_rounded, color: AppColors.ink, size: 20),
                  'More',
                  AppColors.ink,
                  SharePlatform.more),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareIcon(
      Widget glyph, String label, Color color, SharePlatform platform) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: () => ShareUtil.shareVerificationTo(platform, _result!),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(11),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.12),
              ),
              child:
                  SizedBox(width: 20, height: 20, child: Center(child: glyph)),
            ),
            SizedBox(height: 6),
            Text(label,
                style: AppType.ui(
                    size: 10,
                    weight: FontWeight.w500,
                    color: AppColors.graphite)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSourceList() {
    final sources = _result!.evidence;
    if (sources.isEmpty) {
      return [
        Text('No sources cited.',
            style: AppType.display(size: 14, color: AppColors.muted)),
      ];
    }

    return sources.map((source) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpace.sm + 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.verifiedSoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.check_rounded,
                  size: 14, color: AppColors.verified),
            ),
            SizedBox(width: AppSpace.sm + 2),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(source.title,
                      style: AppType.display(
                          size: 14.5, color: AppColors.ink, height: 1.35)),
                  if ((source.domain ?? '').isNotEmpty)
                    Text(source.domain!.toUpperCase(),
                        style: AppType.data(
                            size: 10,
                            color: AppColors.muted,
                            letterSpacing: 0.5)),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}
