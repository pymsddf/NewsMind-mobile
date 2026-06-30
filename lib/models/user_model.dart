class UserModel {
  final String? id;
  final String name;
  final String email;
  final String role;
  final bool isAccountVerified;
  final bool pro;
  final String? planId;
  final String? billingCycle;
  final String? joinDate;
  final DateTime? createdAt;
  final DateTime? subscriptionEndDate;
  final bool loginNotifications;
  final UsageModel? usage;

  /// Chosen daily-feed topics (max 3). Empty ⇒ onboarding not yet completed.
  final List<String> topics;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    this.role = 'Reporter',
    this.isAccountVerified = false,
    this.pro = false,
    this.planId,
    this.billingCycle,
    this.joinDate,
    this.createdAt,
    this.subscriptionEndDate,
    this.loginNotifications = true,
    this.usage,
    this.topics = const [],
  });

  /// True once the user has picked at least one topic in onboarding.
  bool get hasTopics => topics.isNotEmpty;

  static String normalizeRole(dynamic rawRole) {
    final role = (rawRole ?? '').toString().trim().toLowerCase();

    if (role == 'admin') return 'Admin';
    if (role == 'reporter' || role == 'repoter' || role == 'journalist' || role == 'analyst') {
      return 'Reporter';
    }
    if (role == 'editor' || role == 'etitor') return 'Editor';
    if (role == 'basic' || role == 'user' || role == 'viewer') return 'Basic';

    return 'Basic';
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: normalizeRole(json['role']),
      isAccountVerified: json['isAccountVerified'] ?? false,
      pro: json['pro'] ?? false,
      planId: json['planId'],
      billingCycle: json['billingCycle'],
      joinDate: json['createdAt'],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      subscriptionEndDate: json['subscriptionEndDate'] != null ? DateTime.tryParse(json['subscriptionEndDate']) : null,
      loginNotifications: json['loginNotifications'] ?? true,
      usage: json['usage'] != null ? UsageModel.fromJson(json['usage']) : null,
      topics: (json['topics'] is List)
          ? List<String>.from((json['topics'] as List).map((e) => e.toString()))
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'isAccountVerified': isAccountVerified,
      'pro': pro,
      'planId': planId,
      'billingCycle': billingCycle,
      'loginNotifications': loginNotifications,
      'topics': topics,
    };
  }
}

class UsageModel {
  final UsageItem newsGenerations;
  final UsageItem verifications;
  final UsageItem biasDetections;

  UsageModel({
    required this.newsGenerations,
    required this.verifications,
    required this.biasDetections,
  });

  factory UsageModel.fromJson(Map<String, dynamic> json) {
    return UsageModel(
      newsGenerations: UsageItem.fromJson(json['newsGenerations'] ?? {}),
      verifications: UsageItem.fromJson(json['verifications'] ?? {}),
      biasDetections: UsageItem.fromJson(json['biasDetections'] ?? {}),
    );
  }
}

class UsageItem {
  final int used;
  final int limit;

  UsageItem({required this.used, required this.limit});

  bool get isUnlimited => limit < 0;
  int get remaining => isUnlimited ? -1 : (limit - used).clamp(0, limit);
  double get percentage => (limit > 0) ? (used / limit).clamp(0.0, 1.0) : 0.0;

  static int _parseCount(dynamic value, {int fallback = 0}) {
    if (value == null) return fallback;
    if (value is int) return value;
    if (value is num) return value.toInt();

    final str = value.toString().trim();
    if (str.isEmpty) return fallback;
    if (str.toLowerCase() == 'unlimited') return -1;

    final parsed = int.tryParse(str);
    return parsed ?? fallback;
  }

  factory UsageItem.fromJson(Map<String, dynamic> json) {
    return UsageItem(
      used: _parseCount(json['used'], fallback: 0),
      limit: _parseCount(json['limit'], fallback: 5),
    );
  }
}
