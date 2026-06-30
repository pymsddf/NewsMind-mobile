import 'dart:async';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/intelligence_design_system.dart';
import '../providers/auth_provider.dart';
import 'news_generation_screen.dart';
import 'fact_checking_screen.dart';
import 'bias_detection_screen.dart';
import 'profile_screen.dart';
import '../widgets/history_panel.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../utils/title_format.dart';
import 'todays_intelligence_screen.dart';
import '../widgets/vector_button.dart';
import '../widgets/newsmind_brand_title.dart';
import '../models/article_model.dart';
import '../models/verification_model.dart';
import '../models/bias_model.dart';

/// Today's Intelligence - Home Screen
///
/// Visual: AppBar title: 'TODAY'S INTELLIGENCE' (Bold Public Sans).
/// Main Focus: A prioritised list view of the top 5 trending news claims.
/// Card Styling: Each card is a structured data block with strict column alignment:
///   - Left column: Large JetBrains Mono timestamp (e.g., 08:30 AM)
///   - Center column: Noto Serif headline
///   - Right column: Minimalist vertical bias sparkline and credibility meter
class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _historyOpen = false;

  final GlobalKey<NewsGenerationScreenState> _genKey = GlobalKey();
  final GlobalKey<FactCheckingScreenState> _factKey = GlobalKey();
  final GlobalKey<BiasDetectionScreenState> _biasKey = GlobalKey();
  final GlobalKey<TodaysIntelligenceScreenState> _intelligenceKey = GlobalKey();

  bool _canGenerate = false;
  int _unreadCount = 0;
  Timer? _unreadTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUnreadCount();
    // Poll periodically so a notification that arrives while the user sits on
    // the home screen lights the bell without needing a tab switch.
    _unreadTimer = Timer.periodic(
      const Duration(seconds: 60),
      (_) => _loadUnreadCount(),
    );
  }

  @override
  void dispose() {
    _unreadTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Refresh the moment the app returns to the foreground.
    if (state == AppLifecycleState.resumed) _loadUnreadCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateCanGenerate();
  }

  /// Fetch unread notifications so the bell only shows a dot when there's
  /// actually something unread.
  Future<void> _loadUnreadCount() async {
    try {
      final notifications = await NotificationService.getNotifications();
      final unread = notifications
          .where((n) => (n['isRead'] ?? n['read'] ?? false) == false)
          .length;
      if (mounted && unread != _unreadCount) {
        setState(() => _unreadCount = unread);
      }
    } catch (_) {
      // Non-fatal: just don't show the dot.
    }
  }

  void _updateCanGenerate() {
    final authProvider = context.read<AuthProvider>();
    final newCanGenerate = authProvider.canGenerate;
    if (_canGenerate != newCanGenerate) {
      print(
          '_updateCanGenerate: changing from $_canGenerate to $newCanGenerate');
      setState(() {
        _canGenerate = newCanGenerate;
      });
    }
  }

  // Always get fresh value from provider
  bool get _currentCanGenerate {
    try {
      return context.read<AuthProvider>().canGenerate;
    } catch (e) {
      return _canGenerate;
    }
  }

  List<Widget> get _screens {
    if (_canGenerate) {
      return [
        TodaysIntelligenceScreen(key: _intelligenceKey, trendingClaims: []),
        NewsGenerationScreen(
          key: _genKey,
          showHeader: false,
          onTabSwitch: (index, {text, result}) =>
              _switchTab(index, text: text, result: result),
        ),
        FactCheckingScreen(
          key: _factKey,
          initialText: '',
          initialResult: null,
          showHeader: false,
        ),
        BiasDetectionScreen(
          key: _biasKey,
          initialText: '',
          initialResult: null,
          showHeader: false,
        ),
        ProfileScreen(),
      ];
    } else {
      // Basic users - no generation tab
      return [
        TodaysIntelligenceScreen(key: _intelligenceKey, trendingClaims: []),
        FactCheckingScreen(
          key: _factKey,
          initialText: '',
          initialResult: null,
          showHeader: false,
        ),
        BiasDetectionScreen(
          key: _biasKey,
          initialText: '',
          initialResult: null,
          showHeader: false,
        ),
        ProfileScreen(),
      ];
    }
  }

  void _switchTab(int index,
      {String? text, dynamic result, String? historyType}) {
    final canGenerate = _currentCanGenerate;

    // For Basic users: 0=Intelligence, 1=Verify, 2=Bias, 3=Profile
    // For Generator users: 0=Intelligence, 1=Generate, 2=Verify, 3=Bias, 4=Profile
    // So the "target screen index" should be used directly without adjustment
    final targetIndex = index;

    setState(() {
      _currentIndex = targetIndex;
    });

    // Determine which prefill method to call based on history type, not tab index
    final isFromHistory = historyType != null;
    final typeLower = historyType?.toLowerCase() ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isFromHistory) {
        // History item navigation - use history type to determine prefill
        if ((typeLower.contains('fact') || typeLower.contains('verif')) &&
            _factKey.currentState != null) {
          _factKey.currentState!
              .prefill(text ?? '', result as VerificationModel?);
        } else if (typeLower.contains('bias') &&
            _biasKey.currentState != null) {
          _biasKey.currentState!.prefill(text ?? '', result as BiasModel?);
        } else if ((typeLower.contains('gen') || typeLower.contains('trans')) &&
            _genKey.currentState != null &&
            result is ArticleModel) {
          _genKey.currentState!.prefill(text ?? '', result);
        }
      } else {
        // Regular tab navigation - use tab index
        if (!canGenerate) {
          // Basic user screens: 0=Intelligence, 1=Verify, 2=Bias, 3=Profile
          if (targetIndex == 1 && _factKey.currentState != null) {
            _factKey.currentState!
                .prefill(text ?? '', result as VerificationModel?);
          } else if (targetIndex == 2 && _biasKey.currentState != null) {
            _biasKey.currentState!.prefill(text ?? '', result as BiasModel?);
          }
        } else {
          // Generator user screens: 0=Intelligence, 1=Generate, 2=Verify, 3=Bias, 4=Profile
          if (targetIndex == 2 && _factKey.currentState != null) {
            _factKey.currentState!
                .prefill(text ?? '', result as VerificationModel?);
          } else if (targetIndex == 3 && _biasKey.currentState != null) {
            _biasKey.currentState!.prefill(text ?? '', result as BiasModel?);
          } else if (targetIndex == 1 &&
              _genKey.currentState != null &&
              result is ArticleModel) {
            _genKey.currentState!.prefill(text ?? '', result);
          }
        }
      }
    });
  }

  void _openHistoryItem(Map<String, dynamic> item) {
    print('=== _openHistoryItem START ===');
    print('item type: ${item['type']}');
    print('item keys: ${item.keys.toList()}');

    final canGenerate = _currentCanGenerate;

    final type = (item['type'] ?? '').toString().toLowerCase();
    final data = item['data'] as Map<String, dynamic>? ?? {};
    final input = data['input'] is Map
        ? Map<String, dynamic>.from(data['input'])
        : <String, dynamic>{};
    final output = data['output'] is Map
        ? Map<String, dynamic>.from(data['output'])
        : <String, dynamic>{};

    print('type after lowercase: $type');
    print('type contains verif: ${type.contains('verif')}');
    print('type contains fact: ${type.contains('fact')}');
    print('type contains bias: ${type.contains('bias')}');
    print('type contains gen: ${type.contains('gen')}');

    String pickText(List<dynamic> values) {
      for (final value in values) {
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    dynamic pickValue(List<dynamic> values) {
      for (final value in values) {
        if (value == null) continue;
        if (value is String && value.trim().isEmpty) continue;
        return value;
      }
      return null;
    }

    if (type.contains('gen')) {
      print('Taking GEN branch');
      final content = pickText([
        output['content'],
        data['content'],
        data['articleContent'],
        item['content'],
        item['preview'],
      ]);
      // Prefer the original input topic; fall back to a markdown-stripped title
      // so the topic box never shows raw "## …" from a history record.
      final topic = cleanTitle(pickText([
        input['topic'],
        item['title'],
        data['title'],
      ]));
      final parametersRaw = pickValue([
        output['parameters'],
        data['parameters'],
        item['parameters'],
      ]);
      final parameters = parametersRaw is Map
          ? Map<String, dynamic>.from(parametersRaw)
          : <String, dynamic>{};
      final wordCountRaw = pickValue([
        output['wordCount'],
        data['wordCount'],
        item['wordCount'],
      ]);
      final wordCount = (wordCountRaw is num) ? wordCountRaw.toInt() : null;
      final historyId = item['id']?.toString() ?? item['_id']?.toString();

      final article = ArticleModel(
        id: item['id']?.toString(),
        title: cleanTitle(
            pickText([item['title'], data['title'], 'Generated Article'])),
        content: content,
        parameters: parameters,
        wordCount: wordCount,
        status: 'completed',
        createdAt:
            item['createdAt']?.toString() ?? item['timestamp']?.toString(),
        historyId: historyId,
      );

      // Generation: Basic=1 (no gen), Generator=1
      _switchTab(1, text: topic, result: article, historyType: type);
    } else if (type.contains('trans')) {
      print('Taking TRANS branch');
      final content = pickText([
        output['translatedContent'],
        output['translated_content'],
        output['translated_text'],
        output['content'],
        data['translatedContent'],
        data['translated_content'],
        data['translated_text'],
        data['content'],
        data['articleContent'],
        item['content'],
        item['preview'],
      ]);
      // Prefer the original input topic; fall back to a markdown-stripped title
      // so the topic box never shows raw "## …" from a history record.
      final topic = cleanTitle(pickText([
        input['topic'],
        item['title'],
        data['title'],
      ]));
      final parametersRaw = pickValue([
        output['parameters'],
        data['parameters'],
        item['parameters'],
      ]);
      final parameters = parametersRaw is Map
          ? Map<String, dynamic>.from(parametersRaw)
          : <String, dynamic>{};
      final wordCountRaw = pickValue([
        output['wordCount'],
        data['wordCount'],
        item['wordCount'],
      ]);
      final wordCount = (wordCountRaw is num) ? wordCountRaw.toInt() : null;
      final historyId = item['id']?.toString() ?? item['_id']?.toString();

      final article = ArticleModel(
        id: item['id']?.toString(),
        title: pickText([item['title'], data['title'], 'Translated Article']),
        content: content,
        parameters: parameters,
        wordCount: wordCount,
        status: 'completed',
        createdAt:
            item['createdAt']?.toString() ?? item['timestamp']?.toString(),
        historyId: historyId,
      );

      // Translation: Basic=1 (no trans), Generator=1
      _switchTab(1, text: topic, result: article, historyType: type);
    } else if (type.contains('fact') || type.contains('verif')) {
      print('Taking VERIFICATION branch');
      final content = pickText([
        input['originalContent'],
        data['originalContent'],
        data['articleContent'],
        data['input_content'],
        data['content'],
        item['preview'],
      ]);

      print('=== VERIFICATION DEBUG ===');
      print(
          'content: ${content.substring(0, content.length > 100 ? 100 : content.length)}...');
      print('output keys: ${output.keys.toList()}');
      print('data keys: ${data.keys.toList()}');

      VerificationModel? result;
      final historyId = item['id']?.toString() ?? item['_id']?.toString();
      final verificationJson = <String, dynamic>{
        'verdict': output['verdict'] ?? data['verdict'] ?? 'MAYBE',
        'confidence': output['confidence'] ??
            data['confidence'] ??
            data['confidence_score'] ??
            5,
        'credibilityScore': output['credibilityScore'] ??
            data['credibilityScore'] ??
            data['credibility_score'] ??
            data['score'] ??
            50,
        'summary':
            output['summary'] ?? data['summary'] ?? data['conclusion'] ?? '',
        'keyFindings': output['keyFindings'] ??
            data['keyFindings'] ??
            data['key_findings'] ??
            data['claims'] ??
            [],
        'evidence': output['evidence'] ??
            output['sources'] ??
            data['evidence'] ??
            data['sources'] ??
            data['claims'] ??
            [],
        'status': 'completed',
        if (historyId != null) 'historyId': historyId,
      };

      print('verificationJson: $verificationJson');

      if (verificationJson.isNotEmpty) {
        final verdictValue = verificationJson['verdict'];
        print('verdictValue: $verdictValue');
        if (verdictValue != null && verdictValue.toString().isNotEmpty) {
          try {
            result = VerificationModel.fromJson(verificationJson);
            print('VerificationModel created: ${result.verdict}');
          } catch (e) {
            print('Verification parse error: $e');
          }
        }
      }
      print('=== END VERIFICATION DEBUG ===');

      // Verification: Basic user = screen index 1, Generator = screen index 2
      final targetIndex = canGenerate ? 2 : 1;
      _switchTab(targetIndex, text: content, result: result, historyType: type);
    } else if (type.contains('bias')) {
      print('Taking BIAS branch');
      final content = pickText([
        input['originalText'],
        data['input_text'],
        input['originalUrl'],
        data['input_url'],
        data['originalContent'],
        data['content'],
        item['preview'],
      ]);

      BiasModel? result;
      final historyId = item['id']?.toString() ?? item['_id']?.toString();

      final overallBiasMap = output['overallBias'] is Map
          ? Map<String, dynamic>.from(output['overallBias'])
          : <String, dynamic>{};

      final biasJson = <String, dynamic>{
        'overall_score': output['overall_score'] ??
            overallBiasMap['score'] ??
            data['overall_score'] ??
            0,
        'overall_label': output['overall_label'] ??
            overallBiasMap['level'] ??
            data['overall_label'] ??
            'medium',
        'dimensions':
            output['labels'] ?? data['labels'] ?? data['dimensions'] ?? {},
        'key_phrases': output['keyFindings'] ??
            data['keyFindings'] ??
            data['key_findings'] ??
            [],
        'evidence':
            output['evidence'] ?? data['evidence'] ?? data['claims'] ?? [],
        'recommendations':
            output['recommendations'] ?? data['recommendations'] ?? [],
        if (historyId != null) 'historyId': historyId,
      };

      if (biasJson.isNotEmpty) {
        try {
          result = BiasModel.fromJson(biasJson);
        } catch (e) {
          print('Bias parse error: $e');
        }
      }

      // Bias: Basic user = screen index 2, Generator = screen index 3
      final targetIndex = canGenerate ? 3 : 2;
      _switchTab(targetIndex, text: content, result: result, historyType: type);
    }
    print('=== _openHistoryItem END ===');
  }

  Future<void> _handleLogout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final providerCanGenerate = context.watch<AuthProvider>().canGenerate;
    if (_canGenerate != providerCanGenerate) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _canGenerate = providerCanGenerate;
          if (!_canGenerate && _currentIndex > 3) {
            _currentIndex = 0;
          }
        });
      });
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < IntelligenceBreakpoints.mobile;

        return Scaffold(
          key: _scaffoldKey,
          backgroundColor: IntelligenceColors.obsidianBlack,
          appBar: AppBar(
            backgroundColor: IntelligenceColors.obsidianBlack,
            elevation: 0,
            title: NewsMindBrandTitle(),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: IntelligenceColors.secondaryTextGrey,
                  size: IntelligenceSpacing.iconMd,
                ),
                onPressed: () => context.push('/search'),
              ),
              Stack(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_rounded,
                      color: IntelligenceColors.secondaryTextGrey,
                      size: IntelligenceSpacing.iconMd,
                    ),
                    // Refresh the unread count when returning from the list
                    // (items get marked read there).
                    onPressed: () => context
                        .push('/notifications')
                        .then((_) => _loadUnreadCount()),
                  ),
                  // Only show the dot when there are actually unread notifications.
                  if (_unreadCount > 0)
                    Positioned(
                      right: 12,
                      top: 12,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: IntelligenceColors.cyberBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: IntelligenceColors.crimsonSpike,
                  size: IntelligenceSpacing.iconMd,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) {
                      int rating = 0;
                      final commentController = TextEditingController();
                      return StatefulBuilder(
                          builder: (context, setDialogState) => AlertDialog(
                                backgroundColor: IntelligenceColors.surfaceDark,
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: IntelligenceColors.slateGrey),
                                ),
                                title: Text(
                                  'Logout',
                                  style:
                                      AppTheme.textTheme.bodyMedium?.copyWith(
                                    color: IntelligenceColors.pureWhite,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                content: SizedBox(
                                  width: 320,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Please rate your experience before logout',
                                        style: AppTheme.textTheme.bodyLarge
                                            ?.copyWith(
                                          color: IntelligenceColors
                                              .secondaryTextGrey,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Row(
                                        children: List.generate(5, (index) {
                                          final star = index + 1;
                                          return IconButton(
                                            icon: Icon(
                                              rating >= star
                                                  ? Icons.star_rounded
                                                  : Icons.star_border_rounded,
                                              color: rating >= star
                                                  ? IntelligenceColors
                                                      .electricTeal
                                                  : IntelligenceColors
                                                      .secondaryTextGrey,
                                            ),
                                            onPressed: () => setDialogState(
                                                () => rating = star),
                                          );
                                        }),
                                      ),
                                      SizedBox(height: 8),
                                      TextField(
                                        controller: commentController,
                                        maxLines: 3,
                                        style: AppTheme.textTheme.bodyMedium
                                            ?.copyWith(
                                          color: IntelligenceColors.pureWhite,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Optional comment',
                                          hintStyle: AppTheme
                                              .textTheme.bodyMedium
                                              ?.copyWith(
                                            color: IntelligenceColors
                                                .secondaryTextGrey,
                                          ),
                                          filled: true,
                                          fillColor:
                                              IntelligenceColors.obsidianBlack,
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx),
                                    child: Text(
                                      'Cancel',
                                      style: AppTheme.textTheme.bodyMedium
                                          ?.copyWith(
                                        color: IntelligenceColors
                                            .secondaryTextGrey,
                                      ),
                                    ),
                                  ),
                                  VectorButton(
                                    label: 'Logout',
                                    type: VectorButtonType.critical,
                                    onPressed: () async {
                                      Navigator.pop(ctx);
                                      await AuthService.submitLogoutFeedback(
                                        rating: rating == 0 ? null : rating,
                                        comment: commentController.text,
                                      );
                                      await _handleLogout();
                                    },
                                  ),
                                ],
                              ));
                    },
                  );
                },
              ),
              SizedBox(width: IntelligenceSpacing.compact),
            ],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: IntelligenceColors.slateGrey,
              ),
            ),
          ),
          body: Row(
            children: [
              if (!isMobile)
                NavigationRail(
                  backgroundColor: IntelligenceColors.obsidianBlack,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() => _currentIndex = index);
                    if (index == 0) {
                      _intelligenceKey.currentState?.refresh();
                    }
                  },
                  labelType: NavigationRailLabelType.all,
                  selectedLabelTextStyle:
                      AppTheme.textTheme.labelMedium?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: IntelligenceColors.electricTeal,
                  ),
                  unselectedLabelTextStyle:
                      AppTheme.textTheme.labelMedium?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: IntelligenceColors.secondaryTextGrey,
                  ),
                  indicatorColor:
                      IntelligenceColors.electricTeal.withValues(alpha: 0.15),
                  destinations: _canGenerate
                      ? [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_rounded),
                            selectedIcon: Icon(Icons.home_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('HOME'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.edit_note_rounded),
                            selectedIcon: Icon(Icons.edit_note_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('GENERATE'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.verified_rounded),
                            selectedIcon: Icon(Icons.verified_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('VERIFY'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.balance_rounded),
                            selectedIcon: Icon(Icons.balance_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('BIAS'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_rounded),
                            selectedIcon: Icon(Icons.person_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('PROFILE'),
                          ),
                        ]
                      : [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_rounded),
                            selectedIcon: Icon(Icons.home_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('HOME'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.verified_rounded),
                            selectedIcon: Icon(Icons.verified_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('VERIFY'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.balance_rounded),
                            selectedIcon: Icon(Icons.balance_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('BIAS'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_rounded),
                            selectedIcon: Icon(Icons.person_rounded,
                                color: IntelligenceColors.electricTeal),
                            label: Text('PROFILE'),
                          ),
                        ],
                ),
              if (!isMobile)
                VerticalDivider(
                    thickness: 1,
                    width: 1,
                    color: IntelligenceColors.slateGrey),
              Expanded(
                // Offstage-per-tab instead of IndexedStack: IndexedStack lays
                // out ALL tabs, so hidden tabs' hover widgets stay in the web
                // mouse-tracker's annotation list and crash hit-testing
                // ("render box never laid out"). Offstage skips layout for
                // hidden tabs; state is preserved by the per-screen GlobalKeys.
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    for (int i = 0; i < _screens.length; i++)
                      Offstage(
                        offstage: _currentIndex != i,
                        child: TickerMode(
                          enabled: _currentIndex == i,
                          child: _screens[i],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // History opens with a right-edge left-swipe. Built lazily (only while
          // open): keeping its hover-capable content (TabBar, list InkWells)
          // offstage at all times crashes Flutter-web's mouse tracker and blocks
          // clicks elsewhere. An empty Drawer keeps the edge-swipe gesture live.
          onEndDrawerChanged: (open) {
            if (_historyOpen != open) setState(() => _historyOpen = open);
          },
          endDrawer: _historyOpen
              ? HistoryPanel(
                  onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
                  onNavigate: (item) {
                    _scaffoldKey.currentState?.closeEndDrawer();
                    _openHistoryItem(item);
                  },
                  canGenerate: _canGenerate,
                )
              : Drawer(child: SizedBox.shrink()),
          bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
        );
      },
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: IntelligenceColors.obsidianBlack,
        border: Border(
          top: BorderSide(
            color: IntelligenceColors.slateGrey,
            width: 1,
          ),
        ),
      ),
      // SafeArea(bottom) pads for the Android system nav bar so the icons sit
      // above it, while the Container background still fills down to the screen
      // edge. The bar's own height lives on the inner SizedBox.
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: IntelligenceSpacing.compact,
              vertical: IntelligenceSpacing.compact,
            ),
            child: _canGenerate
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'HOME'),
                      _buildNavItem(1, Icons.edit_note_rounded, 'GENERATE'),
                      _buildNavItem(2, Icons.verified_rounded, 'VERIFY'),
                      _buildNavItem(3, Icons.balance_rounded, 'BIAS'),
                      _buildNavItem(4, Icons.person_rounded, 'PROFILE'),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(0, Icons.home_rounded, 'HOME'),
                      _buildNavItem(1, Icons.verified_rounded, 'VERIFY'),
                      _buildNavItem(2, Icons.balance_rounded, 'BIAS'),
                      _buildNavItem(3, Icons.person_rounded, 'PROFILE'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => _currentIndex = index);
        if (index == 0) {
          _intelligenceKey.currentState?.refresh();
        } else if (index == (_canGenerate ? 4 : 3)) {
          // Entering Profile: pull fresh user data so the usage stats reflect
          // generate/verify/bias actions taken since the app opened.
          context.read<AuthProvider>().refreshUser();
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? IntelligenceColors.electricTeal
                  : IntelligenceColors.secondaryTextGrey,
              size: 22,
            ),
            if (isSelected) ...[
              SizedBox(width: 6),
              Text(
                label,
                style: AppTheme.textTheme.labelMedium?.copyWith(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: IntelligenceColors.electricTeal,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
