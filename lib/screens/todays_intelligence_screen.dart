import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/intelligence_design_system.dart';
import '../config/topics.dart';
import '../models/news_article_model.dart';
import '../services/news_service.dart';
import '../widgets/skeleton.dart';
import 'news_article_reader_screen.dart';

/// Today's Intelligence — the home feed of real aggregated news for the user's
/// chosen topics (`/api/news/feed`). Image-led editorial cards, Instagram-style
/// pull-to-refresh. Painted from [AppColors]/[AppType] so it follows the active
/// light/dark palette.
class TodaysIntelligenceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> trendingClaims;

  const TodaysIntelligenceScreen({
    super.key,
    required this.trendingClaims,
  });

  @override
  State<TodaysIntelligenceScreen> createState() =>
      TodaysIntelligenceScreenState();
}

class TodaysIntelligenceScreenState extends State<TodaysIntelligenceScreen> {
  List<NewsArticle> _articles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // Instant paint from the last cached feed, then refresh in the background.
    final cached = await NewsService.getCachedFeed();
    if (mounted && cached.isNotEmpty) {
      setState(() {
        _articles = cached;
        _isLoading = false;
      });
    }
    await _loadFeed(showSpinner: cached.isEmpty);
  }

  /// Called by HomeScreen when the user taps the Intelligence tab.
  void refresh() => _loadFeed(showSpinner: _articles.isEmpty);

  Future<void> _loadFeed({bool showSpinner = true}) async {
    if (!mounted) return;
    if (showSpinner) setState(() => _isLoading = true);
    try {
      final fresh = await NewsService.getFeed(limit: 40);
      if (!mounted) return;
      setState(() {
        // Keep whatever's on screen if a refresh returns empty (transient
        // network issue) rather than blanking a good cached list.
        if (fresh.isNotEmpty || _articles.isEmpty) _articles = fresh;
        _isLoading = false;
      });
      if (fresh.isNotEmpty) NewsService.cacheFeed(fresh);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _dismissArticle(NewsArticle a, int index) {
    setState(() => _articles.remove(a));
    NewsService.dismiss(a.id);
    NewsService.cacheFeed(_articles);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('Dismissed',
            style: AppType.ui(size: 13, color: AppColors.onAccent)),
        backgroundColor: AppColors.ink,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.redline,
          onPressed: () {
            if (!mounted) return;
            setState(
                () => _articles.insert(index.clamp(0, _articles.length), a));
            NewsService.undismiss(a.id);
            NewsService.cacheFeed(_articles);
          },
        ),
      ));
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: AppSpace.lg),
      decoration: BoxDecoration(
        color: AppColors.redlineSoft,
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.visibility_off_rounded,
              color: AppColors.redline, size: 20),
          SizedBox(width: AppSpace.sm),
          Text('Dismiss',
              style: AppType.ui(
                  size: 13, weight: FontWeight.w700, color: AppColors.redline)),
        ],
      ),
    );
  }

  void _openArticle(NewsArticle a) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NewsArticleReaderScreen(article: a)),
    );
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.paper,
      child: RefreshIndicator(
        onRefresh: () => _loadFeed(showSpinner: false),
        color: AppColors.indigo,
        backgroundColor: AppColors.surface,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            if (_isLoading)
              SliverToBoxAdapter(
                child: Skeleton(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        AppSpace.md, 0, AppSpace.md, AppSpace.xl),
                    child: Column(
                      children: List.generate(
                        4,
                        (_) => Padding(
                          padding: EdgeInsets.only(bottom: AppSpace.md),
                          child: _buildSkeletonCard(),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else if (_articles.isNotEmpty)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                    AppSpace.md, 0, AppSpace.md, AppSpace.xl),
                sliver: SliverList.separated(
                  itemCount: _articles.length,
                  separatorBuilder: (_, __) => SizedBox(height: AppSpace.md),
                  itemBuilder: (context, i) {
                    final a = _articles[i];
                    return Dismissible(
                      key: ValueKey(a.id.isEmpty ? a.sourceUrl : a.id),
                      direction: DismissDirection.startToEnd,
                      onDismissed: (_) => _dismissArticle(a, i),
                      background: _buildDismissBackground(),
                      child: _buildArticleCard(a),
                    );
                  },
                ),
              )
            else
              SliverToBoxAdapter(child: _buildEmptyState()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpace.md, AppSpace.lg, AppSpace.md, AppSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: "Today's ",
                  style: AppType.headline(
                    size: 32,
                    weight: FontWeight.w800,
                    color: AppColors.ink,
                    height: 1.05,
                    letterSpacing: -0.8,
                  ),
                ),
                TextSpan(
                  text: 'News',
                  style: AppType.headline(
                    size: 32,
                    weight: FontWeight.w800,
                    color: AppColors.redline,
                    fontStyle: FontStyle.italic,
                    height: 1.05,
                    letterSpacing: -0.8,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpace.sm),
          Text(
            'Real-time news across your chosen topics, refreshed through the day.',
            style: AppType.display(
                size: 15, color: AppColors.graphite, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Placeholder card mirroring [_buildArticleCard]'s layout (image → badge +
  /// meta → title lines → summary lines), shown while the feed loads.
  Widget _buildSkeletonCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.rule, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: SkeletonBox(height: double.infinity, radius: 0),
          ),
          Padding(
            padding: EdgeInsets.all(AppSpace.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SkeletonBox(width: 64, height: 16, radius: AppRadius.sm),
                    const Spacer(),
                    SkeletonBox(width: 90, height: 10),
                  ],
                ),
                SizedBox(height: AppSpace.md),
                SkeletonBox(width: double.infinity, height: 18),
                SizedBox(height: AppSpace.sm),
                SkeletonBox(width: 220, height: 18),
                SizedBox(height: AppSpace.md),
                SkeletonBox(width: double.infinity, height: 12),
                SizedBox(height: AppSpace.sm),
                SkeletonBox(width: 180, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArticleCard(NewsArticle a) {
    return GestureDetector(
      onTap: () => _openArticle(a),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.rule, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (a.imageUrl != null) _buildImage(a),
            Padding(
              padding: EdgeInsets.all(AppSpace.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.indigoSoft,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          a.topic.toUpperCase(),
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
                        child: Text(
                          [
                            if (a.sourceName.isNotEmpty) a.sourceName,
                            _relativeTime(a.publishedAt),
                          ].join('  ·  '),
                          textAlign: TextAlign.right,
                          overflow: TextOverflow.ellipsis,
                          style: AppType.data(
                              size: 10,
                              color: AppColors.muted,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpace.sm),
                  Text(
                    a.title,
                    style: AppType.headline(
                      size: 19,
                      weight: FontWeight.w700,
                      color: AppColors.ink,
                      height: 1.2,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (a.summary.isNotEmpty) ...[
                    SizedBox(height: AppSpace.sm),
                    Text(
                      a.summary,
                      style: AppType.display(
                          size: 14, color: AppColors.graphite, height: 1.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(NewsArticle a) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: CachedNetworkImage(
        imageUrl: a.displayImageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: AppColors.paperAlt),
        errorWidget: (_, __, ___) => Container(
          color: AppColors.paperAlt,
          child: Icon(
            Topics.byId(a.topic)?.icon ?? Icons.image_not_supported_rounded,
            color: AppColors.muted,
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          AppSpace.lg, AppSpace.xl, AppSpace.lg, AppSpace.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.indigoSoft,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.rule),
            ),
            child: Icon(Icons.newspaper_rounded,
                color: AppColors.indigo, size: 30),
          ),
          SizedBox(height: AppSpace.md),
          Text(
            'No news yet',
            style: AppType.headline(
                size: 20,
                weight: FontWeight.w700,
                color: AppColors.ink,
                letterSpacing: -0.3),
          ),
          SizedBox(height: AppSpace.sm),
          Text(
            'Pull down to refresh, or pick your topics in Profile to tailor this feed.',
            style: AppType.display(
                size: 14, color: AppColors.graphite, height: 1.5),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
