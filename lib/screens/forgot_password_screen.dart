import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/vector_button.dart';
import '../widgets/notizz_brand_title.dart';

class ForgotPasswordScreen extends StatefulWidget {
  ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  int _step = 0; // 0: enter email, 1: enter OTP, 2: new password
  bool _loading = false;
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscure = true;

  Future<void> _sendOtp() async {
    if (_emailController.text.trim().isEmpty) return;
    setState(() => _loading = true);

    final response = await AuthService.sendResetOtp(_emailController.text.trim());

    setState(() => _loading = false);
    if (!mounted) return;

    if (response['success'] == true) {
      setState(() => _step = 1);
      _showSnack('OTP sent to your email', isError: false);
    } else {
      _showSnack(response['message'] ?? 'Failed to send OTP');
    }
  }

  Future<void> _resetPassword() async {
    if (_otpController.text.trim().isEmpty || _newPasswordController.text.isEmpty) return;
    setState(() => _loading = true);

    final response = await AuthService.resetPassword(
      _emailController.text.trim(),
      _otpController.text.trim(),
      _newPasswordController.text,
    );

    setState(() => _loading = false);
    if (!mounted) return;

    if (response['success'] == true) {
      _showSnack('Password reset successfully!', isError: false);
      await Future.delayed(Duration(seconds: 1));
      if (mounted) Navigator.pop(context);
    } else {
      _showSnack(response['message'] ?? 'Password reset failed');
    }
  }

  void _showSnack(String msg, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppTheme.error : AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(),
      ),
    );
  }


  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: NotizzBrandTitle(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        gradient: i <= _step ? AppTheme.primaryGradient : null,
                        color: i > _step ? AppTheme.surfaceLight : null,
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 40),

              if (_step == 0) ...[
                Text('Enter your email', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                SizedBox(height: 8),
                Text("We'll send you a verification code", style: TextStyle(color: AppTheme.textMuted)),
                SizedBox(height: 32),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.surface,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                  ),
                ),
                SizedBox(height: 24),
                VectorButton(fullWidth: true, label: 'Send OTP', isLoading: _loading, onPressed: _sendOtp),
              ],

              if (_step == 1) ...[
                Text('Enter OTP & New Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                SizedBox(height: 8),
                Text('Check your email for the verification code', style: TextStyle(color: AppTheme.textMuted)),
                SizedBox(height: 32),
                TextFormField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 24, letterSpacing: 8),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    labelText: 'Verification Code',
                    prefixIcon: Icon(Icons.pin_outlined, color: AppTheme.textMuted),
                    filled: true,
                    fillColor: AppTheme.surface,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                  ),
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _newPasswordController,
                  obscureText: _obscure,
                  style: TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    filled: true,
                    fillColor: AppTheme.surface,
                    labelStyle: TextStyle(color: AppTheme.textSecondary),
                    prefixIcon: Icon(Icons.lock_outlined, color: AppTheme.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: AppTheme.textMuted),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                VectorButton(fullWidth: true, label: 'Reset Password', isLoading: _loading, onPressed: _resetPassword),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
