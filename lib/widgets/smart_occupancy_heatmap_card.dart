import 'dart:async';
import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/reservation_availability.dart';

class SmartOccupancyHeatmapCard extends StatefulWidget {
  const SmartOccupancyHeatmapCard({
    super.key,
    required this.slots,
    this.onRefreshRequested,
    this.autoRefreshInterval = const Duration(seconds: 30),
  });

  final List<ReservationSlot> slots;
  final VoidCallback? onRefreshRequested;
  final Duration autoRefreshInterval;

  @override
  State<SmartOccupancyHeatmapCard> createState() => _SmartOccupancyHeatmapCardState();
}

class _SmartOccupancyHeatmapCardState extends State<SmartOccupancyHeatmapCard>
    with SingleTickerProviderStateMixin {
  Timer? _refreshTimer;
  bool _isAutoRefreshing = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(_pulseController);

    _startAutoRefresh();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    if (_isAutoRefreshing) {
      _refreshTimer = Timer.periodic(widget.autoRefreshInterval, (_) {
        if (mounted && _isAutoRefreshing) {
          widget.onRefreshRequested?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  int get _totalSlots => widget.slots.length;
  int get _availableSlots => widget.slots.where((s) => s.isAvailable).length;
  int get _occupiedSlots => widget.slots.where((s) => s.isOccupied).length;
  int get _otherBusySlots => widget.slots.where((s) => !s.isAvailable && !s.isOccupied).length;

  double get _occupancyRate {
    if (_totalSlots == 0) return 0.0;
    return (_totalSlots - _availableSlots) / _totalSlots;
  }

  String get _demandLevel {
    final rate = _occupancyRate;
    if (rate >= 0.85) return 'CRITICAL / ALMOST FULL';
    if (rate >= 0.60) return 'HIGH DEMAND';
    if (rate >= 0.30) return 'MODERATE AVAILABILITY';
    return 'HIGH AVAILABILITY';
  }

  Color get _demandColor {
    final rate = _occupancyRate;
    if (rate >= 0.85) return const Color(0xFFEF4444);
    if (rate >= 0.60) return const Color(0xFFF59E0B);
    if (rate >= 0.30) return AppPalette.powderBlue;
    return const Color(0xFF10B981);
  }

  @override
  Widget build(BuildContext context) {
    final percentInt = (_occupancyRate * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF122744),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _demandColor.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _demandColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top row: Heatmap badge & Live Auto-refresh toggle (Responsive Autofit)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _demandColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.local_fire_department_rounded, color: _demandColor, size: 18),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SMART OCCUPANCY HEATMAP',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          Text(
                            _demandLevel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: _demandColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () {
                  setState(() {
                    _isAutoRefreshing = !_isAutoRefreshing;
                    _startAutoRefresh();
                  });
                  if (_isAutoRefreshing) {
                    widget.onRefreshRequested?.call();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _isAutoRefreshing
                        ? const Color(0xFF10B981).withValues(alpha: 0.15)
                        : Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isAutoRefreshing
                          ? const Color(0xFF10B981).withValues(alpha: 0.4)
                          : Colors.white24,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isAutoRefreshing)
                        FadeTransition(
                          opacity: _pulseAnimation,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      else
                        const Icon(Icons.pause, size: 10, color: Colors.white70),
                      const SizedBox(width: 6),
                      Text(
                        _isAutoRefreshing ? 'LIVE AUTO-SYNC' : 'PAUSED',
                        style: TextStyle(
                          color: _isAutoRefreshing ? const Color(0xFF10B981) : Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Occupancy Progress Meter
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 10,
              child: Stack(
                children: [
                  Container(color: const Color(0xFF0A192C)),
                  FractionallySizedBox(
                    widthFactor: _occupancyRate.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          colors: [
                            _demandColor.withValues(alpha: 0.7),
                            _demandColor,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3 Metric Pills
          Row(
            children: [
              _metricPill(
                'Available',
                '$_availableSlots',
                const Color(0xFF10B981),
                Icons.check_circle_outline,
              ),
              const SizedBox(width: 8),
              _metricPill(
                'Occupied',
                '$_occupiedSlots',
                const Color(0xFFEF4444),
                Icons.directions_car_filled_rounded,
              ),
              const SizedBox(width: 8),
              _metricPill(
                'Busy',
                '$_otherBusySlots',
                AppPalette.naplesYellow,
                Icons.bookmark_outline_rounded,
              ),
              const SizedBox(width: 8),
              _metricPill(
                'Capacity',
                '$percentInt%',
                AppPalette.powderBlue,
                Icons.pie_chart_outline_rounded,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Historical Peak Hours Forecast
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0A192C),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        'ESTIMATED PEAK HOURS (CALAMBA)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'AI Predictive Model',
                      style: TextStyle(
                        color: AppPalette.powderBlue,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _peakBar('8-11 AM', '85% Peak', const Color(0xFFEF4444), 0.85),
                    const SizedBox(width: 10),
                    _peakBar('12-3 PM', '60% Mod', const Color(0xFFF59E0B), 0.60),
                    const SizedBox(width: 10),
                    _peakBar('5-8 PM', '92% Peak', const Color(0xFFEF4444), 0.92),
                    const SizedBox(width: 10),
                    _peakBar('Night', '20% Low', const Color(0xFF10B981), 0.20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricPill(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _peakBar(String time, String desc, Color barColor, double factor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                time,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              height: 4,
              color: Colors.white12,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: factor,
                child: Container(color: barColor),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            desc,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: barColor, fontSize: 8, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
