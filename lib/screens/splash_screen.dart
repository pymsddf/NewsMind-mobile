import 'package:flutter/material.dart';
import '../theme/intelligence_design_system.dart';
import '../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

/// Splash — a quiet editorial reveal: the masthead settles, a redline rules
/// itself beneath it, and a tagline fades in. No spinner.
class SplashScreen extends StatefulWidget {
  SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<double> _rule;
  late Animation<double> _tagline;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1800),
      vsync: this,
    );
    _fade = CurvedAnimation(
        parent: _controller, curve: Interval(0.0, 0.45, curve: Curves.easeOut));
    _rule = CurvedAnimation(
        parent: _controller, curve: Interval(0.35, 0.75, curve: Curves.easeInOutCubic));
    _tagline = CurvedAnimation(
        parent: _controller, curve: Interval(0.6, 1.0, curve: Curves.easeOut));
    _controller.forward();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    await authProvider.init();

    if (!mounted) return;
    context.go(authProvider.isLoggedIn ? '/home' : '/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: _fade.value,
                  child: Transform.translate(
                    offset: Offset(0, 12 * (1 - _fade.value)),
                    child: SizedBox(
                      width: 96,
                      height: 96,
                      child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
                SizedBox(height: AppSpace.lg),
                Opacity(
                  opacity: _fade.value,
                  // Masthead wordmark — "AI" set in press-red italic to match
                  // NewsMindBrandTitle (and the web app). FittedBox guarantees
                  // it scales down rather than overflowing on narrow screens.
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpace.lg),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'NewsMind ',
                              style: AppType.display(
                                  size: 40,
                                  weight: FontWeight.w700,
                                  color: AppColors.ink,
                                  letterSpacing: -0.5),
                            ),
                            TextSpan(
                              text: 'AI',
                              style: AppType.display(
                                  size: 40,
                                  weight: FontWeight.w700,
                                  color: AppColors.redline,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: -0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppSpace.md),
                // Redline rule draws itself in
                Container(
                  height: 2.5,
                  width: 180 * _rule.value,
                  color: AppColors.redline,
                ),
                SizedBox(height: AppSpace.lg),
                Opacity(
                  opacity: _tagline.value,
                  child: Text(
                    'Truth, weighed.',
                    style: AppType.display(
                        size: 17,
                        color: AppColors.graphite,
                        fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
