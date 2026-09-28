import 'package:e_parada_mobile/models/reservation_availability.dart';
import 'package:e_parada_mobile/widgets/visual_parking_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('VisualParkingGrid renders floor plan stalls and allows selecting available bay', (tester) async {
    final slots = [
      const ReservationSlot(
        id: 1,
        label: 'Bay A-1',
        supportedVehicleTypes: ['Car', 'Motorcycle'],
        supportsVehicle: true,
        isOccupied: false,
        isAvailable: true,
      ),
      const ReservationSlot(
        id: 2,
        label: 'Bay A-2',
        supportedVehicleTypes: ['Car'],
        supportsVehicle: true,
        isOccupied: true,
        isAvailable: false,
      ),
      const ReservationSlot(
        id: 3,
        label: 'Bay B-1',
        supportedVehicleTypes: ['Motorcycle'],
        supportsVehicle: false,
        isOccupied: false,
        isAvailable: false,
      ),
    ];

    ReservationSlot? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: VisualParkingGrid(
                  slots: slots,
                  selectedSlot: selected,
                  onSlotSelected: (slot) => setState(() => selected = slot),
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Select Parking Bay'), findsOneWidget);
    expect(find.text('Floor Plan'), findsOneWidget);
    expect(find.text('Grid'), findsOneWidget);
    expect(find.text('DRIVEWAY ENTRY & AISLE'), findsOneWidget);
    expect(find.text('Bay A-1'), findsWidgets);
    expect(find.text('Bay A-2'), findsWidgets);
    expect(find.text('Bay B-1'), findsWidgets);

    // Tap available slot Bay A-1
    await tester.tap(find.text('Bay A-1').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(selected?.id, equals(1));
    expect(find.text('Selected: Bay A-1 (Ready to reserve)'), findsOneWidget);

    // Switch to Grid layout mode
    await tester.tap(find.text('Grid'));
    await tester.pumpAndSettle();
    expect(find.text('Bay A-1'), findsWidgets);
  });
}
