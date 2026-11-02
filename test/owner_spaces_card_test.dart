import 'package:e_parada_mobile/config/app_theme.dart';
import 'package:e_parada_mobile/models/owner_parking_space.dart';
import 'package:e_parada_mobile/screens/owner_spaces_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OwnerSpaceCard renders compact layout with left-aligned actions and no overflow on narrow screens', (tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final space = OwnerParkingSpace.fromJson({
      'id': 1,
      'space_name': 'SM Calamba',
      'address': 'National Highway, Brgy. Real, Calamba City, Laguna (adjacent to SM City Calamba & Grand Terminal)',
      'approval_status': 'approved',
      'is_available': true,
      'is_open_now': true,
      'operating_hours': '9:00 AM - 10:00 PM',
      'active_slots_count': 50,
      'pending_reservations_count': 0,
      'vehicle_types': ['Car', 'SUV/MPV', 'Motorcycle', 'Pickup/Van'],
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: SingleChildScrollView(
            child: OwnerSpaceCard(
              space: space,
              onEdit: () {},
              onDelete: () {},
              onReportUnavailable: () {},
              onRestoreAvailable: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.text('SM Calamba'), findsOneWidget);
    expect(find.textContaining('SM City Calamba'), findsOneWidget);
    expect(find.text('9:00 AM - 10:00 PM'), findsOneWidget);
    expect(find.text('50 active slots'), findsOneWidget);
    expect(find.text('0 pending requests'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
    expect(find.text('Car • SUV/MPV • Motorcycle • Pickup/Van'), findsOneWidget);

    // Verify left-aligned action buttons
    final reportBtn = find.text('Report Unavailable');
    final editBtn = find.text('Edit');
    expect(reportBtn, findsOneWidget);
    expect(editBtn, findsOneWidget);

    // Verify Wrap alignment is WrapAlignment.start
    final wrapFinder = find.ancestor(
      of: reportBtn,
      matching: find.byType(Wrap),
    );
    final wrapWidget = tester.widget<Wrap>(wrapFinder.first);
    expect(wrapWidget.alignment, WrapAlignment.start);

    // Verify the Align ancestor of the Wrap has Alignment.centerLeft
    final alignFinder = find.ancestor(
      of: wrapFinder,
      matching: find.byType(Align),
    );
    expect(alignFinder, findsWidgets);
    final alignWidget = tester.widget<Align>(alignFinder.first);
    expect(alignWidget.alignment, Alignment.centerLeft);

    // Verify no rendering overflow exceptions
    expect(tester.takeException(), isNull);
  });
}
