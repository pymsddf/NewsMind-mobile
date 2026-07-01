import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/vector_card.dart';
import '../services/user_service.dart';
import '../providers/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../widgets/notizz_brand_title.dart';
import '../utils/error_text.dart';

class HistoryScreen extends StatefulWidget {
  HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _isLoading = true;
  bool _canGenerate = false;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _canGenerate = authProvider.canGenerate;
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final authProvider = context.read<AuthProvider>();
    setState(() => _isLoading = true);
    try {
      // Show cached history first for instant paint.
      final cachedHistory = await UserService.getCachedHistory();
      _canGenerate = authProvider.canGenerate;
      
      List<Map<String, dynamic>> filteredHistory;
      if (_canGenerate) {
        filteredHistory = cachedHistory.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        // Filter out generation/translation items for Basic users
        filteredHistory = cachedHistory.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).where((item) {
          final type = (item['type'] ?? '').toString().toLowerCase();
          return !type.contains('gen') && !type.contains('trans') && !type.contains('news');
        }).toList();
      }
      
      if (filteredHistory.isNotEmpty) {
        setState(() {
          _history = filteredHistory;
          _isLoading = false;
        });
      }

      // Refresh from backend and update cache/UI.
      final history = await UserService.getHistory(forceRefresh: true);
      if (_canGenerate) {
        filteredHistory = history.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
      } else {
        filteredHistory = history.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).where((item) {
          final type = (item['type'] ?? '').toString().toLowerCase();
          return !type.contains('gen') && !type.contains('trans') && !type.contains('news');
        }).toList();
      }

      setState(() {
        _history = filteredHistory;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyError(e))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: AppColors.paper,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  title: NotizzBrandTitle(),
                  actions: [
                    IconButton(
                      icon: Icon(Icons.refresh_rounded, color: AppColors.graphite),
                      onPressed: _fetchHistory,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(AppSpace.md, AppSpace.sm, AppSpace.md, 0),
                    child: Text('Activity log',
                        style: Theme.of(context).textTheme.headlineMedium),
                  ),
                ),
                if (_history.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  _buildHistoryList(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.indigoSoft,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(Icons.history_rounded, size: 32, color: AppColors.indigo),
          ),
          SizedBox(height: 16),
          Text('No activity yet',
              style: AppType.display(size: 20, weight: FontWeight.w600, color: AppColors.ink)),
          SizedBox(height: 6),
          Text(
            'Your generated news and analyses will appear here.',
            style: AppType.display(size: 14, color: AppColors.graphite, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return SliverPadding(
      padding: EdgeInsets.all(16),
      sliver: SliverList.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final item = _history[index];
        final type = item['type'] ?? 'News';
        final query = item['query'] ?? '';
        final dateStr = item['createdAt'] ?? '';
        String formattedDate = '';
        if (dateStr.isNotEmpty) {
          try {
            final date = DateTime.parse(dateStr);
            formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
          } catch (_) {}
        }

        return Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: VectorCard(
            margin: EdgeInsets.zero,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _getColorForType(type).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(_getIconForType(type), color: _getColorForType(type), size: 20),
              ),
              title: Text(
                type,
                style: AppType.ui(size: 14, weight: FontWeight.w700, color: AppColors.ink),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (query.isNotEmpty) ...[
                    SizedBox(height: 4),
                    Text(
                      query,
                      style: AppType.display(size: 14, color: AppColors.graphite, height: 1.35),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 6),
                  Text(
                    formattedDate,
                    style: AppType.data(size: 11, color: AppColors.muted),
                  ),
                ],
              ),
              isThreeLine: query.isNotEmpty,
            ),
          ),
        );
      },
    ),
  );
}

  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'news':
      case 'news generation':
        return Icons.article_rounded;
      case 'verification':
      case 'fact check':
        return Icons.verified_user_rounded;
      case 'bias':
      case 'bias detection':
        return Icons.analytics_rounded;
      case 'translate':
      case 'translation':
        return Icons.translate_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'news':
      case 'news generation':
        return AppColors.indigo;
      case 'verification':
      case 'fact check':
        return AppColors.verified;
      case 'bias':
      case 'bias detection':
        return AppColors.caution;
      case 'translate':
      case 'translation':
        return AppColors.neutral;
      default:
        return AppColors.graphite;
    }
  }
}
