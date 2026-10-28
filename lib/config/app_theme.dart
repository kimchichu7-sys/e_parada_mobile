import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPalette {
  // Brand Palette (taken from the E-Parada logo mark)
  static const Color aliceBlue = Color(0xFFF6FAFF); // #F6FAFF - Background & Surface Canvas
  static const Color naplesYellow = Color(0xFFFFDE70); // #FFDE70 - Accent Gold / Rating / Highlights
  static const Color powderBlue = Color(0xFFA3C4EB); // #A3C4EB - Secondary Blue / Soft Accent
  static const Color yaleBlue = Color(0xFF173B64); // #173B64 - Primary Yale Navy Brand Color

  // Dark Mode Shades
  static const Color darkBg = Color(0xFF0A192C); // Deep Obsidian Navy
  static const Color darkSurface = Color(0xFF122744); // Elevated Dark Surface
  static const Color darkCard = Color(0xFF173B64); // Card Container in Dark Mode

  // Functional status palette (panel-mandated, independent of brand colors)
  static const Color success = Color(0xFF10B981); // Approve / Check-in / Pay
  static const Color danger = Color(0xFFEF4444); // Cancel / Reject / Overstay
  static const Color warning = Color(0xFFF59E0B); // Pending / Awaiting downpayment
}

/// Shared elevation + radius tokens so every screen feels consistent.
class AppTokens {
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double minTouchTarget = 48;

  static List<BoxShadow> softShadow(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: (dark ? Colors.black : AppPalette.yaleBlue).withValues(
          alpha: dark ? 0.35 : 0.08,
        ),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

class AppTheme {
  static const String _prefKey = 'app_theme_mode';
  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.system);

  static Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefKey);
      if (saved == 'light') {
        themeNotifier.value = ThemeMode.light;
      } else if (saved == 'dark') {
        themeNotifier.value = ThemeMode.dark;
      } else {
        themeNotifier.value = ThemeMode.system;
      }
    } catch (_) {}
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeNotifier.value = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKey, mode.name);
    } catch (_) {}
  }

  static ThemeData get lightTheme => _build(Brightness.light);

  static ThemeData get darkTheme => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final scheme = dark
        ? const ColorScheme.dark(
            primary: AppPalette.powderBlue,
            onPrimary: AppPalette.yaleBlue,
            primaryContainer: AppPalette.darkCard,
            onPrimaryContainer: AppPalette.aliceBlue,
            secondary: AppPalette.naplesYellow,
            onSecondary: AppPalette.yaleBlue,
            secondaryContainer: AppPalette.darkSurface,
            onSecondaryContainer: AppPalette.naplesYellow,
            tertiary: AppPalette.naplesYellow,
            onTertiary: AppPalette.yaleBlue,
            surface: AppPalette.darkSurface,
            onSurface: AppPalette.aliceBlue,
            surfaceContainerHighest: AppPalette.darkCard,
            error: AppPalette.danger,
          )
        : const ColorScheme.light(
            primary: AppPalette.yaleBlue,
            onPrimary: Colors.white,
            primaryContainer: AppPalette.powderBlue,
            onPrimaryContainer: AppPalette.yaleBlue,
            secondary: AppPalette.powderBlue,
            onSecondary: AppPalette.yaleBlue,
            secondaryContainer: AppPalette.aliceBlue,
            onSecondaryContainer: AppPalette.yaleBlue,
            tertiary: AppPalette.naplesYellow,
            onTertiary: AppPalette.yaleBlue,
            surface: Colors.white,
            onSurface: AppPalette.yaleBlue,
            surfaceContainerHighest: AppPalette.aliceBlue,
            error: Color(0xFFDC2626),
          );

    final bg = dark ? AppPalette.darkBg : AppPalette.aliceBlue;
    final surface = dark ? AppPalette.darkSurface : Colors.white;
    final onSurface = dark ? AppPalette.aliceBlue : AppPalette.yaleBlue;
    final hairline = AppPalette.powderBlue.withValues(alpha: dark ? 0.18 : 0.4);
    final accent = dark ? AppPalette.powderBlue : AppPalette.yaleBlue;
    final onAccent = dark ? AppPalette.yaleBlue : Colors.white;
    final headerColor = dark ? AppPalette.powderBlue : AppPalette.yaleBlue;

    // Typography: body 14-16sp, headers 18-22sp bold (panel readability mandate).
    final textTheme = TextTheme(
      displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: -0.6),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: -0.5),
      displaySmall: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: -0.5),
      headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: -0.4),
      headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: -0.4),
      headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: headerColor, letterSpacing: -0.3),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: headerColor),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: headerColor),
      titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: headerColor),
      bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: onSurface),
      bodyMedium: TextStyle(fontSize: 15, height: 1.45, color: onSurface),
      bodySmall: TextStyle(fontSize: 14, height: 1.4, color: onSurface.withValues(alpha: 0.78)),
      labelLarge: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
      labelMedium: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
      labelSmall: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
    );

    final roundedMd = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppTokens.radiusMd),
    );

    OutlineInputBorder inputBorder(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          borderSide: BorderSide(color: color, width: width),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: AppPalette.yaleBlue.withValues(alpha: 0.12),
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg),
          side: BorderSide(color: hairline, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? AppPalette.darkSurface : AppPalette.yaleBlue,
        foregroundColor: headerColor,
        elevation: 0,
        scrolledUnderElevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        toolbarHeight: 60,
        titleTextStyle: TextStyle(
          color: headerColor,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 8,
        backgroundColor: surface,
        shadowColor: AppPalette.yaleBlue.withValues(alpha: 0.2),
        surfaceTintColor: Colors.transparent,
        indicatorColor: dark
            ? AppPalette.powderBlue.withValues(alpha: 0.2)
            : AppPalette.naplesYellow.withValues(alpha: 0.65),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            letterSpacing: -0.2,
            color: selected ? onSurface : onSurface.withValues(alpha: 0.65),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? onSurface : onSurface.withValues(alpha: 0.65),
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          shape: roundedMd,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: onAccent,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          elevation: 0,
          shape: roundedMd,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(64, AppTokens.minTouchTarget),
          side: BorderSide(color: accent, width: 1.5),
          shape: roundedMd,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          minimumSize: const Size(48, AppTokens.minTouchTarget),
          shape: roundedMd,
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(AppTokens.minTouchTarget, AppTokens.minTouchTarget),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppPalette.naplesYellow,
        foregroundColor: AppPalette.yaleBlue,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: dark ? AppPalette.darkCard : AppPalette.aliceBlue,
        selectedColor: dark
            ? AppPalette.powderBlue.withValues(alpha: 0.25)
            : AppPalette.naplesYellow.withValues(alpha: 0.7),
        side: BorderSide(color: hairline),
        labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: onSurface),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: TextStyle(fontSize: 15, color: onSurface.withValues(alpha: 0.8)),
        hintStyle: TextStyle(fontSize: 15, color: onSurface.withValues(alpha: 0.45)),
        border: inputBorder(AppPalette.powderBlue.withValues(alpha: dark ? 0.3 : 0.8)),
        enabledBorder: inputBorder(AppPalette.powderBlue.withValues(alpha: dark ? 0.3 : 0.8)),
        focusedBorder: inputBorder(dark ? AppPalette.powderBlue : AppPalette.yaleBlue, 2),
        errorBorder: inputBorder(AppPalette.danger),
        focusedErrorBorder: inputBorder(AppPalette.danger, 2),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLg + 4),
        ),
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: headerColor),
        contentTextStyle: TextStyle(fontSize: 15, height: 1.45, color: onSurface),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppPalette.powderBlue,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: dark ? AppPalette.darkCard : AppPalette.yaleBlue,
        contentTextStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppPalette.aliceBlue,
        ),
        actionTextColor: AppPalette.naplesYellow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: onSurface,
        unselectedLabelColor: onSurface.withValues(alpha: 0.6),
        indicatorColor: AppPalette.naplesYellow,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: hairline,
        labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
        unselectedLabelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      listTileTheme: ListTileThemeData(
        minVerticalPadding: 10,
        shape: roundedMd,
        titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: headerColor),
        subtitleTextStyle: TextStyle(fontSize: 14, color: onSurface.withValues(alpha: 0.75)),
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1, space: 24),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: dark ? AppPalette.powderBlue : AppPalette.yaleBlue,
        linearTrackColor: AppPalette.powderBlue.withValues(alpha: 0.3),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppPalette.naplesYellow : null,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppPalette.yaleBlue : null,
        ),
      ),
    );
  }
}
