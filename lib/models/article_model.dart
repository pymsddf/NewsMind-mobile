class ArticleModel {
  final String? id;
  final String? title;
  final String? content;
  final Map<String, dynamic>? parameters;
  final int? wordCount;
  final String? status;
  final String? createdAt;
  final String? historyId;

  ArticleModel({
    this.id, // the article id if any
    this.title,
    this.content,
    this.parameters,
    this.wordCount,
    this.status,
    this.createdAt,
    this.historyId,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id']?.toString(),
      title: json['title'],
      content: json['content'],
      parameters: json['parameters'] is Map ? Map<String, dynamic>.from(json['parameters']) : null,
      wordCount: json['wordCount'],
      status: json['status'],
      createdAt: json['createdAt'],
      historyId: json['historyId']?.toString() ?? json['_id']?.toString() ?? json['id']?.toString(),
    );
  }
  ArticleModel copyWith({
    String? id,
    String? title,
    String? content,
    Map<String, dynamic>? parameters,
    int? wordCount,
    String? status,
    String? createdAt,
    String? historyId,
  }) {
    return ArticleModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      parameters: parameters ?? this.parameters,
      wordCount: wordCount ?? this.wordCount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      historyId: historyId ?? this.historyId,
    );
  }
}
