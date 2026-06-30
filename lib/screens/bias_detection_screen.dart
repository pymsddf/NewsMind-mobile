import 'package:flutter/material.dart';
import '../services/bias_service.dart';
import '../models/bias_model.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/sharp_input.dart';
import '../widgets/vector_button.dart';
import '../widgets/vector_card.dart';
import '../widgets/feedback_rating.dart';
import '../widgets/data_visualization.dart';
import '../widgets/verdict_stamp.dart';
import '../widgets/news_generation_widgets.dart';
import '../utils/share_util.dart';
import '../utils/upgrade_helper.dart';
import '../utils/error_text.dart';
import '../widgets/newsmind_brand_title.dart';

/// Bias Detection — the analyst's grid: a lean spectrum, sensationalism level,
/// credibility dial and a per-dimension breakdown.
class BiasDetectionScreen extends StatefulWidget {
  final String? initialText;
  final BiasModel? initialResult;
  final bool showHeader;

  const BiasDetectionScreen({
    super.key,
    this.initialText,
    this.initialResult,
    this.showHeader = true,
  });

  @override
  State<BiasDetectionScreen> createState() => BiasDetectionScreenState();
}

class BiasDetectionScreenState extends State<BiasDetectionScreen> {
  final _textController = TextEditingController();
  final _urlController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAnalyzing = false;
  bool _useUrl = false;
  BiasModel? _result;

  @override
  void initState() {
    super.initState();
    if (widget.initialText != null && widget.initialText!.isNotEmpty) {
      if (widget.initialText!.startsWith('http')) {
        _urlController.text = widget.initialText!;
        _useUrl = true;
      } else {
        _textController.text = widget.initialText!;
        _useUrl = false;
      }
    }
    if (widget.initialResult != null) {
      _result = widget.initialResult;
    }
  }

  void prefill(String text, BiasModel? result) {
    setState(() {
      if (text.startsWith('http')) {
        _urlController.text = text;
        _useUrl = true;
      } else {
        _textController.text = text;
        _useUrl = false;
      }
      _result = result;
      _isAnalyzing = false;
    });

    if (result != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            400,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  Future<void> _analyze() async {
    final text = _textController.text.trim();
    final url = _urlController.text.trim();

    if (_useUrl && url.isEmpty) {
      _showSnack('Enter a URL to analyze');
      return;
    }
    if (!_useUrl && text.isEmpty) {
      _showSnack('Enter text to analyze');
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _result = null;
    });

    try {
      final result = await BiasService.analyzeBias(
        text: _useUrl ? null : text,
        url: _useUrl ? url : null,
      );
      setState(() {
        _result = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() => _isAnalyzing = false);
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
      featureLabel: 'bias detection',
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppType.ui(size: 13, color: AppColors.onAccent)),
        backgroundColor: AppColors.redline,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
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
              title: NewsMindBrandTitle(),
              actions: [
                if (_result != null)
                  IconButton(
                    icon: Icon(Icons.ios_share_rounded, color: AppColors.ink),
                    onPressed: () => ShareUtil.shareBiasAnalysis(_result!),
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
                    Text('Bias detection',
                        style: Theme.of(context).textTheme.headlineMedium),
                    SizedBox(height: 4),
                    Text(
                      'See where a piece leans, and how hard.',
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
                        DeskLabel('Source'),
                        SizedBox(height: AppSpace.md),
                        _buildToggle(),
                        SizedBox(height: AppSpace.md),
                        if (_useUrl)
                          SharpInput(
                            label: 'Article URL',
                            hint: 'https://example.com/article',
                            controller: _urlController,
                            keyboardType: TextInputType.url,
                          )
                        else
                          SharpInput(
                            label: 'Article text',
                            hint: 'Paste the article text to analyze…',
                            controller: _textController,
                            maxLines: 5,
                          ),
                        SizedBox(height: AppSpace.md),
                        VectorButton(
                          label: 'Analyze bias',
                          icon: Icons.travel_explore_rounded,
                          type: VectorButtonType.primary,
                          fullWidth: true,
                          isLoading: _isAnalyzing,
                          onPressed: _analyze,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: AppSpace.lg),
                  if (_result != null) ...[
                    _buildResultsGrid(),
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

  Widget _buildToggle() {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.paperAlt,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          _buildToggleButton('TEXT', !_useUrl, () => setState(() => _useUrl = false)),
          _buildToggleButton('URL', _useUrl, () => setState(() => _useUrl = true)),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 140),
          padding: EdgeInsets.symmetric(vertical: 9),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
            boxShadow: isSelected ? VectorCard.cardShadow : null,
          ),
          child: Text(
            label,
            style: AppType.ui(
              size: 12,
              weight: FontWeight.w700,
              color: isSelected ? AppColors.indigo : AppColors.muted,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsGrid() {
    final overallScore = _result!.overallBias.score / 100.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bias-level spectrum (UNBIASED · NEUTRAL · BIASED).
        VectorCard(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.all(AppSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeskLabel('Bias level'),
              SizedBox(height: AppSpace.lg),
              BiasSpectrum(
                  biasValue: (overallScore * 2 - 1).clamp(-1.0, 1.0)),
            ],
          ),
        ),
        // Bias Analysis card — score dial, top bias types, key findings, share.
        InlineBiasResult(biasResult: _result!),
      ],
    );
  }

}
