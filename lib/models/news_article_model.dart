import '../config/api_config.dart';

/// A real aggregated news article from the shared topic pool (`/api/news/feed`).
class NewsArticle {
  final String id;
  final String topic;
  final String title;
  final String summary;
  final String content;
  final String? imageUrl;
  final String sourceName;
  final String sourceUrl;
  final DateTime publishedAt;

  NewsArticle({
    required this.id,
    required this.topic,
    required this.title,
    this.summary = '',
    this.content = '',
    this.imageUrl,
    this.sourceName = '',
    this.sourceUrl = '',
    required this.publishedAt,
  });

  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final img = (json['imageUrl'] ?? '').toString();
    return NewsArticle(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      topic: (json['topic'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      summary: (json['summary'] ?? '').toString(),
      content: (json['content'] ?? '').toString(),
      imageUrl: img.isEmpty ? null : img,
      sourceName: (json['sourceName'] ?? '').toString(),
      sourceUrl: (json['sourceUrl'] ?? '').toString(),
      publishedAt:
          DateTime.tryParse((json['publishedAt'] ?? '').toString())?.toLocal() ??
              DateTime.now(),
    );
  }

  /// Image URL routed through the backend proxy so it renders on web (CORS).
  /// Null when the article has no image.
  String? get displayImageUrl => ApiConfig.proxiedImage(imageUrl);

  /// For local caching (shared_preferences). Round-trips with [fromJson].
  Map<String, dynamic> toJson() => {
        '_id': id,
        'topic': topic,
        'title': title,
        'summary': summary,
        'content': content,
        'imageUrl': imageUrl,
        'sourceName': sourceName,
        'sourceUrl': sourceUrl,
        'publishedAt': publishedAt.toIso8601String(),
      };
}
