import 'dart:async';
import '../models/subscription_model.dart';
import 'api_service.dart';

/// Service for managing news subscriptions
class SubscriptionService {
  static const String _baseUrl = '/api/subscriptions';

  /// Get all subscriptions for the current user
  static Future<List<Subscription>> getSubscriptions({
    bool activeOnly = true,
  }) async {
    try {
      final response = await ApiService.get(
        '$_baseUrl?activeOnly=$activeOnly',
      );

      if (response['success'] == true) {
        final List<dynamic> subscriptions = response['subscriptions'] ?? [];
        return subscriptions
            .map((json) => Subscription.fromJson(json))
            .toList();
      }

      return [];
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return [];
    }
  }

  /// Get a specific subscription by ID
  static Future<Subscription?> getSubscription(String id) async {
    try {
      final response = await ApiService.get('$_baseUrl/$id');

      if (response['success'] == true) {
        return Subscription.fromJson(response['subscription']);
      }

      return null;
    } catch (e) {
      print('Error fetching subscription: $e');
      return null;
    }
  }

  /// Create a new subscription
  /// Returns a tuple of [Subscription?, String? errorMessage]
  static Future<({Subscription? subscription, String? error})>
      createSubscription({
    required String topic,
    String customPrompt = '',
    int wordCount = 500,
    ArticleStyle style = ArticleStyle.news,
    ArticleTone tone = ArticleTone.neutral,
    SubscriptionFrequency frequency = SubscriptionFrequency.daily,
    List<int> preferredTimes = const [9],
    List<int> preferredDays = const [],
    List<String> deliveryChannels = const ['inApp'],
    String language = 'en',
    DateTime? startDate,
    DateTime? endDate,
    bool runImmediately = false,
  }) async {
    try {
      final response = await ApiService.post(_baseUrl, {
        'topic': topic,
        'customPrompt': customPrompt,
        'wordCount': wordCount,
        'style': style.value,
        'tone': tone.value,
        'frequency': frequency.value,
        'preferredTimes': preferredTimes,
        'preferredDays': preferredDays,
        'deliveryChannels': deliveryChannels,
        'language': language,
        'runImmediately': runImmediately,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
      });

      print('Create subscription response: $response');

      if (response['success'] == true) {
        final sub = Subscription.fromJson(response['subscription']);
        return (subscription: sub, error: null);
      }

      // Return error message for debugging
      final String message = response['message'] ?? 'Unknown error';
      print('Subscription creation failed: $message');
      return (subscription: null, error: message);
    } catch (e) {
      print('Error creating subscription: $e');
      return (subscription: null, error: e.toString());
    }
  }

  /// Update a subscription
  static Future<Subscription?> updateSubscription(
    String id, {
    String? topic,
    String? customPrompt,
    int? wordCount,
    ArticleStyle? style,
    ArticleTone? tone,
    SubscriptionFrequency? frequency,
    List<int>? preferredTimes,
    List<int>? preferredDays,
    List<String>? deliveryChannels,
    String? language,
    bool? isActive,
    DateTime? endDate,
  }) async {
    try {
      final body = <String, dynamic>{};

      if (topic != null) body['topic'] = topic;
      if (customPrompt != null) body['customPrompt'] = customPrompt;
      if (wordCount != null) body['wordCount'] = wordCount;
      if (style != null) body['style'] = style.value;
      if (tone != null) body['tone'] = tone.value;
      if (frequency != null) body['frequency'] = frequency.value;
      if (preferredTimes != null) body['preferredTimes'] = preferredTimes;
      if (preferredDays != null) body['preferredDays'] = preferredDays;
      if (deliveryChannels != null) body['deliveryChannels'] = deliveryChannels;
      if (language != null) body['language'] = language;
      if (isActive != null) body['isActive'] = isActive;
      if (endDate != null) body['endDate'] = endDate.toIso8601String();

      final response = await ApiService.put('$_baseUrl/$id', body);

      if (response['success'] == true) {
        return Subscription.fromJson(response['subscription']);
      }

      return null;
    } catch (e) {
      print('Error updating subscription: $e');
      return null;
    }
  }

  /// Delete a subscription
  static Future<bool> deleteSubscription(String id) async {
    try {
      final response = await ApiService.delete('$_baseUrl/$id');
      return response['success'] == true;
    } catch (e) {
      print('Error deleting subscription: $e');
      return false;
    }
  }

  /// Manually trigger news generation for a subscription
  static Future<GeneratedNews?> generateNews(String subscriptionId) async {
    try {
      final response = await ApiService.post(
        '$_baseUrl/$subscriptionId/generate',
        {},
      );

      if (response['success'] == true) {
        return GeneratedNews.fromJson(response['news']);
      }

      return null;
    } catch (e) {
      print('Error generating news: $e');
      return null;
    }
  }

  /// Get all generated news for the current user
  static Future<List<GeneratedNews>> getGeneratedNews({
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    try {
      final response = await ApiService.get(
        '$_baseUrl/news/all?limit=$limit&unreadOnly=$unreadOnly',
      );

      if (response['success'] == true) {
        final List<dynamic> news = response['news'] ?? [];
        return news.map((json) => GeneratedNews.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      print('Error fetching generated news: $e');
      return [];
    }
  }

  /// Get a specific generated news article
  static Future<GeneratedNews?> getNewsArticle(String newsId) async {
    try {
      final response = await ApiService.get('$_baseUrl/news/$newsId');

      if (response['success'] == true) {
        return GeneratedNews.fromJson(response['news']);
      }

      return null;
    } catch (e) {
      print('Error fetching news article: $e');
      return null;
    }
  }

  /// Toggle save status for a news article
  static Future<bool> toggleSaveNews(String newsId) async {
    try {
      final response = await ApiService.put('$_baseUrl/news/$newsId/save', {});
      return response['success'] == true;
    } catch (e) {
      print('Error toggling save: $e');
      return false;
    }
  }

  /// Mark a news article as read (dismissed)
  static Future<bool> markAsRead(String newsId) async {
    try {
      final response = await ApiService.put('$_baseUrl/news/$newsId/read', {});
      return response['success'] == true;
    } catch (e) {
      print('Error marking as read: $e');
      return false;
    }
  }

  /// Submit feedback for a news article
  static Future<bool> submitFeedback(
    String newsId, {
    int? rating,
    String? comment,
  }) async {
    try {
      final response = await ApiService.post(
        '$_baseUrl/news/$newsId/feedback',
        {
          if (rating != null) 'rating': rating,
          if (comment != null) 'comment': comment,
        },
      );

      return response['success'] == true;
    } catch (e) {
      print('Error submitting feedback: $e');
      return false;
    }
  }

  /// Get subscription statistics
  static Future<SubscriptionStats?> getStats() async {
    try {
      final response = await ApiService.get('$_baseUrl/stats/overview');

      if (response['success'] == true) {
        return SubscriptionStats.fromJson(response['stats']);
      }

      return null;
    } catch (e) {
      print('Error fetching stats: $e');
      return null;
    }
  }

  /// Get unread news count
  static Future<int> getUnreadCount() async {
    try {
      final response = await ApiService.get('$_baseUrl/news/all?limit=1');

      if (response['success'] == true) {
        return response['unreadCount'] ?? 0;
      }

      return 0;
    } catch (e) {
      print('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Get Stripe Checkout URL for Pro upgrade
  static Future<String?> getCheckoutUrl({
    required String planId,
    required String billingCycle,
    required String userId,
  }) async {
    try {
      final response = await ApiService.post(
        '/api/payment/create-checkout-session',
        {
          'planId': planId,
          'billingCycle': billingCycle,
          'userId': userId,
        },
      );

      if (response['success'] == true) {
        return response['url'];
      }
      return null;
    } catch (e) {
      print('Error getting checkout URL: $e');
      return null;
    }
  }

  /// Redeem an admin-issued promo code to activate Pro. Returns the full server
  /// response: { success, message, subscription }.
  static Future<Map<String, dynamic>> redeemPromoCode(String code) async {
    try {
      final response = await ApiService.post(
        '/api/payment/redeem-promo',
        {'code': code.trim()},
      );
      return Map<String, dynamic>.from(response);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }
}
