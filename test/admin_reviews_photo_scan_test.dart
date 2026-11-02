import 'package:e_parada_mobile/config/app_theme.dart';
import 'package:e_parada_mobile/screens/admin_reviews_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AdminReviewsScreen renders photo scan banner without overflow on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AdminReviewsScreen(),
      ),
    );

    // Verify Admin Reviews AppBar renders properly
    expect(find.text('Admin Reviews'), findsOneWidget);
    expect(find.byIcon(Icons.fact_check_outlined), findsOneWidget);
  });
}
