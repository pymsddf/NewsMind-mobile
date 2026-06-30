import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/otp_verification_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/onboarding_topics_screen.dart';
import '../screens/notification_screen.dart';
import '../screens/history_screen.dart';
import '../screens/news_search_screen.dart';

class NewsMindRouter {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/',
      refreshListenable: authProvider,
      redirect: (context, state) {
        final isLoggedIn = authProvider.isLoggedIn;
        final isGoingToLogin = state.matchedLocation == '/login';
        final isGoingToRegister = state.matchedLocation == '/register';
        final isGoingToSplash = state.matchedLocation == '/';
        final isGoingToForgotPassword =
            state.matchedLocation == '/forgot-password';
        final isGoingToVerifyOtp = state.matchedLocation == '/verify-otp';
        final isGoingToOnboarding = state.matchedLocation == '/onboarding';

        if (!isLoggedIn) {
          if (isGoingToLogin ||
              isGoingToRegister ||
              isGoingToForgotPassword ||
              isGoingToVerifyOtp ||
              isGoingToSplash) {
            return null;
          }
          return '/login';
        }

        // First-login gate: a logged-in user who hasn't picked topics must
        // onboard before reaching the rest of the app. Splash is exempt (it
        // navigates onward itself once auth + onboarding state are resolved).
        if (authProvider.needsOnboarding &&
            !isGoingToOnboarding &&
            !isGoingToSplash) {
          return '/onboarding';
        }
        if (!authProvider.needsOnboarding && isGoingToOnboarding) {
          return '/home';
        }

        // Direct logged-in users away from auth pages to home.
        if (isGoingToLogin || isGoingToRegister) {
          return '/home';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => RegisterScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/verify-otp',
          builder: (context, state) =>
              OtpVerificationScreen(email: (state.extra as String?) ?? ''),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => OnboardingTopicsScreen(),
        ),
        GoRoute(
          path: '/topics',
          builder: (context, state) =>
              const OnboardingTopicsScreen(isEdit: true),
        ),
        GoRoute(
          path: '/notifications',
          builder: (context, state) => NotificationScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => HistoryScreen(),
        ),
        GoRoute(
          path: '/search',
          builder: (context, state) => const NewsSearchScreen(),
        ),
      ],
    );
  }
}
