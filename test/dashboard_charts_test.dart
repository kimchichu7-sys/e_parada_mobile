import 'package:e_parada_mobile/models/dashboard_summary.dart';
import 'package:e_parada_mobile/widgets/dashboard_analytics_charts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DashboardAnalyticsCharts renders 7-day revenue, peak hours, and vehicle distribution', (tester) async {
    final summary = DashboardSummary.fromJson({
      'title': 'Owner Dashboard',
      'subtitle': 'Manage your parking spaces and track earnings',
      'role': 'parking_owner',
      'metrics': [
        {'key': 'total_revenue', 'label': 'Total Revenue', 'value': '₱15,400'},
        {'key': 'active_spaces', 'label': 'Active Spaces', 'value': '4'},
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: DashboardAnalyticsCharts(
              summary: summary,
              isOwnerOrAdmin: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('7-Day Revenue & Demand'), findsOneWidget);
    expect(find.text('+18.4% this week'), findsOneWidget);
    expect(find.text('Peak Parking Hours & Turnover'), findsOneWidget);
    expect(find.text('Vehicle Type Breakdown'), findsOneWidget);
    expect(find.text('4-Wheel Cars'), findsOneWidget);
    expect(find.text('Motorcycles'), findsOneWidget);
    expect(find.text('Vans / Trucks'), findsOneWidget);

    // Tap on Monday bar
    await tester.tap(find.text('Mon'));
    await tester.pumpAndSettle();
    expect(find.text('Mon Insights'), findsOneWidget);
  });
}
