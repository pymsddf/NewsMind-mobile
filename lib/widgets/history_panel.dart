import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/intelligence_design_system.dart';
import '../services/user_service.dart';

class HistoryPanel extends StatefulWidget {
  final VoidCallback onClose;
  final void Function(Map<String, dynamic>) onNavigate;
  final bool canGenerate;

  const HistoryPanel(
      {super.key,
      required this.onClose,
      required this.onNavigate,
      required this.canGenerate});

  @override
  State<HistoryPanel> createState() => _HistoryPanelState();
}

class _HistoryPanelState extends State<HistoryPanel>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> _allHistory = [];
  List<Map<String, dynamic>> _filteredHistory = [];
  bool _isLoading = true;
  int _selectedTabIndex = 0;
  late TabController _tabController;

  late List<String> _tabs;
  late List<String?> _typeFilters;

  @override
  void initState() {
    super.initState();
    _initTabs();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _fetchHistory();
  }

  void _initTabs() {
    if (widget.canGenerate) {
      _tabs = ['ALL', 'GENERATE', 'VERIFY', 'BIAS'];
      _typeFilters = [null, 'generation', 'verification', 'bias'];
    } else {
      _tabs = ['ALL', 'VERIFY', 'BIAS'];
      _typeFilters = [null, 'verification', 'bias'];
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _selectedTabIndex = _tabController.index;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final typeFilter = _typeFilters[_selectedTabIndex];
    if (typeFilter == null) {
      _filteredHistory = List.from(_allHistory);
    } else {
      _filteredHistory = _allHistory.where((item) {
        final type = (item['type'] ?? '').toString().toLowerCase();
        final page = (item['page'] ?? '').toString().toLowerCase();

        if (typeFilter == 'generation') {
          return type.contains('gen') ||
              type.contains('trans') ||
              page.contains('gen');
        } else if (typeFilter == 'verification') {
          return type.contains('fact') ||
              type.contains('verif') ||
              page.contains('fact') ||
              page.contains('verif');
        } else if (typeFilter == 'bias') {
          return type.contains('bias') || page.contains('bias');
        }
        return true;
      }).toList();
    }
    setState(() {});
  }

  Future<void> _fetchHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      // Phase 1: render cached history immediately (fast open)
      final cachedRaw = await UserService.getCachedHistory();
      if (cachedRaw.isNotEmpty && mounted) {
        final cached = cachedRaw
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
        setState(() {
          _allHistory = cached;
          _applyFilter();
          _isLoading = false;
        });
      }

      // Phase 2: refresh from server in background and update UI
      final historyRaw = await UserService.getHistory(forceRefresh: true);
      final history = historyRaw
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();

      if (!mounted) return;
      setState(() {
        _allHistory = history;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rendered as a Scaffold endDrawer — opens with a right-edge left-swipe.
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.9,
      backgroundColor: AppColors.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: IntelligenceColors.electricTeal,
                      ),
                    )
                  : _filteredHistory.isEmpty
                      ? _buildEmptyState()
                      : _buildList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(IntelligenceSpacing.standard),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'HISTORY',
            style: AppTheme.textTheme.bodyMedium?.copyWith(
              fontSize: IntelligenceTypography.headingSm,
              fontWeight: FontWeight.w700,
              color: IntelligenceColors.pureWhite,
              letterSpacing: 2,
            ),
          ),
          Spacer(),
          if (_allHistory.isNotEmpty)
            TextButton.icon(
              onPressed: _showClearConfirmation,
              icon: Icon(Icons.delete_sweep_rounded,
                  size: 18, color: IntelligenceColors.crimsonSpike),
              label: Text(
                'ELIMINATE ALL',
                style: AppTheme.textTheme.labelMedium?.copyWith(
                  color: IntelligenceColors.crimsonSpike,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: IntelligenceColors.secondaryTextGrey,
            ),
            onPressed: widget.onClose,
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: IntelligenceColors.surfaceDark,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: IntelligenceColors.slateGrey),
        ),
        title: Text(
          'ELIMINATE HISTORY',
          style: AppTheme.textTheme.bodyMedium?.copyWith(
            color: IntelligenceColors.pureWhite,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This action is irreversible. All records will be purged from the neural link.',
          style: AppTheme.textTheme.bodyLarge?.copyWith(
            color: IntelligenceColors.secondaryTextGrey,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.secondaryTextGrey,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _clearHistory();
            },
            child: Text(
              'PURGE ALL',
              style: AppTheme.textTheme.bodyMedium?.copyWith(
                color: IntelligenceColors.crimsonSpike,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearHistory() async {
    setState(() => _isLoading = true);
    try {
      final success = await UserService.clearHistory();
      if (success) {
        setState(() {
          _allHistory = [];
          _filteredHistory = [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildTabBar() {
    return Container(
      margin:
          EdgeInsets.symmetric(horizontal: IntelligenceSpacing.standard),
      decoration: BoxDecoration(
        color: IntelligenceColors.surfaceDark,
        border: Border.all(
          color: IntelligenceColors.slateGrey,
          width: 1,
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: IntelligenceColors.electricTeal,
        indicatorWeight: 2,
        labelColor: IntelligenceColors.electricTeal,
        unselectedLabelColor: IntelligenceColors.secondaryTextGrey,
        labelStyle: AppTheme.textTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: AppTheme.textTheme.labelMedium?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
        tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: IntelligenceColors.secondaryTextGrey.withValues(alpha: 0.3),
          ),
          SizedBox(height: IntelligenceSpacing.standard),
          Text(
            'NO RECORDS FOUND',
            style: AppTheme.textTheme.labelMedium?.copyWith(
              fontSize: IntelligenceTypography.monoMd,
              color: IntelligenceColors.secondaryTextGrey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: IntelligenceColors.electricTeal,
      backgroundColor: IntelligenceColors.surfaceDark,
      child: ListView.builder(
        padding: EdgeInsets.all(IntelligenceSpacing.standard),
        itemCount: _filteredHistory.length,
        itemBuilder: (context, index) {
          final item = _filteredHistory[index];
          return _buildHistoryCard(item, index);
        },
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> item, int index) {
    final type = (item['type'] ?? 'News').toString();
    final data = item['data'] as Map<String, dynamic>? ?? {};
    final input = data['input'] is Map
        ? Map<String, dynamic>.from(data['input'])
        : <String, dynamic>{};
    final output = data['output'] is Map
        ? Map<String, dynamic>.from(data['output'])
        : <String, dynamic>{};
    final query = item['title'] ??
        input['topic'] ??
        item['query'] ??
        data['title'] ??
        data['query'] ??
        'Untitled Activity';
    final dateStr = item['createdAt'] ?? item['timestamp'] ?? '';

    String formattedDate = '';
    if (dateStr.toString().isNotEmpty) {
      try {
        final date = DateTime.parse(dateStr.toString());
        final diff = DateTime.now().difference(date);
        if (diff.inHours < 24) {
          formattedDate = diff.inHours > 0
              ? '${diff.inHours}h ago'
              : '${diff.inMinutes}m ago';
        } else {
          formattedDate = DateFormat('MMM d, HH:mm').format(date);
        }
      } catch (_) {
        formattedDate = dateStr.toString();
      }
    }

    // Extract a preview based on type
    String preview = '';
    final lowerType = type.toLowerCase();
    if (lowerType.contains('gen')) {
      preview = output['content'] ?? data['content'] ?? item['preview'] ?? '';
    } else if (lowerType.contains('trans')) {
      final translated = output['translatedContent'] ??
          data['translated_content'] ??
          data['translated_text'] ??
          data['translation'] ??
          '';
      final target = output['targetLanguage'] ??
          input['targetLanguage'] ??
          data['target_language'] ??
          '';
      preview = target.toString().isNotEmpty
          ? '$target: $translated'
          : translated.toString();
    } else if (lowerType.contains('fact') || lowerType.contains('verif')) {
      final verdict = output['verdict'] ?? data['verdict'];
      final summary =
          output['summary'] ?? data['summary'] ?? data['conclusion'] ?? '';
      preview = verdict != null
          ? 'Verdict: $verdict. $summary'
          : (output['content'] ?? data['content'] ?? item['preview'] ?? '');
    } else if (lowerType.contains('bias')) {
      final overallBias = output['overallBias'] is Map
          ? Map<String, dynamic>.from(output['overallBias'])
          : <String, dynamic>{};
      final label = overallBias['level'] ??
          output['overall_label'] ??
          data['overall_label'] ??
          data['bias_label'] ??
          '';
      final score = overallBias['score'] ??
          output['overall_score'] ??
          data['overall_score'] ??
          '';
      if (label.toString().isNotEmpty) {
        preview =
            'Bias: $label ${score != '' ? '($score%)' : ''}. ${output['summary'] ?? data['summary'] ?? ''}';
      } else {
        preview = output['summary'] ??
            output['content'] ??
            data['summary'] ??
            data['content'] ??
            item['preview'] ??
            '';
      }
    } else {
      preview = item['preview'] ?? '';
    }

    return Dismissible(
      key: Key(item['id']?.toString() ?? index.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: IntelligenceSpacing.standard),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        color: IntelligenceColors.crimsonSpike.withValues(alpha: 0.2),
        child: Icon(Icons.delete_outline_rounded,
            color: IntelligenceColors.crimsonSpike),
      ),
      onDismissed: (direction) {
        final id = item['id']?.toString();
        if (id != null) {
          UserService.deleteHistoryItem(id);
          setState(() {
            _allHistory.removeWhere((h) => h['id'].toString() == id);
            _filteredHistory.removeAt(index);
          });
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: IntelligenceSpacing.standard),
        decoration: BoxDecoration(
          color: IntelligenceColors.surfaceDark,
          border: Border.all(
            color: IntelligenceColors.slateGrey,
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _navigateToDetail(item),
            child: Padding(
              padding: EdgeInsets.all(IntelligenceSpacing.standard),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: IntelligenceSpacing.compact,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getColorForType(type).withValues(alpha: 0.15),
                            border: Border.all(
                              color:
                                  _getColorForType(type).withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            _getDisplayNameForType(type).toUpperCase(),
                            style: AppTheme.textTheme.labelMedium?.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: _getColorForType(type),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        formattedDate,
                        style: AppTheme.textTheme.labelMedium?.copyWith(
                          fontSize: IntelligenceTypography.monoSm,
                          color: IntelligenceColors.secondaryTextGrey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: IntelligenceSpacing.standard),

                  // Query/Title
                  Text(
                    query.toString(),
                    style: AppTheme.textTheme.bodyLarge?.copyWith(
                      fontSize: IntelligenceTypography.bodyMd,
                      fontWeight: FontWeight.w600,
                      color: IntelligenceColors.pureWhite,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  if (preview.toString().isNotEmpty) ...[
                    SizedBox(height: IntelligenceSpacing.compact),
                    Text(
                      preview.toString().replaceAll('\n', ' ').trim(),
                      style: AppTheme.textTheme.labelMedium?.copyWith(
                        fontSize: IntelligenceTypography.monoSm,
                        color: IntelligenceColors.secondaryTextGrey,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(Map<String, dynamic> item) {
    widget.onNavigate(item);
  }



  Color _getColorForType(String type) {
    type = type.toLowerCase();
    if (type.contains('gen') || type.contains('trans') || type.contains('news')) {
      return IntelligenceColors.cyberBlue;
    }
    if (type.contains('fact') || type.contains('verif')) {
      return IntelligenceColors.electricTeal;
    }
    if (type.contains('bias')) return IntelligenceColors.kineticsOrange;
    return IntelligenceColors.secondaryTextGrey;
  }

  String _getDisplayNameForType(String type) {
    type = type.toLowerCase();
    if (type.contains('gen') || type.contains('trans') || type.contains('news')) {
      return 'Generation';
    }
    if (type.contains('fact') || type.contains('verif')) return 'Verification';
    if (type.contains('bias')) return 'Bias Analysis';
    return type;
  }
}
