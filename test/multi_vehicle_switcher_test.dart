import 'package:e_parada_mobile/models/vehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MultiVehicleSwitcher displays multiple approved vehicles and switches selection on tap', (tester) async {
    final vehicle1 = Vehicle.fromJson({
      'id': 11,
      'plate_number': 'ABC 1234',
      'vehicle_type': 'Car',
      'vehicle_make': 'Toyota',
      'vehicle_model': 'Vios',
      'vehicle_color': 'Silver',
      'status': 'approved',
    });

    final vehicle2 = Vehicle.fromJson({
      'id': 12,
      'plate_number': 'XYZ 5678',
      'vehicle_type': 'Motorcycle',
      'vehicle_make': 'Yamaha',
      'vehicle_model': 'NMAX',
      'vehicle_color': 'Matte Black',
      'status': 'approved',
    });

    Vehicle? selected = vehicle1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              final vehicles = [vehicle1, vehicle2];
              return Column(
                children: [
                  Text('Current Selected: ${selected?.plateNumber}'),
                  Expanded(
                    child: ListView.builder(
                      itemCount: vehicles.length,
                      itemBuilder: (context, index) {
                        final v = vehicles[index];
                        final isSel = selected?.id == v.id;
                        return ListTile(
                          title: Text(v.plateNumber),
                          subtitle: Text(v.vehicleType),
                          trailing: isSel ? const Icon(Icons.check) : null,
                          onTap: () => setState(() => selected = v),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('Current Selected: ABC 1234'), findsOneWidget);
    expect(find.text('XYZ 5678'), findsOneWidget);

    await tester.tap(find.text('XYZ 5678'));
    await tester.pumpAndSettle();

    expect(find.text('Current Selected: XYZ 5678'), findsOneWidget);
  });
}
