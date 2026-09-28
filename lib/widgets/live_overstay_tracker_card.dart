import 'dart:async';
import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/driver_reservation.dart';
import '../services/reservation_service.dart';
import 'extend_parking_dialog.dart';

enum ParkingSessionPhase {
  upcoming,
  active,
  expiringSoon,
  gracePeriod,
  overstay,
  completed,
}

class LiveOverstayTrackerCard extends StatefulWidget {
  const LiveOverstayTrackerCard({
    super.key,
    required this.reservation,
    this.onExtensionRequested,
    this.isCompact = false,
    this.mockNow,
    this.graceMinutes = 15,
  });

  final DriverReservation reservation;
  final VoidCallback? onExtensionRequested;
  final bool isCompact;
  final DateTime? mockNow;
  final int graceMinutes;

  @override
  State<LiveOverstayTrackerCard> createState() => _LiveOverstayTrackerCardState();
}

class _LiveOverstayTrackerCardState extends State<LiveOverstayTrackerCard> {
  Timer? _ticker;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _now = widget.mockNow ?? DateTime.now();
    if (widget.mockNow == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) {
          setState(() {
            _now = DateTime.now();
          });
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant LiveOverstayTrackerCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mockNow != null) {
      _now = widget.mockNow!;
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  DateTime? get _startDateTime => widget.reservation.scheduledStartDateTime;
  DateTime? get _endDateTime => widget.reservation.scheduledEndDateTime;

  ParkingSessionPhase get _currentPhase {
    if (widget.reservation.status == 'completed' || widget.reservation.status == 'cancelled') {
      return ParkingSessionPhase.completed;
    }

    final end = _endDateTime;
    final start = _startDateTime;

    if (end == null || start == null) {
      return ParkingSessionPhase.active;
    }

    if (_now.isBefore(start)) {
      return ParkingSessionPhase.upcoming;
    }

    if (_now.isBefore(end)) {
      final diff = end.difference(_now);
      if (diff.inMinutes <= 15) {
        return ParkingSessionPhase.expiringSoon;
      }
      return ParkingSessionPhase.active;
    }

    final graceEnd = end.add(Duration(minutes: widget.graceMinutes));
    if (_now.isBefore(graceEnd)) {
      return ParkingSessionPhase.gracePeriod;
    }

    return ParkingSessionPhase.overstay;
  }

  String _formatDuration(Duration d) {
    final abs = d.abs();
    final hours = abs.inHours;
    final minutes = abs.inMinutes % 60;
    final seconds = abs.inSeconds % 60;

    final hStr = hours > 0 ? '${hours.toString().padLeft(2, '0')}h ' : '';
    final mStr = '${minutes.toString().padLeft(2, '0')}m ';
    final sStr = '${seconds.toString().padLeft(2, '0')}s';

    return '$hStr$mStr$sStr';
  }

  double get _estimatedHourlyRate {
    final amount = widget.reservation.totalAmount ?? 0.0;
    final hours = widget.reservation.totalHours ?? 1.0;
    if (amount > 0 && hours > 0) {
      return amount / hours;
    }
    return 30.0;
  }

  double _calculateOverstayFee(int overstayMinutes) {
    if (overstayMinutes <= 0) return 0.0;
    final billableHours = (overstayMinutes / 60.0).ceil();
    return billableHours * _estimatedHourlyRate;
  }

  Future<void> _requestQuickExtension(int extraMinutes) async {
    final end = _endDateTime ?? DateTime.now();
    final newEnd = end.add(Duration(minutes: extraMinutes));
    final cost = (extraMinutes / 60.0) * _estimatedHourlyRate;

    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF122744),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppPalette.naplesYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.more_time, color: AppPalette.naplesYellow, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quick Extend Parking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Add +$extraMinutes minutes to your reservation',
                        style: TextStyle(
                          color: AppPalette.powderBlue.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A192C),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.yaleBlue.withValues(alpha: 0.8)),
              ),
              child: Column(
                children: [
                  _summaryRow('Current End Time', _formatTime(TimeOfDay.fromDateTime(end))),
                  const Divider(color: Color(0xFF1B365D), height: 16),
                  _summaryRow('New End Time', _formatTime(TimeOfDay.fromDateTime(newEnd)), isHighlight: true),
                  const Divider(color: Color(0xFF1B365D), height: 16),
                  _summaryRow('Est. Additional Cost', 'PHP ${cost.toStringAsFixed(2)}', isHighlight: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF334E68)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.naplesYellow,
                      foregroundColor: const Color(0xFF0A192C),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text(
                      'Confirm Extension',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    final dateStr = '${newEnd.year.toString().padLeft(4, '0')}-${newEnd.month.toString().padLeft(2, '0')}-${newEnd.day.toString().padLeft(2, '0')}';
    final timeStr = '${newEnd.hour.toString().padLeft(2, '0')}:${newEnd.minute.toString().padLeft(2, '0')}';

    try {
      await ReservationService.requestExtension(
        reservationId: widget.reservation.id,
        endDate: dateStr,
        endTime: timeStr,
        reason: 'Quick extension via live session tracker (+${extraMinutes}m)',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF166534),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('+$extraMinutes min extension sent for owner approval!'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      widget.onExtensionRequested?.call();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to request extension: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _summaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppPalette.naplesYellow : Colors.white,
            fontSize: 14,
            fontWeight: isHighlight ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _formatTime(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final phase = _currentPhase;
    if (phase == ParkingSessionPhase.completed) {
      return const SizedBox.shrink();
    }

    final end = _endDateTime;

    Color badgeBg;
    Color badgeBorder;
    Color accentColor;
    IconData statusIcon;
    String statusTitle;
    String countdownLabel;
    String subtitle;

    switch (phase) {
      case ParkingSessionPhase.upcoming:
        badgeBg = const Color(0xFF0F2B48);
        badgeBorder = AppPalette.powderBlue.withValues(alpha: 0.3);
        accentColor = AppPalette.powderBlue;
        statusIcon = Icons.calendar_today_outlined;
        statusTitle = 'UPCOMING PARKING SESSION';
        final startsIn = _startDateTime?.difference(_now) ?? Duration.zero;
        countdownLabel = 'Starts in ${_formatDuration(startsIn)}';
        subtitle = 'Scheduled for ${widget.reservation.startTime} to ${widget.reservation.endTime}';
        break;

      case ParkingSessionPhase.active:
        badgeBg = const Color(0xFF0C2744);
        badgeBorder = const Color(0xFF1E4B7E);
        accentColor = const Color(0xFF38BDF8);
        statusIcon = Icons.timer_outlined;
        statusTitle = 'PARKING SESSION ACTIVE';
        final remaining = end?.difference(_now) ?? Duration.zero;
        countdownLabel = '${_formatDuration(remaining)} remaining';
        subtitle = 'Expires at ${widget.reservation.endTime} • Slot: ${widget.reservation.slotLabel}';
        break;

      case ParkingSessionPhase.expiringSoon:
        badgeBg = const Color(0xFF2A240E);
        badgeBorder = AppPalette.naplesYellow.withValues(alpha: 0.5);
        accentColor = AppPalette.naplesYellow;
        statusIcon = Icons.warning_amber_rounded;
        statusTitle = 'SESSION EXPIRING SOON';
        final remaining = end?.difference(_now) ?? Duration.zero;
        countdownLabel = '${_formatDuration(remaining)} remaining';
        subtitle = 'Extend now to prevent grace period transition';
        break;

      case ParkingSessionPhase.gracePeriod:
        badgeBg = const Color(0xFF332008);
        badgeBorder = const Color(0xFFF59E0B).withValues(alpha: 0.6);
        accentColor = const Color(0xFFF59E0B);
        statusIcon = Icons.shield_outlined;
        statusTitle = 'GRACE PERIOD ACTIVE (15 MINS)';
        final graceEnd = end?.add(Duration(minutes: widget.graceMinutes)) ?? _now;
        final graceLeft = graceEnd.difference(_now);
        countdownLabel = '${_formatDuration(graceLeft)} grace remaining';
        subtitle = 'No fee yet. Overstay charges start after grace ends.';
        break;

      case ParkingSessionPhase.overstay:
        badgeBg = const Color(0xFF380E14);
        badgeBorder = const Color(0xFFEF4444).withValues(alpha: 0.7);
        accentColor = const Color(0xFFEF4444);
        statusIcon = Icons.error_outline;
        final graceEnd = end?.add(Duration(minutes: widget.graceMinutes)) ?? _now;
        final overtimeMins = _now.difference(graceEnd).inMinutes + 1;
        final estFee = _calculateOverstayFee(overtimeMins);
        statusTitle = 'OVERSTAY ACTIVE (+$overtimeMins MINS)';
        countdownLabel = '+${_formatDuration(_now.difference(graceEnd))} overstay';
        subtitle = 'Est. overstay fee: PHP ${estFee.toStringAsFixed(2)} • Please extend or exit';
        break;

      case ParkingSessionPhase.completed:
        return const SizedBox.shrink();
    }

    if (widget.isCompact) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: badgeBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: badgeBorder),
        ),
        child: Row(
          children: [
            Icon(statusIcon, color: accentColor, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    statusTitle,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    countdownLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.reservation.canExtend && !widget.reservation.extensionPending)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: AppPalette.naplesYellow,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => ExtendParkingDialog.show(context, widget.reservation),
                child: const Text('Extend', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: accentColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusTitle,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                      ),
                    ),
                    Text(
                      countdownLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
              if (phase == ParkingSessionPhase.overstay)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '+PHP ${_calculateOverstayFee(_now.difference(end!.add(Duration(minutes: widget.graceMinutes))).inMinutes + 1).toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          if (widget.reservation.extensionPending) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppPalette.naplesYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppPalette.naplesYellow.withValues(alpha: 0.4)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppPalette.naplesYellow),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Extension request under owner review...',
                      style: TextStyle(
                        color: AppPalette.naplesYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else if (widget.reservation.canExtend) ...[
            const Divider(color: Color(0xFF1B365D), height: 16),
            Row(
              children: [
                Text(
                  'Quick Extend:',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _quickChip('+30m', () => _requestQuickExtension(30)),
                        const SizedBox(width: 6),
                        _quickChip('+1h', () => _requestQuickExtension(60)),
                        const SizedBox(width: 6),
                        _quickChip('+2h', () => _requestQuickExtension(120)),
                        const SizedBox(width: 6),
                        _quickChip('Custom...', () async {
                          final result = await ExtendParkingDialog.show(context, widget.reservation);
                          if (result == true) {
                            widget.onExtensionRequested?.call();
                          }
                        }, isCustom: true),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _quickChip(String label, VoidCallback onTap, {bool isCustom = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCustom
              ? const Color(0xFF1E3E6B)
              : AppPalette.naplesYellow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isCustom ? const Color(0xFF335C94) : AppPalette.naplesYellow,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isCustom ? AppPalette.powderBlue : AppPalette.naplesYellow,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
