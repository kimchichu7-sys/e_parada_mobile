import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPalette {
  // Brand Palette from Capstone specifications:
  static const Color aliceBlue = Color(0xFFF6FAFF); // #F6FAFF - Background & Surface Canvas
  static const Color naplesYellow = Color(0xFFFFDE70); // #FFDE70 - Accent Gold / Rating / Highlights
  static const Color powderBlue = Color(0xFFA3C4EB); // #A3C4EB - Secondary Blue / Soft Accent
  static const Color yaleBlue = Color(0xFF173B64); // #173B64 - Primary Yale Navy Brand Color

  // Dark Mode Shades
  static const Color darkBg = Color(0xFF0A192C); // Deep Obsidian Navy
  static const Color darkSurface = Color(0xFF122744); // Elevated Dark Surface
  static const Color darkCard = Color(0xFF173B64); // Card Container in Dark Mode
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

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
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
      ),
      scaffoldBackgroundColor: AppPalette.aliceBlue,
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppPalette.powderBlue.withValues(alpha: 0.35),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.yaleBlue,
        foregroundColor: AppPalette.aliceBlue,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppPalette.aliceBlue,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.yaleBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.yaleBlue,
          side: const BorderSide(color: AppPalette.yaleBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppPalette.powderBlue.withValues(alpha: 0.8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppPalette.powderBlue.withValues(alpha: 0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppPalette.yaleBlue, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
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
        error: Color(0xFFEF4444),
      ),
      scaffoldBackgroundColor: AppPalette.darkBg,
      cardTheme: CardThemeData(
        color: AppPalette.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: AppPalette.powderBlue.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppPalette.darkSurface,
        foregroundColor: AppPalette.aliceBlue,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppPalette.aliceBlue,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppPalette.powderBlue,
          foregroundColor: AppPalette.yaleBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppPalette.powderBlue,
          side: const BorderSide(color: AppPalette.powderBlue, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppPalette.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppPalette.powderBlue.withValues(alpha: 0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppPalette.powderBlue.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppPalette.powderBlue, width: 2),
        ),
      ),
    );
  }
}
