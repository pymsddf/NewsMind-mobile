import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/article_model.dart';
import '../models/news_article_model.dart';
import 'api_service.dart';

class NewsService {
  static const String _feedCacheKey = 'feed_cache_v1';

  /// Persist the latest feed locally for instant paint on next open.
  static Future<void> cacheFeed(List<NewsArticle> articles) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _feedCacheKey, jsonEncode(articles.map((a) => a.toJson()).toList()));
    } catch (_) {}
  }

  /// Last cached feed (empty if none). Shown immediately while the network refreshes.
  static Future<List<NewsArticle>> getCachedFeed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_feedCacheKey);
      if (raw == null || raw.isEmpty) return [];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
    } catch (_) {}
    return [];
  }
  // ---- Aggregated real-news topic feed (`/api/news/feed`, `/api/user/topics`) ----

  /// Latest aggregated articles for the user's topics (or all topics if the
  /// user hasn't picked any yet). Pass [before] for time-based pagination.
  static Future<List<NewsArticle>> getFeed(
      {int limit = 30, DateTime? before}) async {
    var endpoint = '/api/news/feed?limit=$limit';
    if (before != null) {
      endpoint +=
          '&before=${Uri.encodeComponent(before.toUtc().toIso8601String())}';
    }
    final res = await ApiService.get(endpoint);
    if (res['success'] == true && res['news'] is List) {
      return (res['news'] as List)
          .whereType<Map>()
          .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Full article body for the in-app reader (server fetches + caches it lazily).
  static Future<String> getArticleContent(String id) async {
    if (id.isEmpty) return '';
    final res = await ApiService.get('/api/news/$id/content');
    if (res['success'] == true && res['content'] is String) {
      return res['content'] as String;
    }
    return '';
  }

  /// The user's currently selected topics (≤3).
  static Future<List<String>> getTopics() async {
    final res = await ApiService.get('/api/user/topics');
    if (res['success'] == true && res['topics'] is List) {
      return List<String>.from(
          (res['topics'] as List).map((e) => e.toString()));
    }
    return [];
  }

  /// Save the user's chosen topics (≤3, validated server-side).
  static Future<bool> saveTopics(List<String> topics) async {
    final res = await ApiService.put('/api/user/topics', {'topics': topics});
    return res['success'] == true;
  }

  /// Current topics plus whether the user may still change them for free.
  /// Returns: { topics: List<String>, canEditFree: bool, pro: bool }.
  static Future<Map<String, dynamic>> getTopicsStatus() async {
    final res = await ApiService.get('/api/user/topics');
    return {
      'topics': res['topics'] is List
          ? List<String>.from((res['topics'] as List).map((e) => e.toString()))
          : <String>[],
      'canEditFree': res['canEditFree'] == true,
      'pro': res['pro'] == true,
    };
  }

  /// Update topics, returning the full server response so callers can detect
  /// the Pro gate ({ success, requiresPro, canEditFree, ... }).
  static Future<Map<String, dynamic>> updateTopics(List<String> topics) async {
    return await ApiService.put('/api/user/topics', {'topics': topics});
  }

  /// Full-text search across the whole news pool (all topics, incl. dismissed).
  static Future<List<NewsArticle>> search(String query,
      {String? topic, int limit = 30}) async {
    final params = <String, String>{'limit': '$limit'};
    if (query.trim().isNotEmpty) params['q'] = query.trim();
    if (topic != null && topic.isNotEmpty) params['topic'] = topic;
    final qs = params.entries
        .map((e) => '${e.key}=${Uri.encodeQueryComponent(e.value)}')
        .join('&');
    final res = await ApiService.get('/api/news/search?$qs');
    if (res['success'] == true && res['news'] is List) {
      return (res['news'] as List)
          .whereType<Map>()
          .map((e) => NewsArticle.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  /// Hide an article from this user's feed (kept in the pool for search).
  static Future<bool> dismiss(String id) async {
    if (id.isEmpty) return false;
    final res = await ApiService.post('/api/news/$id/dismiss', {});
    return res['success'] == true;
  }

  /// Undo a dismissal — the article returns to the feed.
  static Future<bool> undismiss(String id) async {
    if (id.isEmpty) return false;
    final res = await ApiService.delete('/api/news/$id/dismiss');
    return res['success'] == true;
  }

  static Future<ArticleModel?> generateArticle({
    required String topic,
    String style = 'news',
    String length = 'medium',
    String tone = 'neutral',
    String sources = '',
  }) async {
    final response = await ApiService.post(ApiConfig.generateNews, {
      'topic': topic,
      'style': style,
      'length': length,
      'tone': tone,
      'sources': sources,
    });

    if (response['error'] != null) {
      throw Exception(response['error']);
    }

    if (response['upgradeRequired'] == true) {
      throw Exception('USAGE_LIMIT_EXCEEDED');
    }

    return ArticleModel.fromJson(response);
  }

  /// Translate-picker languages for the CURRENT engine (admin-configured):
  /// LibreTranslate ⇒ only its supported Indian languages + Urdu; LLM ⇒ full
  /// Indian list. Returns [{code, name}].
  static Future<List<Map<String, String>>> getTranslateLanguages() async {
    final res = await ApiService.get('/api/agents/translate/languages');
    if (res['success'] == true && res['languages'] is List) {
      return (res['languages'] as List).whereType<Map>().map((e) {
        return {
          'code': (e['code'] ?? '').toString(),
          'name': (e['name'] ?? '').toString(),
        };
      }).toList();
    }
    return [];
  }

  static Future<Map<String, dynamic>> translate({
    required String content,
    required String targetLanguage,
  }) async {
    final response = await ApiService.post(ApiConfig.translate, {
      'content': content,
      'target_language': targetLanguage,
    });

    if (response['upgradeRequired'] == true) {
      throw Exception('USAGE_LIMIT_EXCEEDED');
    }

    if (response['success'] == false) {
      throw Exception(response['message'] ?? 'Translation failed');
    }

    return response;
  }
}
