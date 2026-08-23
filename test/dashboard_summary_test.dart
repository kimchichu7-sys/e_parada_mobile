import 'package:e_parada_mobile/models/dashboard_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses a role-specific dashboard response', () {
    final summary = DashboardSummary.fromJson({
      'role': 'parking_owner',
      'title': 'Parking owner dashboard',
      'subtitle': 'Manage your E-Parada operations.',
      'metrics': [
        {'key': 'spaces', 'label': 'Parking spaces', 'value': 3},
        {'key': 'pending', 'label': 'Pending requests', 'value': 2},
      ],
    });

    expect(summary.role, 'parking_owner');
    expect(summary.metrics.length, 2);
    expect(summary.metrics.first.label, 'Parking spaces');
    expect(summary.metrics.first.value, 3);
  });
}
