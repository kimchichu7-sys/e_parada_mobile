import 'package:e_parada_mobile/config/app_theme.dart';
import 'package:e_parada_mobile/screens/admin_operations_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdminOperationsScreen renders header title, icon, and all tabs', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AdminOperationsScreen(),
      ),
    );

    // Verify header title and section icon
    expect(find.text('Platform Operations'), findsOneWidget);
    expect(find.byIcon(Icons.admin_panel_settings_outlined), findsOneWidget);

    // Verify all 3 Tab labels and their icons
    expect(find.text('Support'), findsOneWidget);
    expect(find.text('QR logs'), findsOneWidget);
    expect(find.text('Audit'), findsOneWidget);
    expect(find.byIcon(Icons.support_agent_outlined), findsOneWidget);
    expect(find.byIcon(Icons.qr_code_scanner_outlined), findsOneWidget);
    expect(find.byIcon(Icons.history_outlined), findsOneWidget);
  });
}
