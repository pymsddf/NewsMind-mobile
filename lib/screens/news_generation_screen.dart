import 'package:flutter/material.dart';
import '../models/article_model.dart';
import '../services/news_service.dart';
import '../theme/app_theme.dart';
import '../widgets/vector_button.dart';
import '../widgets/vector_card.dart';
import '../widgets/feedback_rating.dart';
import '../widgets/news_generation_widgets.dart';
import '../models/verification_model.dart';
import '../models/bias_model.dart';
import '../services/verification_service.dart';
import '../services/bias_service.dart';
import '../utils/upgrade_helper.dart';
import '../utils/error_text.dart';
import '../widgets/notizz_brand_title.dart';

class NewsGenerationScreen extends StatefulWidget {
  final String? initialTopic;
  final ArticleModel? initialArticle;
  final void Function(int, {String? text, dynamic result})? onTabSwitch;
  final bool showHeader;

  const NewsGenerationScreen({
    super.key,
    this.initialTopic,
    this.initialArticle,
    this.onTabSwitch,
    this.showHeader = true,
  });

  @override
  State<NewsGenerationScreen> createState() => NewsGenerationScreenState();
}

class NewsGenerationScreenState extends State<NewsGenerationScreen> {
  final _topicController = TextEditingController();
  final _sourcesController = TextEditingController();
  final _scrollController = ScrollController();

  String _style = 'news';
  String _length = 'medium';
  String _tone = 'neutral';
  bool _isGenerating = false;
  bool _isVerifying = false;
  bool _isBiasAnalyzing = false;
  bool _showParams = true;
  ArticleModel? _article;
  VerificationModel? _verificationResult;
  BiasModel? _biasResult;

  final _styles = ['news', 'analysis', 'interview', 'listicle', 'editorial'];
  final _lengths = ['short', 'medium', 'long', 'extended'];
  final _tones = ['neutral', 'formal', 'conversational', 'investigative'];

  @override
  void initState() {
    super.initState();
    if (widget.initialTopic != null) {
      _topicController.text = widget.initialTopic!;
    }
    if (widget.initialArticle != null) {
      _article = widget.initialArticle;
      _showParams = false;
    }
  }

  void prefill(String topic, ArticleModel article) {
    setState(() {
      _topicController.text = topic;
      _article = article;
      _showParams = false;
    });
    // Scroll to results
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _generateArticle() async {
    if (_topicController.text.trim().isEmpty) {
      _showSnack('Please enter a topic');
      return;
    }

    setState(() {
      _isGenerating = true;
      _article = null;
      _showParams = false;
    });

    try {
      final article = await NewsService.generateArticle(
        topic: _topicController.text.trim(),
        style: _style,
        length: _length,
        tone: _tone,
        sources: _sourcesController.text.trim(),
      );

      setState(() {
        _article = article;
        _isGenerating = false;
      });
    } catch (e) {
      setState(() => _isGenerating = false);
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
      featureLabel: 'news generation',
    );
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(),
      ),
    );
  }

  Future<void> _translateArticle() async {
    if (_article == null || _article!.content == null) return;

    final languages = await NewsService.getTranslateLanguages();
    if (!mounted) return;
    if (languages.isEmpty) {
      _showSnack('Could not load languages. Please try again.');
      return;
    }
    final lang = await _showLanguageDialog(languages);
    if (lang == null) return;

    setState(() => _isGenerating = true);
    try {
      final response = await NewsService.translate(
        content: _article!.content!,
        targetLanguage: lang,
      );
      final translatedContent = response['translated_content'] ??
          response['translated_text'] ??
          _article!.content;
      setState(() {
        _article = _article!.copyWith(content: translatedContent);
        _isGenerating = false;
      });
      _showSnack('Translated to ${lang.toUpperCase()}', isError: false);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isGenerating = false);
      if (UpgradeHelper.isUsageLimitError(e)) {
        _showUpgradeDialog();
      } else {
        _showSnack(friendlyError(e));
      }
    }
  }

  Future<void> _verifyContent() async {
    if (_article == null || _article!.content == null) return;

    setState(() {
      _isVerifying = true;
      _verificationResult = null;
    });

    try {
      final result =
          await VerificationService.verifyContent(_article!.content!);
      if (!mounted) return;
      setState(() {
        _verificationResult = result;
        _isVerifying = false;
      });
      // Scroll to results
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      if (UpgradeHelper.isUsageLimitError(e)) {
        _showUpgradeDialog();
      } else {
        _showSnack(friendlyError(e));
      }
    }
  }

  Future<void> _analyzeBias() async {
    if (_article == null || _article!.content == null) return;

    setState(() {
      _isBiasAnalyzing = true;
      _biasResult = null;
    });

    try {
      final result = await BiasService.analyzeBias(text: _article!.content!);
      if (!mounted) return;
      setState(() {
        _biasResult = result;
        _isBiasAnalyzing = false;
      });
      // Scroll to results
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isBiasAnalyzing = false);
      if (UpgradeHelper.isUsageLimitError(e)) {
        _showUpgradeDialog();
      } else {
        _showSnack(friendlyError(e));
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// [languages] comes from the backend and is engine-aware (LibreTranslate ⇒
  /// only its supported Indian languages + Urdu; LLM ⇒ full Indian list).
  /// Returns the chosen language NAME (the backend maps names → ISO for Libre).
  Future<String?> _showLanguageDialog(List<Map<String, String>> languages) {
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: Text('Select Language',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: languages.length,
            itemBuilder: (context, index) {
              final name = languages[index]['name'] ?? '';
              return ListTile(
                title: Text(name, style: TextStyle(color: AppTheme.textPrimary)),
                onTap: () => Navigator.pop(ctx, name),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _topicController.dispose();
    _sourcesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          if (widget.showHeader)
            const SliverAppBar(
              floating: true,
              title: NotizzBrandTitle(),
              automaticallyImplyLeading: false,
            ),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Topic Input
                  VectorCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                                color: AppTheme.primaryColor, size: 20),
                            SizedBox(width: 8),
                            Text('Topic',
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary)),
                          ],
                        ),
                        SizedBox(height: 12),
                        TextFormField(
                          controller: _topicController,
                          maxLines: 3,
                          minLines: 2,
                          style: TextStyle(color: AppTheme.textPrimary),
                          decoration: InputDecoration(
                            hintText: 'Enter the news topic or headline...',
                            border: InputBorder.none,
                            filled: true,
                            fillColor: AppTheme.background,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),

                  // Collapsible Parameters
                  VectorCard(
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () =>
                              setState(() => _showParams = !_showParams),
                          child: Row(
                            children: [
                              Icon(Icons.tune_rounded,
                                  color: AppTheme.accentColor, size: 20),
                              SizedBox(width: 8),
                              Text('Parameters',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary)),
                              Spacer(),
                              Icon(
                                _showParams
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppTheme.textMuted,
                              ),
                            ],
                          ),
                        ),
                        if (_showParams) ...[
                          SizedBox(height: 16),
                          GenerationDropdown(
                              label: 'Style',
                              value: _style,
                              items: _styles,
                              onChanged: (v) => setState(() => _style = v!)),
                          SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                  child: GenerationDropdown(
                                      label: 'Length',
                                      value: _length,
                                      items: _lengths,
                                      onChanged: (v) =>
                                          setState(() => _length = v!))),
                              SizedBox(width: 12),
                              Expanded(
                                  child: GenerationDropdown(
                                      label: 'Tone',
                                      value: _tone,
                                      items: _tones,
                                      onChanged: (v) =>
                                          setState(() => _tone = v!))),
                            ],
                          ),
                          SizedBox(height: 12),
                          TextFormField(
                            controller: _sourcesController,
                            style: TextStyle(color: AppTheme.textPrimary),
                            decoration: InputDecoration(
                              labelText: 'Sources (optional)',
                              hintText: 'Source URLs or references',
                              prefixIcon:
                                  Icon(Icons.link, color: AppTheme.textMuted),
                              filled: true,
                              fillColor: AppTheme.background,
                              labelStyle:
                                  TextStyle(color: AppTheme.textSecondary),
                              hintStyle: TextStyle(color: AppTheme.textMuted),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  // Generate Button
                  VectorButton(
                    fullWidth: true,
                    label: 'Generate Article',
                    icon: Icons.auto_awesome_rounded,
                    isLoading: _isGenerating,
                    onPressed: _generateArticle,
                  ),
                  SizedBox(height: 20),

                  // Loading Shimmer
                  if (_isGenerating) LoadingShimmer(),

                  // Article Result
                  if (_article != null) ...[
                    GeneratedArticleCard(
                      article: _article!,
                      style: _style,
                      tone: _tone,
                      onTranslate: _translateArticle,
                      onVerify: _verifyContent,
                      onAnalyzeBias: _analyzeBias,
                      onShowSnack: (msg) => _showSnack(msg, isError: false),
                    ),
                    if (_article!.historyId != null)
                      FeedbackRating(historyId: _article!.historyId!),
                  ],

                  // Verification Progress/Result
                  if (_isVerifying)
                    InlineLoading(
                        message: 'Verifying content...',
                        color: AppTheme.success),
                  if (_verificationResult != null) ...[
                    InlineVerificationResult(
                        verificationResult: _verificationResult!),
                    if (_verificationResult!.historyId != null)
                      FeedbackRating(
                          historyId: _verificationResult!.historyId!),
                  ],

                  // Bias Progress/Result
                  if (_isBiasAnalyzing)
                    InlineLoading(
                        message: 'Analyzing bias...', color: AppTheme.warning),
                  if (_biasResult != null) ...[
                    InlineBiasResult(biasResult: _biasResult!),
                    if (_biasResult!.historyId != null)
                      FeedbackRating(historyId: _biasResult!.historyId!),
                  ],

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
