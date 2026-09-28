import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../models/driver_reservation.dart';
import '../services/reservation_service.dart';
import '../utils/validators.dart';

class ExtendParkingDialog extends StatefulWidget {
  const ExtendParkingDialog({super.key, required this.reservation});

  final DriverReservation reservation;

  static Future<bool?> show(BuildContext context, DriverReservation reservation) {
    return showDialog<bool>(
      context: context,
      builder: (context) => ExtendParkingDialog(reservation: reservation),
    );
  }

  @override
  State<ExtendParkingDialog> createState() => _ExtendParkingDialogState();
}

class _ExtendParkingDialogState extends State<ExtendParkingDialog> {
  final List<int> _presetMinutes = [30, 60, 120, 180];
  int _selectedMinutes = 60;
  bool _isCustom = false;

  late DateTime _newEndDate;
  late TimeOfDay _newEndTime;
  final TextEditingController _reasonController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _computeNewEndFromMinutes(_selectedMinutes);
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  DateTime get _currentEndDateTime {
    final res = widget.reservation;
    final dateStr = res.endDate.isNotEmpty ? res.endDate : res.reservationDate;
    final baseDate = DateTime.tryParse(dateStr) ?? DateTime.now();
    final endTimeParts = res.endTime.split(':');
    final hour = int.tryParse(endTimeParts.isNotEmpty ? endTimeParts[0] : '0') ?? 0;
    final minute = int.tryParse(endTimeParts.length > 1 ? endTimeParts[1] : '0') ?? 0;
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }

  void _computeNewEndFromMinutes(int extraMinutes) {
    final target = _currentEndDateTime.add(Duration(minutes: extraMinutes));
    _newEndDate = DateTime(target.year, target.month, target.day);
    _newEndTime = TimeOfDay(hour: target.hour, minute: target.minute);
  }

  double get _estimatedExtraCost {
    final amount = widget.reservation.totalAmount ?? 0.0;
    final rate = amount > 0 ? (amount / 2.0) : 50.0;
    final hours = _selectedMinutes / 60.0;
    return rate * hours;
  }

  Future<void> _submitExtension() async {
    setState(() => _submitting = true);
    try {
      await ReservationService.requestExtension(
        reservationId: widget.reservation.id,
        endDate: _formatDate(_newEndDate),
        endTime: _formatTime(_newEndTime),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF166534),
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Extension request submitted to owner successfully!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final ref = Validators.formatReservationNumber(
      widget.reservation.backupReference,
      id: widget.reservation.id,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPalette.yaleBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.more_time_rounded,
                      color: AppPalette.yaleBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Extend Parking Time',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          '$ref • ${widget.reservation.parkingSpaceName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current Schedule Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'CURRENT END TIME',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${widget.reservation.endDate.isNotEmpty ? widget.reservation.endDate : widget.reservation.reservationDate} at ${widget.reservation.endTime}',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'NEW END TIME',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF166534),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_formatDate(_newEndDate)} ${_formatTime(_newEndTime)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: Color(0xFF166534),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Duration Presets
              Text(
                'Select Additional Duration',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._presetMinutes.map((mins) {
                    final label = mins < 60 ? '+$mins mins' : '+${mins ~/ 60} ${mins == 60 ? 'hr' : 'hrs'}';
                    final isSelected = !_isCustom && _selectedMinutes == mins;
                    return ChoiceChip(
                      label: Text(label),
                      selected: isSelected,
                      selectedColor: AppPalette.yaleBlue,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedMinutes = mins;
                            _isCustom = false;
                            _computeNewEndFromMinutes(mins);
                          });
                        }
                      },
                    );
                  }),
                  ChoiceChip(
                    label: const Text('Custom Picker'),
                    selected: _isCustom,
                    selectedColor: AppPalette.yaleBlue,
                    labelStyle: TextStyle(
                      color: _isCustom ? Colors.white : colors.onSurface,
                      fontWeight: FontWeight.w800,
                    ),
                    onSelected: (selected) {
                      setState(() => _isCustom = selected);
                    },
                  ),
                ],
              ),

              if (_isCustom) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.calendar_today_outlined, size: 16),
                        label: Text(_formatDate(_newEndDate)),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _newEndDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 30)),
                          );
                          if (picked != null) {
                            setState(() => _newEndDate = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.access_time_rounded, size: 16),
                        label: Text(_formatTime(_newEndTime)),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: _newEndTime,
                          );
                          if (picked != null) {
                            setState(() => _newEndTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 14),

              // Reason field
              TextField(
                controller: _reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Reason for extension (Optional)',
                  hintText: 'e.g. Traffic delay, meeting extended...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 14),

              // Cost Estimate Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppPalette.naplesYellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppPalette.naplesYellow.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: AppPalette.yaleBlue),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Estimated additional cost: ~₱${_estimatedExtraCost.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppPalette.yaleBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Submit Button
              FilledButton.icon(
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(_submitting ? 'Submitting...' : 'Request Extension'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.yaleBlue,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _submitting ? null : _submitExtension,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) =>
      '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
