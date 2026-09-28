import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:e_parada_mobile/models/reservation_availability.dart';
import 'package:e_parada_mobile/widgets/smart_occupancy_heatmap_card.dart';

void main() {
  final sampleSlots = [
    const ReservationSlot(
      id: 1,
      label: 'Slot A1',
      supportedVehicleTypes: ['Car'],
      supportsVehicle: true,
      isOccupied: false,
      isAvailable: true,
    ),
    const ReservationSlot(
      id: 2,
      label: 'Slot A2',
      supportedVehicleTypes: ['Car'],
      supportsVehicle: true,
      isOccupied: true,
      isAvailable: false,
    ),
    const ReservationSlot(
      id: 3,
      label: 'Slot A3',
      supportedVehicleTypes: ['Car'],
      supportsVehicle: true,
      isOccupied: false,
      isAvailable: false,
    ),
    const ReservationSlot(
      id: 4,
      label: 'Slot B1',
      supportedVehicleTypes: ['Car'],
      supportsVehicle: true,
      isOccupied: false,
      isAvailable: true,
    ),
  ];

  testWidgets('SmartOccupancyHeatmapCard renders capacity, metrics, and peak demand forecast', (tester) async {
    bool refreshTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: SmartOccupancyHeatmapCard(
              slots: sampleSlots,
              onRefreshRequested: () {
                refreshTapped = true;
              },
            ),
          ),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Verify key metrics
    expect(find.text('SMART OCCUPANCY HEATMAP'), findsOneWidget);
    expect(find.text('MODERATE AVAILABILITY'), findsOneWidget);
    expect(find.text('50%'), findsOneWidget); // 2 occupied/busy out of 4 (50% occupancy rate)

    // Verify stat pills
    expect(find.text('2'), findsWidgets); // 2 available, 50% capacity
    expect(find.text('1'), findsWidgets); // 1 occupied, 1 busy
    expect(find.text('Available'), findsOneWidget);
    expect(find.text('Occupied'), findsOneWidget);
    expect(find.text('Busy'), findsOneWidget);
    expect(find.text('Capacity'), findsOneWidget);

    // Verify Peak demand section
    expect(find.text('ESTIMATED PEAK HOURS (CALAMBA)'), findsOneWidget);
    expect(find.text('AI Predictive Model'), findsOneWidget);
    expect(find.text('8-11 AM'), findsOneWidget);
    expect(find.text('12-3 PM'), findsOneWidget);
    expect(find.text('5-8 PM'), findsOneWidget);
    expect(find.text('Night'), findsOneWidget);

    // Verify toggle auto-refresh ticker
    final tickerChip = find.text('LIVE AUTO-SYNC');
    expect(tickerChip, findsOneWidget);
    await tester.tap(tickerChip);
    await tester.pump();
    expect(find.text('PAUSED'), findsOneWidget);
    expect(refreshTapped, isFalse);
  });
}
