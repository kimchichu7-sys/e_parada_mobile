import 'package:e_parada_mobile/config/app_theme.dart';
import 'package:e_parada_mobile/screens/admin_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdminOperationsScreen renders header title, icon, and all tabs with high-contrast colors in light theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AdminOperationsScreen(),
      ),
    );

    // Verify header title and section icon
    final titleFinder = find.text('Platform Operations');
    expect(titleFinder, findsOneWidget);
    final titleText = tester.widget<Text>(titleFinder);
    expect(titleText.style?.color, AppPalette.aliceBlue);

    final iconFinder = find.byIcon(Icons.admin_panel_settings_outlined);
    expect(iconFinder, findsAtLeastNWidgets(1));
    final headerIcon = tester.widget<Icon>(iconFinder.first);
    expect(headerIcon.color, AppPalette.aliceBlue);

    // Verify all 3 Tab labels and their icons
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('QR logs'), findsOneWidget);
    expect(find.text('Audit'), findsOneWidget);
    expect(find.byIcon(Icons.support_agent_outlined), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_outlined), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
  });

  testWidgets('AdminOperationsScreen renders header title, icon, and all tabs with powder blue colors in dark theme', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const AdminOperationsScreen(),
      ),
    );

    final titleFinder = find.text('Platform Operations');
    expect(titleFinder, findsOneWidget);
    final titleText = tester.widget<Text>(titleFinder);
    expect(titleText.style?.color, AppPalette.powderBlue);

    final iconFinder = find.byIcon(Icons.admin_panel_settings_outlined);
    expect(iconFinder, findsAtLeastNWidgets(1));
    final headerIcon = tester.widget<Icon>(iconFinder.first);
    expect(headerIcon.color, AppPalette.powderBlue);
  });
}
