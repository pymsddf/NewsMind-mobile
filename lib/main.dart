import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'theme/intelligence_design_system.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_controller.dart';
import 'config/router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the saved theme before first paint so there's no flash.
  final themeController = ThemeController();
  await themeController.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: themeController),
      ],
      child: NewsMindApp(),
    ),
  );
}

class NewsMindApp extends StatefulWidget {
  NewsMindApp({super.key});

  @override
  State<NewsMindApp> createState() => _NewsMindAppState();
}

class _NewsMindAppState extends State<NewsMindApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = NewsMindRouter.createRouter(context.read<AuthProvider>());
  }

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();

    // Keep the system bars in step with the active palette.
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          themeController.isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness:
          themeController.isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness:
          themeController.isDark ? Brightness.light : Brightness.dark,
    ));

    return MaterialApp.router(
      title: 'NewsMind AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: _router,
      // Colours are applied through mutable AppColors statics (not
      // Theme.of(context)), so a mode switch won't rebuild already-built
      // screens on its own — that's why only part of the UI changed until a
      // tab switch. Re-keying the navigator subtree on each mode change forces
      // the whole visible tree to rebuild at once. The router itself isn't
      // recreated, so the current route/navigation is preserved.
      builder: (context, child) => KeyedSubtree(
        key: ValueKey(themeController.isDark),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
