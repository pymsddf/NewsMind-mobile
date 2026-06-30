import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/intelligence_design_system.dart';
import '../config/topics.dart';
import '../models/news_article_model.dart';
import '../services/news_service.dart';
import 'news_article_reader_screen.dart';

/// Search across the whole news pool (all topics, including dismissed —
/// dismissals only hide from the passive feed). Debounced search-as-you-type,
/// compact result rows. Painted from [AppColors]/[AppType].
class NewsSearchScreen extends StatefulWidget {
  const NewsSearchScreen({super.key});

  @override
  State<NewsSearchScreen> createState() => _NewsSearchScreenState();
}

class _NewsSearchScreenState extends State<NewsSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<NewsArticle> _results = [];
  bool _loading = false;
  bool _searched = false;
  int _reqId = 0;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _results = [];
        _searched = false;
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);
    _debounce = Timer(const Duration(milliseconds: 400), () => _run(value));
  }

  Future<void> _run(String query) async {
    final id = ++_reqId;
    final results = await NewsService.search(query);
    if (!mounted || id != _reqId) return; // ignore stale responses
    setState(() {
      _results = results;
      _loading = false;
      _searched = true;
    });
  }

  void _open(NewsArticle a) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewsArticleReaderScreen(article: a)),
    );
  }

  String _meta(NewsArticle a) {
    final diff = DateTime.now().difference(a.publishedAt);
    final t = diff.inMinutes < 60
        ? '${diff.inMinutes}m'
        : diff.inHours < 24
            ? '${diff.inHours}h'
            : '${diff.inDays}d';
    return [if (a.sourceName.isNotEmpty) a.sourceName, a.topic, t]
        .join('  ·  ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      appBar: AppBar(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          onChanged: _onChanged,
          onSubmitted: (v) => _run(v),
          style: AppType.ui(size: 16, color: AppColors.ink),
          cursorColor: AppColors.redline,
          decoration: InputDecoration(
            hintText: 'Search the news…',
            hintStyle: AppType.ui(size: 16, color: AppColors.muted),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
        ),
        actions: [
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.graphite),
              onPressed: () {
                _controller.clear();
                _onChanged('');
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.rule),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.indigo, strokeWidth: 2),
      );
    }
    if (!_searched) {
      return _hint('Search across every topic',
          'Find any article in the news pool — even ones you swiped away.');
    }
    if (_results.isEmpty) {
      return _hint('No results', 'Try different keywords.');
    }
    return ListView.separated(
      padding: EdgeInsets.all(AppSpace.md),
      itemCount: _results.length,
      separatorBuilder: (_, __) =>
          Divider(height: AppSpace.lg, color: AppColors.rule),
      itemBuilder: (_, i) => _buildResult(_results[i]),
    );
  }

  Widget _buildResult(NewsArticle a) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _open(a),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: SizedBox(
              width: 84,
              height: 84,
              child: a.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: a.displayImageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.paperAlt),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.paperAlt,
                        child: Icon(Topics.byId(a.topic)?.icon ?? Icons.article_rounded,
                            color: AppColors.muted, size: 22),
                      ),
                    )
                  : Container(
                      color: AppColors.paperAlt,
                      child: Icon(Topics.byId(a.topic)?.icon ?? Icons.article_rounded,
                          color: AppColors.muted, size: 22),
                    ),
            ),
          ),
          SizedBox(width: AppSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: AppType.headline(
                    size: 16,
                    weight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.2,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6),
                Text(
                  _meta(a),
                  style: AppType.data(
                      size: 10, color: AppColors.muted, letterSpacing: 0.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hint(String title, String body) {
    return Padding(
      padding: EdgeInsets.all(AppSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_rounded, color: AppColors.muted, size: 40),
          SizedBox(height: AppSpace.md),
          Text(title,
              style: AppType.headline(
                  size: 20, weight: FontWeight.w700, color: AppColors.ink)),
          SizedBox(height: AppSpace.sm),
          Text(body,
              textAlign: TextAlign.center,
              style: AppType.display(
                  size: 14, color: AppColors.graphite, height: 1.5)),
        ],
      ),
    );
  }
}
