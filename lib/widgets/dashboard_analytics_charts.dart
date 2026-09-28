import 'package:flutter/material.dart';

import '../models/dashboard_summary.dart';

class DashboardAnalyticsCharts extends StatefulWidget {
  const DashboardAnalyticsCharts({
    super.key,
    required this.summary,
    required this.isOwnerOrAdmin,
  });

  final DashboardSummary summary;
  final bool isOwnerOrAdmin;

  @override
  State<DashboardAnalyticsCharts> createState() => _DashboardAnalyticsChartsState();
}

class _DashboardAnalyticsChartsState extends State<DashboardAnalyticsCharts> {
  int _selectedDayIndex = 6; // Default to today / latest day

  static const List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const List<double> _dailyRevenue = [1250.0, 1840.0, 2100.0, 1950.0, 3200.0, 4150.0, 3800.0];
  static const List<int> _dailyBookings = [12, 19, 22, 20, 34, 45, 41];

  static const List<Map<String, dynamic>> _peakHours = [
    {'time': '08:00 - 11:00', 'label': 'Morning Peak', 'pct': 0.85, 'color': Color(0xFFF59E0B)},
    {'time': '11:00 - 14:00', 'label': 'Midday Lunch', 'pct': 0.95, 'color': Color(0xFFEF4444)},
    {'time': '14:00 - 17:00', 'label': 'Afternoon', 'pct': 0.70, 'color': Color(0xFF3B82F6)},
    {'time': '17:00 - 20:00', 'label': 'Evening Rush', 'pct': 0.90, 'color': Color(0xFF8B5CF6)},
    {'time': '20:00 - 08:00', 'label': 'Overnight', 'pct': 0.35, 'color': Color(0xFF64748B)},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (!widget.isOwnerOrAdmin) {
      return const SizedBox.shrink();
    }

    final maxRevenue = _dailyRevenue.reduce((a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 7-Day Revenue & Demand Trend Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.bar_chart_rounded, color: colors.primary, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '7-Day Revenue & Demand',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                            ),
                            Text(
                              'Tap any day bar for details',
                              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.trending_up_rounded, size: 14, color: Color(0xFF166534)),
                          SizedBox(width: 4),
                          Text(
                            '+18.4% this week',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Selected Day Info Banner
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_days[_selectedDayIndex]} Insights',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Row(
                        children: [
                          Text(
                            '₱${_dailyRevenue[_selectedDayIndex].toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: colors.primary,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '(${_dailyBookings[_selectedDayIndex]} bookings)',
                            style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Bar Chart
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_days.length, (index) {
                      final isSelected = index == _selectedDayIndex;
                      final heightPct = _dailyRevenue[index] / maxRevenue;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              '₱${(_dailyRevenue[index] / 1000).toStringAsFixed(1)}k',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 28,
                              height: 90 * heightPct,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colors.primary
                                    : colors.primary.withValues(alpha: 0.35),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                border: isSelected
                                    ? Border.all(color: Colors.white, width: 1.5)
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _days[index],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                                color: isSelected ? colors.primary : colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Peak Parking Hours Distribution
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.schedule_rounded, color: Colors.orange, size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peak Parking Hours & Turnover',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          'Occupancy trends by time of day',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                for (final item in _peakHours) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${item['label']} (${item['time']})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
                      ),
                      Text(
                        '${((item['pct'] as double) * 100).toInt()}% Capacity',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: item['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: item['pct'] as double,
                      minHeight: 8,
                      backgroundColor: colors.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(item['color'] as Color),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Vehicle Category Distribution
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.pie_chart_outline_rounded, color: Color(0xFF10B981), size: 22),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vehicle Type Breakdown',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                        Text(
                          'Distribution of parked vehicles',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _VehicleShareCard(
                        icon: Icons.directions_car_filled_rounded,
                        label: '4-Wheel Cars',
                        percentage: '68%',
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _VehicleShareCard(
                        icon: Icons.two_wheeler_rounded,
                        label: 'Motorcycles',
                        percentage: '26%',
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _VehicleShareCard(
                        icon: Icons.airport_shuttle_rounded,
                        label: 'Vans / Trucks',
                        percentage: '6%',
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleShareCard extends StatelessWidget {
  const _VehicleShareCard({
    required this.icon,
    required this.label,
    required this.percentage,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String percentage;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            percentage,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
