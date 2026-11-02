import 'package:e_parada_mobile/config/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('AppPalette contains exact brand hex colors', () {
    expect(AppPalette.aliceBlue, const Color(0xFFF6FAFF));
    expect(AppPalette.naplesYellow, const Color(0xFFFFDE70));
    expect(AppPalette.powderBlue, const Color(0xFFA3C4EB));
    expect(AppPalette.yaleBlue, const Color(0xFF173B64));
  });

  test('lightTheme and darkTheme apply correct brand palettes', () {
    final light = AppTheme.lightTheme;
    expect(light.brightness, Brightness.light);
    expect(light.scaffoldBackgroundColor, AppPalette.aliceBlue);
    expect(light.colorScheme.primary, AppPalette.yaleBlue);
    expect(light.appBarTheme.backgroundColor, AppPalette.yaleBlue);
    expect(light.appBarTheme.foregroundColor, AppPalette.aliceBlue);
    expect(light.appBarTheme.titleTextStyle?.color, AppPalette.aliceBlue);
    expect(light.tabBarTheme.labelColor, AppPalette.naplesYellow);

    final dark = AppTheme.darkTheme;
    expect(dark.brightness, Brightness.dark);
    expect(dark.scaffoldBackgroundColor, AppPalette.darkBg);
    expect(dark.colorScheme.primary, AppPalette.powderBlue);
    expect(dark.appBarTheme.backgroundColor, AppPalette.darkSurface);
    expect(dark.appBarTheme.foregroundColor, AppPalette.powderBlue);
    expect(dark.appBarTheme.titleTextStyle?.color, AppPalette.powderBlue);
    expect(dark.tabBarTheme.labelColor, AppPalette.naplesYellow);
  });

  test('themeNotifier updates with setThemeMode', () async {
    await AppTheme.setThemeMode(ThemeMode.dark);
    expect(AppTheme.themeNotifier.value, ThemeMode.dark);

    await AppTheme.setThemeMode(ThemeMode.light);
    expect(AppTheme.themeNotifier.value, ThemeMode.light);

    await AppTheme.setThemeMode(ThemeMode.system);
    expect(AppTheme.themeNotifier.value, ThemeMode.system);
  });
}
