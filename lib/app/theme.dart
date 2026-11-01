import 'package:flutter/material.dart';

/// Static design tokens (spacing, radii, brand, status).
class Tokens {
  static const primary = Color(0xFF0F5F66); // brand: UI accents only, not data
  static const radius = 12.0;
  static const radiusSm = 8.0;
  static const s8 = 8.0, s12 = 12.0, s16 = 16.0, s20 = 20.0, s24 = 24.0;

  // Status palette (fixed, never themed). Always paired with icon + label.
  static const statusGood = Color(0xFF0CA30C);
  static const statusCritical = Color(0xFFD03B3B);

  /// Darker amber for text/icons on light surfaces (statusWarning fails contrast there).
  static const warning = Color(0xFFB7791F);
}

/// Chart colours as a ThemeExtension so light/dark are separately selected
/// steps (validated with the dataviz validator), not an automatic flip.
@immutable
class VizColors extends ThemeExtension<VizColors> {
  const VizColors({
    required this.categorical,
    required this.surface,
    required this.inkPrimary,
    required this.inkSecondary,
    required this.inkMuted,
    required this.grid,
    required this.axis,
    required this.good,
    required this.bad,
  });

  /// Fixed-order categorical slots. Colour follows the entity, never its rank.
  final List<Color> categorical;
  final Color surface;
  final Color inkPrimary;
  final Color inkSecondary;
  final Color inkMuted;
  final Color grid; // solid hairline
  final Color axis;
  final Color good; // delta-up text
  final Color bad;

  static const light = VizColors(
    categorical: [
      Color(0xFF2A78D6), // blue
      Color(0xFFEB6834), // orange
      Color(0xFF1BAF7A), // aqua
      Color(0xFFEDA100), // yellow
      Color(0xFFE87BA4), // magenta
      Color(0xFF008300), // green
      Color(0xFF6250D6), // violet
      Color(0xFFE34948), // red
    ],
    surface: Color(0xFFFCFCFB),
    inkPrimary: Color(0xFF0B0B0B),
    inkSecondary: Color(0xFF52514E),
    inkMuted: Color(0xFF898781),
    grid: Color(0xFFE1E0D9),
    axis: Color(0xFFC3C2B7),
    good: Color(0xFF006300),
    bad: Color(0xFFD03B3B),
  );

  static const dark = VizColors(
    categorical: [
      Color(0xFF3987E5),
      Color(0xFFD95926),
      Color(0xFF199E70),
      Color(0xFFC98500),
      Color(0xFFD55181),
      Color(0xFF008300),
      Color(0xFF9085E9),
      Color(0xFFE66767),
    ],
    surface: Color(0xFF1A1A19),
    inkPrimary: Color(0xFFF0EFEC),
    inkSecondary: Color(0xFFC3C2B7),
    inkMuted: Color(0xFF898781),
    grid: Color(0xFF2C2C2A),
    axis: Color(0xFF383835),
    good: Color(0xFF0CA30C),
    bad: Color(0xFFE66767),
  );

  static VizColors of(BuildContext c) =>
      Theme.of(c).extension<VizColors>() ?? (Theme.of(c).brightness == Brightness.dark ? dark : light);

  @override
  VizColors copyWith() => this;

  @override
  VizColors lerp(ThemeExtension<VizColors>? other, double t) => this;
}

const bodyFont = 'PlusJakartaSans';
const displayFont = 'BricolageGrotesque';
const _fontFallback = ['HindSiliguri']; // Bengali glyphs

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final viz = dark ? VizColors.dark : VizColors.light;
  final scheme = ColorScheme.fromSeed(
    seedColor: Tokens.primary,
    brightness: b,
    primary: dark ? const Color(0xFF63C5CD) : Tokens.primary,
    error: dark ? const Color(0xFFE66767) : Tokens.statusCritical,
  ).copyWith(
    surface: dark ? const Color(0xFF0D0D0D) : const Color(0xFFF9F9F7),
    onSurface: viz.inkPrimary,
    onSurfaceVariant: viz.inkSecondary,
    outlineVariant: dark ? const Color(0xFF2C2C2A) : const Color(0xFFE1E0D9),
    outline: viz.inkMuted,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: b,
    fontFamily: bodyFont,
    fontFamilyFallback: _fontFallback,
    scaffoldBackgroundColor: scheme.surface,
    extensions: [viz],
  );
  final text = base.textTheme;
  TextStyle? disp(TextStyle? t, FontWeight w) =>
      t?.copyWith(fontFamily: displayFont, fontFamilyFallback: _fontFallback, fontWeight: w);
  return base.copyWith(
    textTheme: text.copyWith(
      displayLarge: disp(text.displayLarge, FontWeight.w700),
      displayMedium: disp(text.displayMedium, FontWeight.w700),
      displaySmall: disp(text.displaySmall, FontWeight.w700),
      headlineLarge: disp(text.headlineLarge, FontWeight.w700),
      headlineMedium: disp(text.headlineMedium, FontWeight.w700),
      headlineSmall: disp(text.headlineSmall, FontWeight.w700),
      titleLarge: disp(text.titleLarge, FontWeight.w700),
      titleMedium: disp(text.titleMedium, FontWeight.w600),
      titleSmall: text.titleSmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.1),
      labelLarge: text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: viz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Tokens.radius),
        side: BorderSide(color: scheme.outlineVariant),
      ),
    ),
    dividerTheme: DividerThemeData(color: scheme.outlineVariant, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: viz.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusSm),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(Tokens.radiusSm),
        borderSide: BorderSide(color: scheme.outlineVariant),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusSm)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 48),
        side: BorderSide(color: scheme.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusSm)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(minimumSize: const Size(48, 48))),
    chipTheme: base.chipTheme.copyWith(
      side: BorderSide(color: scheme.outlineVariant),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusSm)),
    ),
    listTileTheme: const ListTileThemeData(minVerticalPadding: 8),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: viz.surface,
      indicatorColor: scheme.primary.withValues(alpha: 0.14),
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: viz.inkSecondary),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: text.titleLarge?.copyWith(color: viz.inkPrimary, fontWeight: FontWeight.w700),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radiusSm)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: viz.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: viz.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Tokens.radius + 4)),
    ),
  );
}

/// Money text: tabular figures only where numbers align (rows/axes);
/// hero and stat values use proportional figures per the dataviz rules.
const moneyFeatures = [FontFeature.tabularFigures()];

TextStyle moneyStyle(BuildContext c,
        {double? size, FontWeight? weight, Color? color, bool tabular = true, bool display = false}) =>
    (Theme.of(c).textTheme.bodyLarge ?? const TextStyle()).copyWith(
      fontFamily: display ? displayFont : null,
      fontSize: size,
      fontWeight: weight ?? FontWeight.w600,
      color: color,
      fontFeatures: tabular ? moneyFeatures : null,
    );
