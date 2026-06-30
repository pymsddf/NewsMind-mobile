import 'package:flutter/material.dart';
import 'intelligence_design_system.dart';

// ============================================================================
// NEWSMIND AI — "The Verdict Desk" theme
// Light-first editorial identity built on bundled fonts (Newsreader,
// Schibsted Grotesk, IBM Plex Mono). See intelligence_design_system.dart.
// ============================================================================

class AppTheme {
  // ----- Legacy color aliases (resolve to the active palette) -----
  static Color get primaryColor => AppColors.indigo;
  static Color get accentColor => AppColors.redline;
  static Color get secondaryColor => AppColors.indigo;

  static Color get background => AppColors.paper;
  static Color get surface => AppColors.surface;
  static Color get surfaceLight => AppColors.surfaceAlt;
  static Color get cardColor => AppColors.surface;
  static Color get borderColor => AppColors.rule;

  static Color get textPrimary => AppColors.ink;
  static Color get textSecondary => AppColors.graphite;
  static Color get textMuted => AppColors.muted;

  static Color get success => AppColors.verified;
  static Color get error => AppColors.redline;
  static Color get warning => AppColors.caution;
  static Color get info => AppColors.neutral;

  static Color get primary => AppColors.indigo;
  static Color get accent => AppColors.redline;

  // ----- Gradients (resolve to active palette) -----
  // Ink-to-warm (web --gradient-primary). Tonal, never candy.
  static LinearGradient get primaryGradient => LinearGradient(
        colors: AppColors.isDark
            ? [Color(0xFFECE6D6), Color(0xFFBBB4A2)]
            : [Color(0xFF1A1714), Color(0xFF3A322A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get criticalAlertGradient => LinearGradient(
        colors: [AppColors.caution, AppColors.redline],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  static LinearGradient get neutralGradient => LinearGradient(
        colors: [AppColors.neutral, AppColors.indigo],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // Rebuilt each access so it reflects the active palette.
  static TextTheme get textTheme => _buildTextTheme();

  // Single source of truth — built from the active palette.
  static ThemeData get theme => _build();

  // Backward-compatible aliases.
  static ThemeData get lightTheme => _build();
  static ThemeData get darkTheme => _build();

  static ThemeData _build() {
    final brightness = AppColors.isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: AppColors.paper,
      primaryColor: AppColors.indigo,
      canvasColor: AppColors.paper,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.indigo,
        secondary: AppColors.redline,
        surface: AppColors.surface,
        error: AppColors.redline,
        onPrimary: AppColors.onAccent,
        onSecondary: AppColors.onAccent,
        onSurface: AppColors.ink,
        onError: AppColors.onAccent,
        outline: AppColors.rule,
      ),
      cardColor: AppColors.surface,
      dividerColor: AppColors.rule,
      textTheme: textTheme,
      fontFamily: AppType.sans,

      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.ink, size: 24),
        titleTextStyle: AppType.headline(
          size: 22,
          weight: FontWeight.w700,
          color: AppColors.ink,
          letterSpacing: -0.4,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.indigo,
        unselectedItemColor: AppColors.muted,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: AppType.ui(size: 11, weight: FontWeight.w600),
        unselectedLabelStyle: AppType.ui(size: 11),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.indigoSoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return AppType.ui(
            size: 11,
            weight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? AppColors.indigo : AppColors.muted,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.indigo : AppColors.muted,
            size: 24,
          );
        }),
      ),

      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.all(AppSpace.sm),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: AppColors.rule, width: 1),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: _inputBorder(AppColors.ruleStrong, 1),
        enabledBorder: _inputBorder(AppColors.ruleStrong, 1),
        focusedBorder: _inputBorder(AppColors.redline, 1.6), // press-red focus ring (web --color-ring)
        errorBorder: _inputBorder(AppColors.redline, 1),
        focusedErrorBorder: _inputBorder(AppColors.redline, 1.6),
        hintStyle: AppType.ui(size: 15, color: AppColors.muted),
        labelStyle: AppType.ui(size: 13, color: AppColors.graphite),
        prefixIconColor: AppColors.muted,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.indigo,
          foregroundColor: AppColors.onAccent,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppType.ui(size: 15, weight: FontWeight.w700, letterSpacing: 0.2),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          side: BorderSide(color: AppColors.ruleStrong),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: AppType.ui(size: 15, weight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.indigo,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          textStyle: AppType.ui(size: 14, weight: FontWeight.w600),
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.indigo,
        foregroundColor: AppColors.onAccent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      iconTheme: IconThemeData(color: AppColors.ink, size: 24),

      dividerTheme: DividerThemeData(
        color: AppColors.rule,
        thickness: 1,
        space: 24,
      ),

      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        tileColor: AppColors.surface,
        textColor: AppColors.ink,
        iconColor: AppColors.graphite,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.paperAlt,
        labelStyle: AppType.ui(size: 12, weight: FontWeight.w500, color: AppColors.ink),
        side: BorderSide(color: AppColors.rule),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.indigo,
        linearTrackColor: AppColors.rule,
        circularTrackColor: AppColors.rule,
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.indigo,
        inactiveTrackColor: AppColors.rule,
        thumbColor: AppColors.indigo,
        overlayColor: AppColors.indigo.withValues(alpha: 0.15),
        trackHeight: 3,
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.indigo
                : AppColors.surface),
        checkColor: WidgetStateProperty.all(AppColors.onAccent),
        side: BorderSide(color: AppColors.ruleStrong, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.indigo
                : AppColors.surface),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.indigo.withValues(alpha: 0.35)
                : AppColors.rule),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppType.ui(size: 13, color: AppColors.onAccent),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: AppColors.rule),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.indigo,
        unselectedLabelColor: AppColors.muted,
        labelStyle: AppType.ui(size: 14, weight: FontWeight.w700),
        unselectedLabelStyle: AppType.ui(size: 14, weight: FontWeight.w500),
        indicatorColor: AppColors.redline,
        indicatorSize: TabBarIndicatorSize.label,
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color c, double w) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: c, width: w),
      );

  // ----- Text theme -----
  static TextTheme _buildTextTheme() {
    return TextTheme(
      // Editorial display (Fraunces) — verdicts & big callouts
      displayLarge: AppType.headline(
        size: 60, weight: FontWeight.w700, color: AppColors.ink,
        height: 1.05, letterSpacing: -1),
      displayMedium: AppType.headline(
        size: 44, weight: FontWeight.w700, color: AppColors.ink,
        height: 1.08, letterSpacing: -0.5),
      displaySmall: AppType.headline(
        size: 32, weight: FontWeight.w600, color: AppColors.ink, height: 1.1),

      // Screen titles — display serif (Fraunces), set tight like print
      headlineLarge: AppType.headline(
        size: 28, weight: FontWeight.w700, color: AppColors.ink, height: 1.15, letterSpacing: -0.5),
      headlineMedium: AppType.headline(
        size: 23, weight: FontWeight.w600, color: AppColors.ink, height: 1.2, letterSpacing: -0.4),
      headlineSmall: AppType.headline(
        size: 19, weight: FontWeight.w600, color: AppColors.ink, height: 1.25, letterSpacing: -0.3),

      // UI titles — grotesk
      titleLarge: AppType.ui(
        size: 17, weight: FontWeight.w700, color: AppColors.ink),
      titleMedium: AppType.ui(
        size: 15, weight: FontWeight.w600, color: AppColors.ink),
      titleSmall: AppType.ui(
        size: 13, weight: FontWeight.w600, color: AppColors.ink),

      // Reading body — Newsreader serif
      bodyLarge: AppType.display(
        size: 16.5, weight: FontWeight.w400, color: AppColors.ink, height: 1.6),
      bodyMedium: AppType.display(
        size: 15, weight: FontWeight.w400, color: AppColors.ink, height: 1.55),
      bodySmall: AppType.ui(
        size: 12.5, weight: FontWeight.w400, color: AppColors.graphite, height: 1.45),

      // Labels — grotesk
      labelLarge: AppType.ui(
        size: 15, weight: FontWeight.w600, color: AppColors.ink, letterSpacing: 0.2),
      labelMedium: AppType.ui(
        size: 13, weight: FontWeight.w500, color: AppColors.ink),
      labelSmall: AppType.ui(
        size: 11, weight: FontWeight.w500, color: AppColors.graphite, letterSpacing: 0.4),
    );
  }
}

// ----- Theme extension for semantic verdict colors -----
extension ThemeExtensions on ThemeData {
  Color get verifiedTrue => AppColors.verified;
  Color get biasWarning => AppColors.caution;
  Color get verifiedFalse => AppColors.redline;
  Color get neutral => AppColors.neutral;
  Color get obsidianBlack => AppColors.ink;
}
