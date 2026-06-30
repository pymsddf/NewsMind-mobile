import '../config/api_config.dart';
import 'api_service.dart';

class AuthService {
  // Demo mode credentials for testing without backend
  static const String demoEmail = 'demo@newsmind.com';
  static const String demoPassword = 'Demo@123456';
  static const String demoToken = 'demo_token_for_testing_purposes';

  static bool get isDemoMode =>
      false; // Disabled demo mode to connect to real backend

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    // Demo mode - allow login with demo credentials
    if (isDemoMode) {
      if (email == demoEmail && password == demoPassword) {
        await ApiService.setToken(demoToken);
        return {
          'success': true,
          'token': demoToken,
          'user': {
            'id': 'demo_user_123',
            'name': 'Demo User',
            'email': demoEmail,
            'role': 'Reporter',
            'pro': false,
          }
        };
      } else {
        return {
          'success': false,
          'message': 'Invalid credentials. Use demo@newsmind.com / Demo@123456'
        };
      }
    }

    final response = await ApiService.post(ApiConfig.login, {
      'email': email,
      'password': password,
    });

    if (response['success'] == true && response['token'] != null) {
      await ApiService.setToken(response['token']);
    }

    return response;
  }

  static Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    // Demo mode
    if (isDemoMode) {
      return {
        'success': true,
        'message': 'Registration successful (Demo Mode). Please login.'
      };
    }

    return await ApiService.post(ApiConfig.register, {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }

  static Future<void> logout() async {
    try {
      if (!isDemoMode) {
        await ApiService.post(ApiConfig.logout, {});
      }
    } catch (_) {}
    await ApiService.clearToken();
  }

  // Clerk social auth (Google/Facebook) using backend upsert endpoint.
  // role is required for first social signup.
  static Future<Map<String, dynamic>> clerkAuth({
    required String clerkUserId,
    required String email,
    required String name,
    required String provider,
    String? role,
    String? avatarUrl,
    String? mode,
  }) async {
    final response = await ApiService.post(ApiConfig.clerkAuth, {
      'clerkUserId': clerkUserId,
      'email': email,
      'name': name,
      'provider': provider,
      'role': role,
      'avatarUrl': avatarUrl,
      'mode': mode,
    });

    if (response['success'] == true && response['token'] != null) {
      await ApiService.setToken(response['token']);
    }

    return response;
  }

  static Future<void> submitLogoutFeedback({
    int? rating,
    String? comment,
  }) async {
    if (rating != null && (rating < 1 || rating > 5)) return;
    try {
      if (!isDemoMode) {
        final payload = <String, dynamic>{
          'platform': 'mobile',
          'comment': (comment ?? '').trim(),
        };
        if (rating != null) payload['rating'] = rating;
        await ApiService.post(ApiConfig.logoutFeedback, payload);
      }
    } catch (_) {}
  }

  static Future<Map<String, dynamic>> sendResetOtp(String email) async {
    // Demo mode
    if (isDemoMode) {
      return {
        'success': true,
        'message': 'OTP sent to your email (Demo Mode). Use: 123456'
      };
    }

    return await ApiService.post(ApiConfig.sendResetOtp, {'email': email});
  }

  static Future<Map<String, dynamic>> resetPassword(
      String email, String otp, String newPassword) async {
    // Demo mode
    if (isDemoMode) {
      if (otp == '123456') {
        return {
          'success': true,
          'message': 'Password reset successfully (Demo Mode)'
        };
      }
      return {'success': false, 'message': 'Invalid OTP. Use: 123456'};
    }

    return await ApiService.post(ApiConfig.resetPassword, {
      'email': email,
      'otp': otp,
      'newPassword': newPassword,
    });
  }

  static Future<Map<String, dynamic>> sendVerifyOtp() async {
    // Demo mode
    if (isDemoMode) {
      return {
        'success': true,
        'message': 'OTP sent to your email (Demo Mode). Use: 123456'
      };
    }

    return await ApiService.post(ApiConfig.sendVerifyOtp, {});
  }

  static Future<Map<String, dynamic>> verifyAccount(String otp) async {
    // Demo mode
    if (isDemoMode) {
      if (otp == '123456') {
        return {
          'success': true,
          'message': 'Account verified successfully (Demo Mode)'
        };
      }
      return {'success': false, 'message': 'Invalid OTP. Use: 123456'};
    }

    return await ApiService.post(ApiConfig.verifyAccount, {'otp': otp});
  }

  /// Registration-flow OTP verify (no auth token; user identified by email).
  /// On success the backend returns a token — store it so the user is logged in.
  static Future<Map<String, dynamic>> verifyAccountPublic(
      String email, String otp) async {
    if (isDemoMode) {
      return otp == '123456'
          ? {'success': true, 'message': 'Account verified (Demo Mode)'}
          : {'success': false, 'message': 'Invalid OTP. Use: 123456'};
    }

    final response = await ApiService.post(
      ApiConfig.verifyAccountPublic,
      {'email': email, 'otp': otp},
    );
    if (response['success'] == true && response['token'] != null) {
      await ApiService.setToken(response['token']);
    }
    return response;
  }

  /// Resend the registration-flow OTP (no auth token; identified by email).
  static Future<Map<String, dynamic>> resendVerifyOtpPublic(
      String email) async {
    if (isDemoMode) {
      return {
        'success': true,
        'message': 'OTP resent (Demo Mode). Use: 123456'
      };
    }
    return await ApiService.post(
      ApiConfig.sendVerifyOtpPublic,
      {'email': email},
    );
  }

  static Future<bool> isAuthenticated() async {
    // Demo mode
    if (isDemoMode) {
      final token = await ApiService.getToken();
      return token != null && token.isNotEmpty;
    }

    final response = await ApiService.post(ApiConfig.isAuth, {});
    return response['success'] == true;
  }
}
