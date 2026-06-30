import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  static const String _productionBaseUrl = 'https://newsmindexp.ddfrl.com';

  // Highest priority: explicit override via --dart-define=API_BASE_URL=...
  static const String _apiBaseUrlFromEnv =
      String.fromEnvironment('API_BASE_URL', defaultValue: '');

  // Google Sign-In Client ID for Web (via --dart-define=GOOGLE_CLIENT_ID=...)
  static const String googleClientId =
      String.fromEnvironment('GOOGLE_CLIENT_ID', defaultValue: '');

  static String get baseUrl {
    if (_apiBaseUrlFromEnv.isNotEmpty) {
      return _apiBaseUrlFromEnv;
    }

    if (kIsWeb) {
      // Default to production so web runs/demos work out of the box.
      // Can be overridden locally with --dart-define=API_BASE_URL=http://localhost:4000
      return _productionBaseUrl;
    } else if (Platform.isAndroid) {
      // Android app should hit deployed backend by default.
      return _productionBaseUrl;
    } else {
      // Default for iOS emulator or other platforms
      return 'http://localhost:4000';
    }
  }

  /// Wrap a remote image URL in our backend image proxy so it loads with CORS
  /// headers (Flutter web/CanvasKit needs them; some publisher CDNs like
  /// static.toiimg.com don't send them). Returns null/empty unchanged.
  static String? proxiedImage(String? url) {
    if (url == null || url.isEmpty) return url;
    return '$baseUrl/api/news/image?url=${Uri.encodeQueryComponent(url)}';
  }

  // API endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String sendVerifyOtp = '/api/auth/send-verify-otp';
  static const String verifyAccount = '/api/auth/verify-account';
  // Public (no auth token) registration-flow verification — identified by email.
  static const String sendVerifyOtpPublic = '/api/auth/send-verify-otp-public';
  static const String verifyAccountPublic = '/api/auth/verify-account-public';
  static const String isAuth = '/api/auth/is-auth';
  static const String sendResetOtp = '/api/auth/send-reset-otp';
  static const String resetPassword = '/api/auth/reset-password';
  static const String clerkAuth = '/api/auth/clerk-auth';

  static const String userData = '/api/user/data';
  static const String updateProfile = '/api/user/update-profile';
  static const String updateSecurity = '/api/user/update-security';
  static const String logoutFeedback = '/api/user/logout-feedback';
  static const String usageStats = '/api/user/usage-stats';
  static const String checkUsage = '/api/user/check-usage';
  static const String history = '/api/user/history';
  static const String clearHistory = '/api/user/history';
  static const String deleteHistory =
      '/api/user/history'; // Append /:id in code
  static const String submitFeedback =
      '/api/history/feedback'; // Append /:id in code
  static const String verificationHistory =
      '/api/user/history?type=verification';
  static const String biasHistory = '/api/user/history?type=bias';
  static const String sessionHistory = '/api/sessions/history';
  static const String notifications = '/api/user/notifications';
  static const String markNotificationRead = '/api/user/notifications/read';
  static const String markAllNotificationsRead =
      '/api/user/notifications/read-all';
  static const String generateNews = '/api/agents/news';
  static const String verifyFact = '/api/agents/verify';
  static const String analyzeBias = '/api/agents/bias';
  static const String translate = '/api/agents/translate';

  // Subscription endpoints
  static const String subscriptions = '/api/subscriptions';
  static const String subscriptionNews = '/api/subscriptions/news/all';
  static const String subscriptionStats = '/api/subscriptions/stats/overview';
  static const String createCheckoutSession =
      '/api/payment/create-checkout-session';
}
