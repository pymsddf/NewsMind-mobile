

/// Frequency options for news subscription
enum SubscriptionFrequency {
  daily,
  weekly,
  biweekly,
  monthly,
}

/// Extension to convert frequency to display string
extension SubscriptionFrequencyExtension on SubscriptionFrequency {
  String get displayName {
    switch (this) {
      case SubscriptionFrequency.daily:
        return 'Daily';
      case SubscriptionFrequency.weekly:
        return 'Weekly';
      case SubscriptionFrequency.biweekly:
        return 'Bi-weekly';
      case SubscriptionFrequency.monthly:
        return 'Monthly';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static SubscriptionFrequency fromString(String value) {
    return SubscriptionFrequency.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SubscriptionFrequency.daily,
    );
  }
}

/// Article style options
enum ArticleStyle {
  news,
  analysis,
  opinion,
  summary,
}

extension ArticleStyleExtension on ArticleStyle {
  String get displayName {
    switch (this) {
      case ArticleStyle.news:
        return 'News';
      case ArticleStyle.analysis:
        return 'Analysis';
      case ArticleStyle.opinion:
        return 'Opinion';
      case ArticleStyle.summary:
        return 'Summary';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static ArticleStyle fromString(String value) {
    return ArticleStyle.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ArticleStyle.news,
    );
  }
}

/// Article tone options
enum ArticleTone {
  neutral,
  formal,
  casual,
  professional,
}

extension ArticleToneExtension on ArticleTone {
  String get displayName {
    switch (this) {
      case ArticleTone.neutral:
        return 'Neutral';
      case ArticleTone.formal:
        return 'Formal';
      case ArticleTone.casual:
        return 'Casual';
      case ArticleTone.professional:
        return 'Professional';
    }
  }

  String get value {
    return toString().split('.').last;
  }

  static ArticleTone fromString(String value) {
    return ArticleTone.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ArticleTone.neutral,
    );
  }
}

/// Subscription model for personalized news
class Subscription {
  final String id;
  final String userId;
  final String topic;
  final String customPrompt;
  final int wordCount;
  final ArticleStyle style;
  final ArticleTone tone;
  final SubscriptionFrequency frequency;
  final List<int> preferredTimes;
  final List<int> preferredDays;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final List<String> deliveryChannels;
  final String language;
  final DateTime? lastGeneratedAt;
  final DateTime? nextScheduledAt;
  final int totalGenerated;
  final int totalRead;
  final DateTime createdAt;
  final DateTime updatedAt;

  Subscription({
    required this.id,
    required this.userId,
    required this.topic,
    this.customPrompt = '',
    this.wordCount = 500,
    this.style = ArticleStyle.news,
    this.tone = ArticleTone.neutral,
    this.frequency = SubscriptionFrequency.daily,
    this.preferredTimes = const [9],
    this.preferredDays = const [],
    required this.startDate,
    this.endDate,
    this.isActive = true,
    this.deliveryChannels = const ['inApp'],
    this.language = 'en',
    this.lastGeneratedAt,
    this.nextScheduledAt,
    this.totalGenerated = 0,
    this.totalRead = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      topic: json['topic'] ?? '',
      customPrompt: json['customPrompt'] ?? '',
      wordCount: json['wordCount'] ?? 500,
      style: ArticleStyleExtension.fromString(json['style'] ?? 'news'),
      tone: ArticleToneExtension.fromString(json['tone'] ?? 'neutral'),
      frequency: SubscriptionFrequencyExtension.fromString(
        json['frequency'] ?? 'daily',
      ),
      preferredTimes: List<int>.from(json['preferredTimes'] ?? [9]),
      preferredDays: List<int>.from(json['preferredDays'] ?? []),
      startDate: DateTime.tryParse(json['startDate'] ?? '') ?? DateTime.now(),
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'])
          : null,
      isActive: json['isActive'] ?? true,
      deliveryChannels: List<String>.from(
        json['deliveryChannels'] ?? ['inApp'],
      ),
      language: json['language'] ?? 'en',
      lastGeneratedAt: json['lastGeneratedAt'] != null
          ? DateTime.tryParse(json['lastGeneratedAt'])
          : null,
      nextScheduledAt: json['nextScheduledAt'] != null
          ? DateTime.tryParse(json['nextScheduledAt'])
          : null,
      totalGenerated: json['totalGenerated'] ?? 0,
      totalRead: json['totalRead'] ?? 0,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'topic': topic,
      'customPrompt': customPrompt,
      'wordCount': wordCount,
      'style': style.value,
      'tone': tone.value,
      'frequency': frequency.value,
      'preferredTimes': preferredTimes,
      'preferredDays': preferredDays,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'deliveryChannels': deliveryChannels,
      'language': language,
      'totalGenerated': totalGenerated,
      'totalRead': totalRead,
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? topic,
    String? customPrompt,
    int? wordCount,
    ArticleStyle? style,
    ArticleTone? tone,
    SubscriptionFrequency? frequency,
    List<int>? preferredTimes,
    List<int>? preferredDays,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List<String>? deliveryChannels,
    String? language,
    DateTime? lastGeneratedAt,
    DateTime? nextScheduledAt,
    int? totalGenerated,
    int? totalRead,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      topic: topic ?? this.topic,
      customPrompt: customPrompt ?? this.customPrompt,
      wordCount: wordCount ?? this.wordCount,
      style: style ?? this.style,
      tone: tone ?? this.tone,
      frequency: frequency ?? this.frequency,
      preferredTimes: preferredTimes ?? this.preferredTimes,
      preferredDays: preferredDays ?? this.preferredDays,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      deliveryChannels: deliveryChannels ?? this.deliveryChannels,
      language: language ?? this.language,
      lastGeneratedAt: lastGeneratedAt ?? this.lastGeneratedAt,
      nextScheduledAt: nextScheduledAt ?? this.nextScheduledAt,
      totalGenerated: totalGenerated ?? this.totalGenerated,
      totalRead: totalRead ?? this.totalRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Generated news model
class GeneratedNews {
  final String id;
  final String subscriptionId;
  final String userId;
  final String topic;
  final String title;
  final String content;
  final String summary;
  final int wordCount;
  final ArticleStyle style;
  final ArticleTone tone;
  final String language;
  final List<NewsSource> sources;
  final VerificationStatus verificationStatus;
  final BiasAnalysis biasAnalysis;
  final bool isRead;
  final bool isSaved;
  final bool isShared;
  final DateTime generatedAt;
  final DateTime scheduledFor;

  GeneratedNews({
    required this.id,
    required this.subscriptionId,
    required this.userId,
    required this.topic,
    required this.title,
    required this.content,
    this.summary = '',
    this.wordCount = 500,
    this.style = ArticleStyle.news,
    this.tone = ArticleTone.neutral,
    this.language = 'en',
    this.sources = const [],
    required this.verificationStatus,
    required this.biasAnalysis,
    this.isRead = false,
    this.isSaved = false,
    this.isShared = false,
    required this.generatedAt,
    required this.scheduledFor,
  });

  factory GeneratedNews.fromJson(Map<String, dynamic> json) {
    return GeneratedNews(
      id: json['_id'] ?? json['id'] ?? '',
      subscriptionId: json['subscriptionId'] is Map
          ? (json['subscriptionId']['_id'] ?? json['subscriptionId']['id'] ?? '').toString()
          : (json['subscriptionId'] ?? '').toString(),
      userId: json['userId'] is Map
          ? (json['userId']['_id'] ?? json['userId']['id'] ?? '').toString()
          : (json['userId'] ?? '').toString(),
      topic: json['topic'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      summary: json['summary'] ?? '',
      wordCount: json['wordCount'] ?? 500,
      style: ArticleStyleExtension.fromString(json['style'] ?? 'news'),
      tone: ArticleToneExtension.fromString(json['tone'] ?? 'neutral'),
      language: json['language'] ?? 'en',
      sources: (json['sources'] as List?)
          ?.map((s) => NewsSource.fromJson(s))
          .toList() ?? [],
      verificationStatus: VerificationStatus.fromJson(
        json['verificationStatus'] ?? {},
      ),
      biasAnalysis: BiasAnalysis.fromJson(json['biasAnalysis'] ?? {}),
      isRead: json['isRead'] ?? false,
      isSaved: json['isSaved'] ?? false,
      isShared: json['isShared'] ?? false,
      generatedAt: DateTime.tryParse(json['generatedAt'] ?? '') ?? DateTime.now(),
      scheduledFor: DateTime.tryParse(json['scheduledFor'] ?? '') ?? DateTime.now(),
    );
  }
}

/// News source model
class NewsSource {
  final String title;
  final String url;
  final String domain;

  NewsSource({
    required this.title,
    required this.url,
    required this.domain,
  });

  factory NewsSource.fromJson(Map<String, dynamic> json) {
    return NewsSource(
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      domain: json['domain'] ?? '',
    );
  }
}

/// Verification status model
class VerificationStatus {
  final String verdict;
  final int confidence;
  final int credibilityScore;

  VerificationStatus({
    this.verdict = 'not_verified',
    this.confidence = 0,
    this.credibilityScore = 0,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      verdict: json['verdict'] ?? 'not_verified',
      confidence: json['confidence'] ?? 0,
      credibilityScore: json['credibilityScore'] ?? 0,
    );
  }
}

/// Bias analysis model
class BiasAnalysis {
  final String overallLabel;
  final String confidence;

  BiasAnalysis({
    this.overallLabel = 'unknown',
    this.confidence = 'low',
  });

  factory BiasAnalysis.fromJson(Map<String, dynamic> json) {
    return BiasAnalysis(
      overallLabel: json['overallLabel'] ?? 'unknown',
      confidence: json['confidence'] ?? 'low',
    );
  }
}

/// Subscription statistics model
class SubscriptionStats {
  final int activeSubscriptions;
  final int totalGenerated;
  final int unreadCount;
  final int savedCount;
  final List<TopicStats> topTopics;

  SubscriptionStats({
    this.activeSubscriptions = 0,
    this.totalGenerated = 0,
    this.unreadCount = 0,
    this.savedCount = 0,
    this.topTopics = const [],
  });

  factory SubscriptionStats.fromJson(Map<String, dynamic> json) {
    return SubscriptionStats(
      activeSubscriptions: json['activeSubscriptions'] ?? 0,
      totalGenerated: json['totalGenerated'] ?? 0,
      unreadCount: json['unreadCount'] ?? 0,
      savedCount: json['savedCount'] ?? 0,
      topTopics: (json['topTopics'] as List?)
          ?.map((t) => TopicStats.fromJson(t))
          .toList() ?? [],
    );
  }
}

/// Topic statistics model
class TopicStats {
  final String topic;
  final int count;

  TopicStats({
    required this.topic,
    required this.count,
  });

  factory TopicStats.fromJson(Map<String, dynamic> json) {
    return TopicStats(
      topic: json['_id'] ?? json['topic'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}