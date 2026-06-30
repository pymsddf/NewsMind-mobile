import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/intelligence_design_system.dart';
import '../config/topics.dart';
import '../models/news_article_model.dart';
import '../services/news_service.dart';
import '../widgets/newsmind_brand_title.dart';
import '../widgets/markdown_text.dart';

/// In-app reader for an aggregated news article — opened when a feed/search card
/// is tapped (instead of bouncing the user out to the source site). The full
/// article body is fetched + cached server-side on first read.
class NewsArticleReaderScreen extends StatefulWidget {
  final NewsArticle article;

  const NewsArticleReaderScreen({super.key, required this.article});

  @override
  State<NewsArticleReaderScreen> createState() =>
      _NewsArticleReaderScreenState();
}

class _NewsArticleReaderScreenState extends State<NewsArticleReaderScreen> {
  String _content = '';
  bool _loading = true;

  NewsArticle get _a => widget.article;

  @override
  void initState() {
    super.initState();
    if (_a.content.isNotEmpty) {
      _content = _a.content;
      _loading = false;
    } else {
      _loadContent();
    }
  }

  Future<void> _loadContent() async {
    final c = await NewsService.getArticleContent(_a.id);
    if (!mounted) return;
    setState(() {
      _content = c.isNotEmpty ? c : _a.summary;
      _loading = false;
    });
  }

  String _meta() {
    final diff = DateTime.now().difference(_a.publishedAt);
    final t = diff.inMinutes < 60
        ? '${diff.inMinutes}m ago'
        : diff.inHours < 24
            ? '${diff.inHours}h ago'
            : '${diff.inDays}d ago';
    return [if (_a.sourceName.isNotEmpty) _a.sourceName, t].join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.pop(context),
        ),
        title: NewsMindBrandTitle(),
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: AppColors.ink),
            onPressed: () => Share.share('${_a.title}\n\n${_a.sourceUrl}',
                subject: _a.title),
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          if (_a.imageUrl != null)
            CachedNetworkImage(
              imageUrl: _a.displayImageUrl!,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              placeholder: (_, __) =>
                  Container(height: 220, color: AppColors.paperAlt),
              errorWidget: (_, __, ___) => Container(
                height: 220,
                color: AppColors.paperAlt,
                child: Icon(
                    Topics.byId(_a.topic)?.icon ?? Icons.article_rounded,
                    color: AppColors.muted,
                    size: 40),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.indigoSoft,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        _a.topic.toUpperCase(),
                        style: AppType.ui(
                          size: 10,
                          weight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: 0.2,
                        ).copyWith(fontStyle: FontStyle.italic),
                      ),
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(_meta(),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.data(size: 11, color: AppColors.muted)),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.md),
                Text(
                  _a.title,
                  style: AppType.headline(
                    size: 26,
                    weight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: AppSpace.lg),
                _buildBody(),
                SizedBox(height: AppSpace.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_content.isNotEmpty) return MarkdownText(_content);
    // Still loading the full body — show the summary so there's something to read.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_a.summary.isNotEmpty)
          Text(_a.summary,
              style: AppType.display(
                  size: 16.5, color: AppColors.ink, height: 1.6)),
        if (_loading) ...[
          SizedBox(height: AppSpace.lg),
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.indigo),
              ),
              SizedBox(width: AppSpace.sm),
              Text('Loading full article…',
                  style: AppType.ui(size: 13, color: AppColors.muted)),
            ],
          ),
        ],
      ],
    );
  }
}
