import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../theme/intelligence_design_system.dart';
import '../widgets/sharp_input.dart';
import '../widgets/vector_button.dart';
import '../widgets/notizz_brand_title.dart';

/// Email OTP verification — the step between signing up and entering the app.
/// The user lands here straight after registering; a 6-digit code was emailed.
/// Verifying logs them in (the backend returns a token), then routing sends
/// them to onboarding or home.
class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  bool _isResending = false;
  int _resendIn = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _resendIn = 30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _resendIn -= 1);
      if (_resendIn <= 0) t.cancel();
    });
  }

  void _toast(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(message, style: AppTheme.textTheme.labelMedium?.copyWith()),
        backgroundColor: success
            ? IntelligenceColors.electricTeal
            : IntelligenceColors.crimsonSpike,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleVerify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _toast('Enter the 6-digit code from your email');
      return;
    }

    final auth = context.read<AuthProvider>();
    final response = await auth.verifyEmail(widget.email, otp);
    if (!mounted) return;

    if (response['success'] == true) {
      _toast('Email verified. Welcome to Notizz.', success: true);
      // Routing redirect sends a verified user to onboarding or home.
      context.go('/home');
    } else {
      _toast(response['message'] ?? 'Verification failed');
    }
  }

  Future<void> _handleResend() async {
    if (_resendIn > 0 || _isResending) return;
    setState(() => _isResending = true);

    final auth = context.read<AuthProvider>();
    final response = await auth.resendVerifyOtp(widget.email);
    if (!mounted) return;

    setState(() => _isResending = false);
    if (response['success'] == true) {
      _startCooldown();
      _toast('A new code is on its way to ${widget.email}.', success: true);
    } else {
      _toast(response['message'] ?? 'Could not resend the code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: SafeArea(
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: IntelligenceSpacing.compact),
                    const NotizzBrandTitle(),
                    SizedBox(height: IntelligenceSpacing.spacious),

                    // Title — editorial masthead serif, matching login/register
                    Text(
                      'Verify your email',
                      style: AppType.headline(
                        size: 34,
                        weight: FontWeight.w700,
                        color: AppColors.ink,
                        height: 1.1,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: AppSpace.sm),

                    // Subtitle — names the address the code went to
                    Text.rich(
                      TextSpan(
                        style: AppType.display(
                          size: 15,
                          color: AppColors.graphite,
                          height: 1.4,
                        ),
                        children: [
                          const TextSpan(
                              text: 'Enter the 6-digit code we sent to '),
                          TextSpan(
                            text: widget.email,
                            style: AppType.display(
                              size: 15,
                              color: AppColors.ink,
                              height: 1.4,
                            ).copyWith(fontWeight: FontWeight.w600),
                          ),
                          const TextSpan(text: '.'),
                        ],
                      ),
                    ),

                    SizedBox(height: IntelligenceSpacing.spacious),

                    SharpInput(
                      label: 'Verification code',
                      hint: '6-digit code',
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.mark_email_read_outlined,
                      onChanged: (v) {
                        // Auto-submit once all six digits are entered.
                        if (v.trim().length == 6 && !authProvider.isLoading) {
                          _handleVerify();
                        }
                      },
                    ),

                    SizedBox(height: IntelligenceSpacing.spacious),

                    VectorButton(
                      label: 'VERIFY',
                      type: VectorButtonType.primary,
                      fullWidth: true,
                      isLoading: authProvider.isLoading,
                      onPressed: _handleVerify,
                    ),

                    SizedBox(height: IntelligenceSpacing.standard),

                    // Resend — disabled during the cooldown window
                    Center(
                      child: VectorButton(
                        label: _resendIn > 0
                            ? 'Resend code in ${_resendIn}s'
                            : (_isResending
                                ? 'Sending…'
                                : "Didn't get it? Resend code"),
                        type: VectorButtonType.text,
                        onPressed: (_resendIn > 0 || _isResending)
                            ? null
                            : _handleResend,
                      ),
                    ),

                    SizedBox(height: IntelligenceSpacing.spacious),

                    Center(
                      child: VectorButton(
                        label: 'Back to sign in',
                        type: VectorButtonType.text,
                        onPressed: () => context.go('/login'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
