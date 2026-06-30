import '../theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../providers/auth_provider.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/sharp_input.dart';
import '../widgets/vector_button.dart';
import '../widgets/newsmind_brand_title.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../config/api_config.dart';
import '../utils/error_text.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select your role',
            style: AppTheme.textTheme.labelMedium?.copyWith(),
          ),
          backgroundColor: IntelligenceColors.crimsonSpike,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final response = await authProvider.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
      _selectedRole,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Account created! Check your email for the code.',
            style: AppTheme.textTheme.labelMedium?.copyWith(),
          ),
          backgroundColor: IntelligenceColors.electricTeal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Go verify the email — registration isn't complete until the OTP is
      // confirmed. Pass the email so the screen can verify/resend by address.
      context.push('/verify-otp', extra: _emailController.text.trim());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message'] ?? 'Registration failed',
            style: AppTheme.textTheme.labelMedium?.copyWith(),
          ),
          backgroundColor: IntelligenceColors.crimsonSpike,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _handleGoogleSignup() async {
    if (_selectedRole.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your role first',
              style: AppTheme.textTheme.labelMedium?.copyWith()),
          backgroundColor: IntelligenceColors.crimsonSpike,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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
      if (account == null) return;

      final response = await authProvider.loginWithClerk(
        clerkUserId: 'google_${account.id}',
        email: account.email,
        name: account.displayName ?? account.email.split('@').first,
        provider: 'google',
        role: _selectedRole,
        avatarUrl: account.photoUrl,
        mode: 'signup',
      );

      if (!mounted) return;
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Social signup successful!',
                style: AppTheme.textTheme.labelMedium?.copyWith()),
            backgroundColor: IntelligenceColors.electricTeal,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Google signup failed',
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
                  fallback: 'Google sign-up failed. Please try again.'),
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
      backgroundColor: AppColors.paper,
      body: SafeArea(
        // Scroll only when the content is taller than the viewport; when it
        // fits, the form fills the screen and stays put (no bounce).
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(IntelligenceSpacing.universal),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      constraints.maxHeight - IntelligenceSpacing.universal * 2,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: IntelligenceSpacing.compact),
                      const NewsMindBrandTitle(),
                      SizedBox(height: IntelligenceSpacing.spacious),

                      // Title — editorial masthead serif, matching login
                      Text(
                        'Create account',
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
                        'Start your AI journalism journey.',
                        style: AppType.display(
                          size: 15,
                          color: AppColors.graphite,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: IntelligenceSpacing.spacious),

                      // Name
                      SharpInput(
                        label: 'Full Name',
                        hint: 'Enter your full name',
                        controller: _nameController,
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: IntelligenceSpacing.standard),

                      // Email
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

                      // Password
                      SharpInput(
                        label: 'Password',
                        hint: 'Create a password',
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
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
                          final hasLower = RegExp(r'[a-z]').hasMatch(value);
                          final hasNumber = RegExp(r'[0-9]').hasMatch(value);
                          if (!hasUpper || !hasLower || !hasNumber) {
                            return 'Use uppercase, lowercase and number';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: IntelligenceSpacing.standard),

                      // Confirm Password
                      SharpInput(
                        label: 'Confirm Password',
                        hint: 'Confirm your password',
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        prefixIcon: Icons.lock_outlined,
                        suffixIcon: _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        onSuffixTap: () {
                          setState(() => _obscureConfirmPassword =
                              !_obscureConfirmPassword);
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: IntelligenceSpacing.standard),

                      // Role selection — label matches the input field labels
                      Text(
                        'SELECT ROLE',
                        style: AppType.ui(
                          size: 11,
                          weight: FontWeight.w600,
                          color: AppColors.graphite,
                          letterSpacing: 1.0,
                        ),
                      ),
                      SizedBox(height: AppSpace.sm),
                      Wrap(
                        spacing: AppSpace.sm,
                        runSpacing: AppSpace.sm,
                        children: [
                          _buildRoleChip('Basic'),
                          _buildRoleChip('Reporter'),
                          _buildRoleChip('Editor'),
                        ],
                      ),

                      SizedBox(height: IntelligenceSpacing.spacious),

                      // Register Button
                      VectorButton(
                        label: 'CREATE ACCOUNT',
                        onPressed: _handleRegister,
                        isLoading: authProvider.isLoading,
                        type: VectorButtonType.primary,
                        fullWidth: true,
                      ),

                      SizedBox(height: IntelligenceSpacing.standard),
                      Text(
                        'or sign up with',
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
                        onPressed:
                            authProvider.isLoading ? null : _handleGoogleSignup,
                      ),

                      SizedBox(height: IntelligenceSpacing.standard),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTheme.textTheme.bodyLarge?.copyWith(
                              fontSize: IntelligenceTypography.bodySm,
                              color: IntelligenceColors.secondaryTextGrey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Sign In',
                              style: AppType.ui(
                                size: IntelligenceTypography.bodySm,
                                weight: FontWeight.w700,
                                color: AppColors.redline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Role chip — editorial: selected fills with ink, unselected is a quiet
  // hairline-bordered pill. No teal accent (matches the redline brand).
  Widget _buildRoleChip(String role) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: IntelligenceSpacing.standard,
          vertical: IntelligenceSpacing.compact,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.ink : AppColors.rule,
            width: 1,
          ),
        ),
        child: Text(
          role,
          style: AppType.ui(
            size: 13,
            weight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.paper : AppColors.graphite,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
