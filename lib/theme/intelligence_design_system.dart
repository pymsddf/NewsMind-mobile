import 'package:flutter/material.dart';

// ============================================================================
// NEWSMIND AI — "NEWSPRINT" DESIGN SYSTEM (2026)
// ============================================================================
// Matches the NewsMind AI web app theme (frontend/styles/tailwind.css):
// ink on warm newsprint paper, black is the brand, press-red is the one loud
// accent, editorial ink-blue for secondary marks. Light-first, built for
// reading. Dark mode mirrors the web "Late Edition" palette.
//
// Canonical tokens live in AppColors / AppType / AppSpace / AppRadius.
// The legacy Intelligence* classes are kept as thin compatibility aliases so
// existing screens keep compiling while they are migrated.
//
// NOTE: the token named `indigo` now holds the INK/primary brand color (to
// match the web, whose primary is ink, not indigo). Kept under the old name to
// avoid churning ~540 call sites. `redline` is the press-red accent; `neutral`
// is the editorial ink-blue secondary.
// ============================================================================

// ---------------------------------------------------------------------------
// CANONICAL PALETTE
// ---------------------------------------------------------------------------

/// Active palette. Field values are swapped at runtime by [applyMode] so the
/// ~860 existing `AppColors.x` / `IntelligenceColors.x` / `AppTheme.x` call
/// sites adapt to light/dark without per-site changes. Because the values are
/// mutable, colors must NOT be captured in `const` widgets — resolve them at
/// build time so a theme switch repaints them.
class AppColors {
  static bool _dark = false;
  static bool get isDark => _dark;

  /// Swap the active palette. Call before (re)building [ThemeData].
  static void applyMode(bool dark) {
    _dark = dark;
    final p = dark ? _Dark() : _Light();
    paper = p.paper;
    paperAlt = p.paperAlt;
    surface = p.surface;
    surfaceAlt = p.surfaceAlt;
    ink = p.ink;
    graphite = p.graphite;
    muted = p.muted;
    rule = p.rule;
    ruleStrong = p.ruleStrong;
    redline = p.redline;
    redlineSoft = p.redlineSoft;
    indigo = p.indigo;
    indigoSoft = p.indigoSoft;
    verified = p.verified;
    verifiedSoft = p.verifiedSoft;
    caution = p.caution;
    cautionSoft = p.cautionSoft;
    neutral = p.neutral;
    neutralSoft = p.neutralSoft;
    onAccent = p.onAccent;
  }

  // Active (mutable) fields — default to light.
  static Color paper = const _Light().paper;
  static Color paperAlt = const _Light().paperAlt;
  static Color surface = const _Light().surface;
  static Color surfaceAlt = const _Light().surfaceAlt;
  static Color ink = const _Light().ink;
  static Color graphite = const _Light().graphite;
  static Color muted = const _Light().muted;
  static Color rule = const _Light().rule;
  static Color ruleStrong = const _Light().ruleStrong;
  static Color redline = const _Light().redline;
  static Color redlineSoft = const _Light().redlineSoft;
  static Color indigo = const _Light().indigo;
  static Color indigoSoft = const _Light().indigoSoft;
  static Color verified = const _Light().verified;
  static Color verifiedSoft = const _Light().verifiedSoft;
  static Color caution = const _Light().caution;
  static Color cautionSoft = const _Light().cautionSoft;
  static Color neutral = const _Light().neutral;
  static Color neutralSoft = const _Light().neutralSoft;
  static Color onAccent = const _Light().onAccent;

  // Convenience alias kept for callers.
  static Color get falseRed => redline;
}

/// Palette contract shared by light & dark.
abstract class _Palette {
  Color get paper;
  Color get paperAlt;
  Color get surface;
  Color get surfaceAlt;
  Color get ink;
  Color get graphite;
  Color get muted;
  Color get rule;
  Color get ruleStrong;
  Color get redline;
  Color get redlineSoft;
  Color get indigo;
  Color get indigoSoft;
  Color get verified;
  Color get verifiedSoft;
  Color get caution;
  Color get cautionSoft;
  Color get neutral;
  Color get neutralSoft;
  Color get onAccent;
}

/// Light — "Newsprint": ink on warm newsprint paper, press-red accent.
/// Mirrors the web app :root palette (frontend/styles/tailwind.css).
class _Light implements _Palette {
  const _Light();
  @override final Color paper = const Color(0xFFF4F1E9);       // newsprint paper
  @override final Color paperAlt = const Color(0xFFEAE4D5);    // paper shade (muted)
  @override final Color surface = const Color(0xFFFCFAF4);     // warm white stock (card)
  @override final Color surfaceAlt = const Color(0xFFFFFFFF);  // clean field (input)
  @override final Color ink = const Color(0xFF1A1714);         // warm ink
  @override final Color graphite = const Color(0xFF6B6357);    // faded ink
  @override final Color muted = const Color(0xFF948B7C);       // lighter faded ink
  @override final Color rule = const Color(0xFFDAD3C3);        // faded rule
  @override final Color ruleStrong = const Color(0xFFC9C1AE);
  @override final Color redline = const Color(0xFFC5301F);     // press-red (accent)
  @override final Color redlineSoft = const Color(0xFFF6E3DE);
  @override final Color indigo = const Color(0xFF1A1714);      // PRIMARY = ink (brand)
  @override final Color indigoSoft = const Color(0xFFE8E2D3);  // selection tint
  @override final Color verified = const Color(0xFF2F7A4F);    // pressroom green
  @override final Color verifiedSoft = const Color(0xFFE2EFE7);
  @override final Color caution = const Color(0xFFB8862F);     // ochre
  @override final Color cautionSoft = const Color(0xFFF3EAD4);
  @override final Color neutral = const Color(0xFF21456E);     // editorial ink-blue (secondary)
  @override final Color neutralSoft = const Color(0xFFE1E8F1);
  @override final Color onAccent = const Color(0xFFF7F4ED);    // paper text on ink/accent
}

/// Dark — "Late Edition": paper text on warm black, red runs hotter.
/// Mirrors the web app .dark palette (frontend/styles/tailwind.css).
class _Dark implements _Palette {
  const _Dark();
  @override final Color paper = const Color(0xFF16140F);       // warm black
  @override final Color paperAlt = const Color(0xFF26221B);    // muted
  @override final Color surface = const Color(0xFF1C1915);     // card
  @override final Color surfaceAlt = const Color(0xFF1E1B16);  // input
  @override final Color ink = const Color(0xFFECE6D6);         // paper text
  @override final Color graphite = const Color(0xFF9A9081);    // faded ink
  @override final Color muted = const Color(0xFF837A6B);
  @override final Color rule = const Color(0xFF2E2A22);
  @override final Color ruleStrong = const Color(0xFF3E392F);
  @override final Color redline = const Color(0xFFE0552F);     // press-red runs hotter (accent)
  @override final Color redlineSoft = const Color(0xFF2A1A12);
  @override final Color indigo = const Color(0xFFECE6D6);      // PRIMARY = paper on dark
  @override final Color indigoSoft = const Color(0xFF26221B);
  @override final Color verified = const Color(0xFF4FA877);
  @override final Color verifiedSoft = const Color(0xFF16271E);
  @override final Color caution = const Color(0xFFD6A341);
  @override final Color cautionSoft = const Color(0xFF2C2210);
  @override final Color neutral = const Color(0xFF6E97C9);     // ink-blue (secondary)
  @override final Color neutralSoft = const Color(0xFF18222F);
  @override final Color onAccent = const Color(0xFF16140F);    // dark text on paper/accent
}

// ---------------------------------------------------------------------------
// TYPOGRAPHY (bundled fonts — no runtime fetching)
// ---------------------------------------------------------------------------
// Display & long-form reading: Newsreader (built for news).
// UI, labels, buttons:        Schibsted Grotesk (built for a news org).
// Data, %, timestamps:        IBM Plex Mono.

class AppType {
  static const String heading = 'Fraunces';  // display serif — masthead/headlines (web: heading)
  static const String serif = 'Newsreader';  // reading serif — long-form body (web: body)
  static const String sans = 'Schibsted Grotesk'; // UI grotesque (web: Archivo)
  static const String mono = 'IBM Plex Mono'; // data/timestamps (web: JetBrains Mono)

  /// Display serif (Fraunces) — masthead, headlines, big verdict callouts.
  static TextStyle headline({
    double? size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) =>
      TextStyle(
        fontFamily: heading,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  static TextStyle display({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? fontStyle,
  }) =>
      TextStyle(
        fontFamily: serif,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
      );

  static TextStyle ui({
    double? size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      TextStyle(
        fontFamily: sans,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle data({
    double? size,
    FontWeight weight = FontWeight.w500,
    Color? color,
    double? height,
    double? letterSpacing = 0.4,
  }) =>
      TextStyle(
        fontFamily: mono,
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}

// ---------------------------------------------------------------------------
// SPACING (8pt grid) + RADIUS
// ---------------------------------------------------------------------------

class AppSpace {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  // Modest, editorial-square radii — matches the web --radius: 0.5rem (8px),
  // with md/sm derived as on the web (−2px / −4px).
  static const double sm = 4.0;
  static const double md = 6.0;
  static const double lg = 8.0;
  static const double pill = 999.0;
}

// ============================================================================
// LEGACY COMPATIBILITY LAYER
// ============================================================================
// Old member names mapped to the new palette so existing screens compile and
// adopt the new identity. New code should prefer AppColors / AppType.

class IntelligenceColors {
  // Base
  static Color get obsidianBlack => AppColors.paper; // was bg → now paper
  static Color get pureWhite => AppColors.ink; // was text → now ink
  static Color get slateGrey => AppColors.rule; // borders / dividers
  static Color get secondaryTextGrey => AppColors.graphite;

  // Intelligence indicators
  static Color get electricTeal => AppColors.indigo; // brand / selection
  static Color get kineticsOrange => AppColors.caution;
  static Color get crimsonSpike => AppColors.redline;
  static Color get cyberBlue => AppColors.neutral;

  // Semantic aliases
  static Color get verifiedTrue => AppColors.verified;
  static Color get biasWarning => AppColors.caution;
  static Color get verifiedFalse => AppColors.redline;
  static Color get neutral => AppColors.neutral;
  static Color get aiGeneration => AppColors.indigo;

  // Backgrounds
  static Color get backgroundDark => AppColors.paper;
  static Color get backgroundLight => AppColors.paper;
  static Color get surfaceDark => AppColors.surface;
  static Color get surfaceLight => AppColors.surfaceAlt;

  // Borders
  static Color get border => AppColors.rule;
  static Color get divider => AppColors.rule;

  // Text
  static Color get textPrimaryDark => AppColors.ink;
  static Color get textPrimaryLight => AppColors.ink;
  static Color get textSecondaryDark => AppColors.graphite;
  static Color get textSecondaryLight => AppColors.graphite;

  // States
  static Color get error => AppColors.redline;
  static Color get warning => AppColors.caution;
  static Color get success => AppColors.verified;
  static Color get info => AppColors.neutral;
}

// ---------------------------------------------------------------------------
// RESPONSIVE BREAKPOINTS
// ---------------------------------------------------------------------------

class IntelligenceBreakpoints {
  static const double mobile = 600.0;
  static const double tablet = 960.0;
  static const double desktop = 1280.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile &&
      MediaQuery.of(context).size.width < tablet;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
}

// ---------------------------------------------------------------------------
// SPACING (legacy names → 8pt grid)
// ---------------------------------------------------------------------------

class IntelligenceSpacing {
  static const double unit = 8.0;
  static const double universal = 16.0;
  static const double compact = 8.0;
  static const double standard = 16.0;
  static const double comfortable = 24.0;
  static const double spacious = 32.0;

  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Radii now soft (was sharp 0/2/4)
  static const double radiusNone = 0.0;
  static const double radiusSm = AppRadius.sm;
  static const double radiusMd = AppRadius.md;
  static const double radiusLg = AppRadius.lg;

  static const double cardPadding = 16.0;
  static const double cardMargin = 8.0;
  static const double cardBorderWidth = 1.0;
}

// ---------------------------------------------------------------------------
// TYPOGRAPHY (legacy names)
// ---------------------------------------------------------------------------

class IntelligenceTypography {
  static const String fontDisplay = AppType.sans; // headings / UI
  static const String fontBody = AppType.serif; // reading
  static const String fontMono = AppType.mono; // data
  static const String fontImpact = AppType.serif;

  static const double displayXl = 64.0; // verdict callouts
  static const double displayLg = 44.0;
  static const double displayMd = 34.0;
  static const double displaySm = 27.0;

  static const double headingXl = 24.0;
  static const double headingLg = 20.0;
  static const double headingMd = 18.0;
  static const double headingSm = 16.0;

  static const double bodyLg = 16.0;
  static const double bodyMd = 14.0;
  static const double bodySm = 12.0;

  static const double monoLg = 14.0;
  static const double monoMd = 12.0;
  static const double monoSm = 10.0;

  static const double lineHeightBody = 1.6;
  static const double lineHeightHeading = 1.15;
  static const double lineHeightMono = 1.4;
}

// ---------------------------------------------------------------------------
// COMPONENT HELPERS (legacy)
// ---------------------------------------------------------------------------

class IntelligenceComponents {
  static Border get cardBorderDark => Border.all(
        color: AppColors.rule,
        width: IntelligenceSpacing.cardBorderWidth,
      );

  static Border get cardBorderLight => Border.all(
        color: AppColors.rule,
        width: IntelligenceSpacing.cardBorderWidth,
      );

  static InputDecoration inputDecoration({
    required String hintText,
    String? labelText,
    IconData? prefixIcon,
    Color? borderColor,
    Color? focusColor,
  }) {
    OutlineInputBorder b(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: IntelligenceSpacing.iconMd)
          : null,
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: EdgeInsets.all(IntelligenceSpacing.standard),
      border: b(borderColor ?? AppColors.ruleStrong, 1),
      enabledBorder: b(borderColor ?? AppColors.ruleStrong, 1),
      focusedBorder: b(focusColor ?? AppColors.redline, 1.6),
      errorBorder: b(AppColors.redline, 1),
      focusedErrorBorder: b(AppColors.redline, 1.6),
    );
  }

  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.indigo,
    foregroundColor: AppColors.onAccent,
    elevation: 0,
    padding: EdgeInsets.symmetric(
      horizontal: IntelligenceSpacing.universal,
      vertical: IntelligenceSpacing.standard,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    textStyle: AppType.ui(size: 16, weight: FontWeight.w700, letterSpacing: 0.2),
  );

  static ButtonStyle get criticalButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.redline,
    foregroundColor: AppColors.onAccent,
    elevation: 0,
    padding: EdgeInsets.symmetric(
      horizontal: IntelligenceSpacing.universal,
      vertical: IntelligenceSpacing.standard,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    textStyle: AppType.ui(size: 16, weight: FontWeight.w700, letterSpacing: 0.2),
  );

  static ButtonStyle get warningButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppColors.caution,
    foregroundColor: AppColors.onAccent,
    elevation: 0,
    padding: EdgeInsets.symmetric(
      horizontal: IntelligenceSpacing.universal,
      vertical: IntelligenceSpacing.standard,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    textStyle: AppType.ui(size: 16, weight: FontWeight.w700, letterSpacing: 0.2),
  );

  static ButtonStyle get outlineButtonStyle => OutlinedButton.styleFrom(
    foregroundColor: AppColors.ink,
    side: BorderSide(color: AppColors.ruleStrong),
    padding: EdgeInsets.symmetric(
      horizontal: IntelligenceSpacing.universal,
      vertical: IntelligenceSpacing.standard,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
  );
}

// ---------------------------------------------------------------------------
// DESIGN SYSTEM GUIDE CONSTANTS (unchanged identifiers)
// ---------------------------------------------------------------------------

class DesignSystemGuide {
  static const String splashScreen = 'Splash Screen';
  static const String getStartedScreen = 'Get Started Screen';
  static const String todaysIntelligence = "Today's Intelligence";
  static const String newsFeed = 'News Feed';
  static const String newsGeneration = 'News Generation';
  static const String factVerification = 'Fact Verification';
  static const String biasDetection = 'Bias Detection';
  static const String intelligenceProfile = 'Intelligence Profile';
  static const String notifications = 'Notifications';
  static const String designSystemGuide = 'Design System Guide';

  static const String vectorCard = 'Vector Card';
  static const String formField = 'Form Field';
  static const String dataVisualization = 'Data Visualization';
  static const String button = 'Button';
  static const String skeletonLoader = 'Skeleton Loader';

  static const String persistentNav = 'Persistent Navigation';
  static const String hapticFeedback = 'Haptic Feedback';
  static const String snapTransitions = 'Snap Transitions';
  static const String microInteractions = 'Micro-Interactions';

  static const List<String> recommendedPackages = [
    'flutter_riverpod',
    'flutter_hooks',
    'go_router',
    'flutter_launcher_icons',
    'fl_chart',
  ];
}
