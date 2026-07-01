import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/auth_provider.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/sharp_input.dart';
import '../widgets/vector_button.dart';
import '../widgets/notizz_brand_title.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';
import '../utils/error_text.dart';

/// Get Started Screen - Consolidated form
///
/// Conversion Insight: Consolidation. Merge the fractured screens into a single efficient form.
/// inputs square and fine Slate Grey border with Electric Teal focus lines.
/// Headline Public Sans.
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final response = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Login successful!',
            style: AppTheme.textTheme.labelMedium?.copyWith(),
          ),
          backgroundColor: IntelligenceColors.electricTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Login failed',
            style: AppTheme.textTheme.labelMedium?.copyWith(),
          ),
          backgroundColor: IntelligenceColors.crimsonSpike,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb && ApiConfig.googleClientId.isNotEmpty
            ? ApiConfig.googleClientId
            : null,
        scopes: ['email', 'profile'],
      );
      await googleSignIn.signOut().catchError((_) => null);
      final account = await googleSignIn.signIn();
      if (account == null) return; // user cancelled

      final response = await authProvider.loginWithClerk(
        clerkUserId: 'google_${account.id}',
        email: account.email,
        name: account.displayName ?? account.email.split('@').first,
        provider: 'google',
        avatarUrl: account.photoUrl,
        mode: 'login',
      );

      if (!mounted) return;
      if (response['success'] != true) {
        final message = response['requiresRole'] == true
            ? 'No role found for this social account. Please sign up first and select a role.'
            : (response['message'] ?? 'Google sign-in failed');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message,
                style: AppTheme.textTheme.labelMedium?.copyWith()),
            backgroundColor: IntelligenceColors.crimsonSpike,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              friendlyError(e,
                  fallback: 'Google sign-in failed. Please try again.'),
              style: AppTheme.textTheme.labelMedium?.copyWith()),
          backgroundColor: IntelligenceColors.crimsonSpike,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: IntelligenceColors.obsidianBlack,
      body: SafeArea(
        // No scroll: the form fills the viewport and the flexible Spacers
        // absorb the leftover vertical space, so the whole page fits on one
        // screen without ever scrolling.
        child: Padding(
          padding: EdgeInsets.all(IntelligenceSpacing.universal),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const SizedBox(height: IntelligenceSpacing.compact),

                NotizzBrandTitle(),
                // Heavier top spacer drops the "Welcome back" block and form
                // a little lower than the other gaps.
                const Spacer(flex: 2),

                // Title - editorial masthead serif (Fraunces)
                Text(
                  'Welcome back',
                  style: AppType.headline(
                    size: 34,
                    weight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: AppSpace.sm),

                // Subtitle
                Text(
                  'Sign in to your Notizz AI account.',
                  style: AppType.display(
                    size: 15,
                    color: AppColors.graphite,
                    height: 1.4,
                  ),
                ),

                const Spacer(),

                // Email field - Sharp Input
                SharpInput(
                  label: 'Email Address',
                  hint: 'Enter your email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),

                SizedBox(height: IntelligenceSpacing.standard),

                // Password field - Sharp Input
                SharpInput(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outlined,
                  suffixIcon: _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  onSuffixTap: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                SizedBox(height: IntelligenceSpacing.standard),

                // Forgot Password - Right aligned
                Align(
                  alignment: Alignment.centerRight,
                  child: VectorButton(
                    label: 'Forgot Password?',
                    type: VectorButtonType.text,
                    onPressed: () => context.push('/forgot-password'),
                  ),
                ),

                SizedBox(height: IntelligenceSpacing.spacious),

                // Login button
                VectorButton(
                  label: 'SIGN IN',
                  type: VectorButtonType.primary,
                  fullWidth: true,
                  isLoading: authProvider.isLoading,
                  onPressed: _handleLogin,
                ),

                SizedBox(height: IntelligenceSpacing.standard),

                Text(
                  'or continue with',
                  style: AppTheme.textTheme.bodyLarge?.copyWith(
                    fontSize: IntelligenceTypography.bodySm,
                    color: IntelligenceColors.secondaryTextGrey,
                  ),
                ),
                SizedBox(height: IntelligenceSpacing.compact),
                VectorButton(
                  label: 'Google',
                  type: VectorButtonType.outline,
                  icon: Icons.g_mobiledata_rounded,
                  fullWidth: true,
                  onPressed: authProvider.isLoading ? null : _handleGoogleLogin,
                ),

                SizedBox(height: IntelligenceSpacing.spacious),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: AppTheme.textTheme.bodyLarge?.copyWith(
                        fontSize: IntelligenceTypography.bodySm,
                        color: IntelligenceColors.secondaryTextGrey,
                      ),
                    ),
                    VectorButton(
                      label: 'Sign Up',
                      type: VectorButtonType.text,
                      onPressed: () => context.push('/register'),
                    ),
                  ],
                ),

                const Spacer(),

                // Standing line — the trust assurances set as quiet fine print
                // at the foot of the page (editorial style), not a badge bar.
                // A short hairline seats it as a footer.
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 32, height: 1, color: AppColors.rule),
                      SizedBox(height: AppSpace.md),
                      Text(
                        'SECURE · ENCRYPTED · VERIFIED',
                        textAlign: TextAlign.center,
                        style: AppType.ui(
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.muted,
                          letterSpacing: 1.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
