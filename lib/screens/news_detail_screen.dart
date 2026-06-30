import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/subscription_model.dart';
import '../theme/app_theme.dart';
import '../widgets/vector_card.dart';
import '../services/news_service.dart';
import 'fact_checking_screen.dart';
import '../widgets/newsmind_brand_title.dart';
import '../utils/error_text.dart';

class NewsDetailScreen extends StatefulWidget {
  final GeneratedNews news;

  const NewsDetailScreen({super.key, required this.news});

  @override
  State<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends State<NewsDetailScreen> {
  late String _currentTitle;
  late String _currentContent;
  bool _isTranslating = false;

  final List<Map<String, String>> _languages = [
    {'code': 'English', 'label': 'English'},
    {'code': 'Hindi', 'label': 'Hindi (हिंदी)'},
    {'code': 'Bengali', 'label': 'Bengali (বাংলা)'},
    {'code': 'Tamil', 'label': 'Tamil (தமிழ்)'},
    {'code': 'Telugu', 'label': 'Telugu (తెలుగు)'},
    {'code': 'Marathi', 'label': 'Marathi (मराठी)'},
    {'code': 'Gujarati', 'label': 'Gujarati (ગુજરાતી)'},
    {'code': 'Kannada', 'label': 'Kannada (కನ್ನಡ)'},
    {'code': 'Malayalam', 'label': 'Malayalam (മലയാളം)'},
    {'code': 'Punjabi', 'label': 'Punjabi (ਪੰਜਾਬੀ)'},
    {'code': 'Odia', 'label': 'Odia (ଓଡਿਆ)'},
    {'code': 'Urdu', 'label': 'Urdu (اردو)'},
    {'code': 'French', 'label': 'French (Français)'},
    {'code': 'Spanish', 'label': 'Spanish (Español)'},
    {'code': 'German', 'label': 'German (Deutsch)'},
    {'code': 'Arabic', 'label': 'Arabic (العربية)'},
    {'code': 'Chinese', 'label': 'Chinese (中文)'},
    {'code': 'Japanese', 'label': 'Japanese (日本語)'},
  ];

  @override
  void initState() {
    super.initState();
    _currentTitle = widget.news.title;
    _currentContent = widget.news.content;
  }

  void _showTranslationDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: AppTheme.surface,
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.textMuted.withValues(alpha: 0.3),
                ),
              ),
              Text(
                'Select Language',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _languages.length,
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    return ListTile(
                      title: Text(lang['label']!,
                          style:
                              TextStyle(color: AppTheme.textSecondary)),
                      trailing: Icon(Icons.chevron_right,
                          color: AppTheme.textMuted),
                      onTap: () {
                        Navigator.pop(context);
                        _translateArticle(lang['code']!);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _translateArticle(String language) async {
    setState(() {
      _isTranslating = true;
    });

    try {
      final result = await NewsService.translate(
        content: _currentContent,
        targetLanguage: language,
      );

      if (mounted) {
        setState(() {
          _currentContent = result['translated_content'] ?? _currentContent;
          // Optionally translate title if provided by backend, usually it returns the full transformed text
          _isTranslating = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translated to $language'),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(friendlyError(e)),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: NewsMindBrandTitle(),
        backgroundColor: AppTheme.surface.withValues(alpha: 0.8),
        elevation: 0,
        iconTheme: IconThemeData(color: AppTheme.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.copy_rounded, color: AppTheme.textMuted),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _currentContent));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Copied to clipboard!'),
                  backgroundColor: AppTheme.success,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share_rounded, color: AppTheme.textMuted),
            onPressed: () {
              Share.share(_currentContent, subject: _currentTitle);
            },
          ),
          SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              children: [
                VectorCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tags
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome,
                                    color: Colors.white, size: 14),
                                SizedBox(width: 4),
                                Text('AI Generated',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceLight,
                              ),
                              child: Text(
                                widget.news.topic.isNotEmpty
                                    ? widget.news.topic
                                    : 'Generated',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Title
                      Text(
                        _currentTitle.isNotEmpty
                            ? _currentTitle
                            : 'Untitled Article',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                      SizedBox(height: 12),

                      // Meta Data
                      Row(
                        children: [
                          Icon(Icons.calendar_today_rounded,
                              size: 14, color: AppTheme.textMuted),
                          SizedBox(width: 4),
                          Text(
                            '${widget.news.generatedAt.day}/${widget.news.generatedAt.month}/${widget.news.generatedAt.year}',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                          Spacer(),
                          Text(
                            '${widget.news.wordCount} words',
                            style: TextStyle(
                                color: AppTheme.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(color: AppTheme.borderColor),
                      SizedBox(height: 16),

                      // Content
                      Text(
                        _currentContent,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 16,
                          height: 1.7,
                        ),
                      ),

                      if (widget.news.sources.isNotEmpty) ...[
                        SizedBox(height: 24),
                        Text('Sources',
                            style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        ...widget.news.sources.map((s) => Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.link,
                                      size: 14, color: AppTheme.accentColor),
                                  SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      s.title.isNotEmpty ? s.title : s.url,
                                      style: TextStyle(
                                          color: AppTheme.accentColor,
                                          fontSize: 13,
                                          decoration: TextDecoration.underline),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],

                      SizedBox(height: 32),
                      Divider(color: AppTheme.borderColor),
                      SizedBox(height: 16),

                      // Action Buttons
                      Text(
                        'AI Tools',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.g_translate_rounded,
                              label: 'Translate',
                              onPressed: _showTranslationDialog,
                              color: Colors.blue,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.verified_user_rounded,
                              label: 'Verify',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FactCheckingScreen(
                                        initialText: _currentContent),
                                  ),
                                );
                              },
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
          if (_isTranslating)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: VectorCard(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryColor),
                      SizedBox(height: 16),
                      Text('Translating Article...',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                  color: color, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
