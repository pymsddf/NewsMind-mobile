import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/news_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _isLoggedIn = false;
  bool _needsOnboarding = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;

  /// True when a logged-in user hasn't picked any topics yet → show onboarding.
  bool get needsOnboarding => _needsOnboarding;

  // Explicit getter for role to fix compilation issues
  String get role => _user?.role ?? 'Basic';

  // Check if user has access to generation feature
  bool get canGenerate {
    if (_user == null) return false;
    final roleLower = UserModel.normalizeRole(_user!.role).toLowerCase();
    return roleLower == 'reporter' ||
        roleLower == 'editor' ||
        roleLower == 'admin';
  }

  // Get navigation tabs based on user role
  List<int> get allowedTabs {
    if (canGenerate) {
      return [0, 1, 2, 3, 4]; // Feed, Generate, Verify, Bias, Profile
    }
    return [0, 2, 3, 4]; // Feed, Verify, Bias, Profile (no Generate)
  }

  Future<void> init() async {
    await ApiService.init();
    _isLoggedIn = ApiService.isLoggedIn;

    if (_isLoggedIn) {
      // Validate the stored token with the server. A locally-present token is
      // not proof of a live session — it can be expired or invalidated
      // (sessionVersion bump). If the server DEFINITIVELY rejects it, clear it
      // and route to login instead of trapping the user in a logged-in-but-
      // unauthorized state (couldn't save topics, stuck on onboarding, etc.).
      if (await _tokenDefinitelyInvalid()) {
        await AuthService.logout();
        _isLoggedIn = false;
        _user = null;
        notifyListeners();
        return;
      }

      // Try to load cached user first
      _user = await UserService.getCachedUser();
      notifyListeners();

      // Then refresh from server
      try {
        final freshUser = await UserService.getUserData();
        if (freshUser != null) {
          _user = freshUser;
          notifyListeners();
        }
      } catch (_) {}

      await _loadOnboardingState();
      notifyListeners();
    }
  }

  /// True only when the server explicitly rejects the token (expired / invalid
  /// / session-invalidated). A network error returns false so offline users
  /// stay signed in.
  Future<bool> _tokenDefinitelyInvalid() async {
    try {
      final res = await ApiService.post(ApiConfig.isAuth, {});
      if (res['success'] == true) return false;
      if (res['tokenExpired'] == true ||
          res['sessionInvalidated'] == true ||
          res['invalidToken'] == true) {
        return true;
      }
      final msg = (res['message'] ?? '').toString().toLowerCase();
      return msg.contains('authoriz') ||
          msg.contains('login again') ||
          msg.contains('session expired') ||
          msg.contains('invalid token');
    } catch (_) {
      return false; // network/other — don't punish offline users
    }
  }

  /// Resolve whether the user still needs to choose topics. Fails open (no
  /// onboarding) so a transient error never traps the user on the picker.
  Future<void> _loadOnboardingState() async {
    try {
      final topics = await NewsService.getTopics();
      _needsOnboarding = topics.isEmpty;
    } catch (_) {
      _needsOnboarding = false;
    }
  }

  /// Call after the user saves their topics in onboarding.
  void markOnboarded() {
    _needsOnboarding = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.login(email, password);

      if (response['success'] == true) {
        _isLoggedIn = true;

        // Fetch user data
        final userData = await UserService.getUserData();
        if (userData != null) {
          _user = userData;
        } else if (response['user'] is Map<String, dynamic>) {
          // Fallback: use login payload so profile/nav are not blank on slow /user/data calls
          _user = UserModel.fromJson(response['user'] as Map<String, dynamic>);
          await UserService.cacheUser(_user!);
        }
        await _loadOnboardingState();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> register(
      String name, String email, String password, String role) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.register(name, email, password, role);
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Registration-flow email verification. On success the user is verified and
  /// logged in (token stored by AuthService), so we hydrate auth state here.
  Future<Map<String, dynamic>> verifyEmail(String email, String otp) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.verifyAccountPublic(email, otp);

      if (response['success'] == true) {
        _isLoggedIn = true;

        final userData = await UserService.getUserData();
        if (userData != null) {
          _user = userData;
        } else if (response['userData'] is Map<String, dynamic>) {
          _user =
              UserModel.fromJson(response['userData'] as Map<String, dynamic>);
          await UserService.cacheUser(_user!);
        }
        await _loadOnboardingState();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Resend the registration-flow OTP to the given email.
  Future<Map<String, dynamic>> resendVerifyOtp(String email) async {
    try {
      return await AuthService.resendVerifyOtpPublic(email);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _user = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    final userData = await UserService.getUserData();
    if (userData != null) {
      _user = userData;
      notifyListeners();
      return;
    }

    // Keep UI usable if network refresh fails by falling back to cached user.
    if (_user == null) {
      final cached = await UserService.getCachedUser();
      if (cached != null) {
        _user = cached;
        notifyListeners();
      }
    }
  }

  Future<Map<String, dynamic>> loginWithClerk({
    required String clerkUserId,
    required String email,
    required String name,
    required String provider,
    String? role,
    String? avatarUrl,
    String? mode,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await AuthService.clerkAuth(
        clerkUserId: clerkUserId,
        email: email,
        name: name,
        provider: provider,
        role: role,
        avatarUrl: avatarUrl,
        mode: mode,
      );

      if (response['success'] == true) {
        _isLoggedIn = true;
        final userData = await UserService.getUserData();
        if (userData != null) {
          _user = userData;
        } else {
          _user = UserModel(
            name: name,
            email: email,
            role: role ?? 'Basic',
          );
          await UserService.cacheUser(_user!);
        }
        await _loadOnboardingState();
      }

      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<void> loadUser() => refreshUser();
}
