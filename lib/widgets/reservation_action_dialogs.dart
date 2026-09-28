import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/driver_reservation.dart';
import 'gcash_payment_gateway_dialog.dart';

class RescheduleSelection {
  const RescheduleSelection({
    required this.reservationDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  final String reservationDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String reason;
}

class FeedbackSelection {
  const FeedbackSelection({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

class PaymentSelection {
  const PaymentSelection({
    required this.method,
    this.proof,
    this.gcashReference,
  });

  final String method;
  final XFile? proof;
  final String? gcashReference;
}

Future<PaymentSelection?> showBillingPaymentDialog(
  BuildContext context,
  DriverReservation reservation,
) async {
  String method = 'cash';
  XFile? proof;
  String? gcashRef;

  // Compute duration metrics if timeIn and timeOut exist
  String durationLabel = 'Scheduled Duration';
  if (reservation.timeIn != null && reservation.timeOut != null) {
    final diff = reservation.timeOut!.difference(reservation.timeIn!);
    final hours = diff.inHours;
    final mins = diff.inMinutes % 60;
    durationLabel = '$hours hr ${mins.toString().padLeft(2, '0')} min (Actual)';
  } else if (reservation.totalHours != null) {
    durationLabel = '${reservation.totalHours} hrs (Estimated)';
  }

  final totalDue = reservation.totalAmount ?? 0.0;
  final hasOverstay = reservation.overstayMinutes > 0 || reservation.overstayAmount > 0;

  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) {
        final colors = Theme.of(context).colorScheme;

        return AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.receipt_long_rounded, color: colors.primary, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Itemized Billing Statement',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reservation.parkingSpaceName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${reservation.backupReference}  •  ${reservation.slotLabel}',
                          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                        ),
                        Text(
                          '${reservation.plateNumber} (${reservation.vehicleType})',
                          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Billing Breakdown',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 8),
                  _buildBillingRow(
                    context: context,
                    label: 'Session Duration',
                    value: durationLabel,
                    icon: Icons.timer_outlined,
                  ),
                  _buildBillingRow(
                    context: context,
                    label: 'Grace Period',
                    value: '- 15 mins deducted',
                    valueColor: Colors.green.shade700,
                    icon: Icons.check_circle_outline,
                  ),
                  if (hasOverstay)
                    _buildBillingRow(
                      context: context,
                      label: 'Overstay (${reservation.overstayMinutes} mins)',
                      value: '+ PHP ${reservation.overstayAmount.toStringAsFixed(2)}',
                      valueColor: colors.error,
                      icon: Icons.warning_amber_rounded,
                    ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable Amount',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        'PHP ${totalDue.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Select Settlement Method',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 0.3),
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'cash',
                        icon: Icon(Icons.payments_outlined),
                        label: Text('Cash'),
                      ),
                      ButtonSegment(
                        value: 'gcash',
                        icon: Icon(Icons.account_balance_wallet_outlined),
                        label: Text('GCash'),
                      ),
                    ],
                    selected: {method},
                    onSelectionChanged: (selected) {
                      setDialogState(() => method = selected.first);
                    },
                  ),
                  const SizedBox(height: 12),
                  if (method == 'cash')
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, size: 20, color: colors.primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash Settlement',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: colors.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Hand PHP ${totalDue.toStringAsFixed(2)} cash directly to the space attendant or owner upon departure.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    if (gcashRef != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF064E3B).withValues(alpha: 0.5)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF059669)
                                : const Color(0xFF86EFAC),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 24),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'GCash Payment Verified',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFF6EE7B7)
                                          : const Color(0xFF166534),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ref ID: $gcashRef',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? const Color(0xFFA7F3D0)
                                          : const Color(0xFF15803D),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    else ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF005CEE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () async {
                            final result = await GcashPaymentGatewayDialog.show(
                              context: context,
                              parkingSpaceName: reservation.parkingSpaceName,
                              reservationReference: reservation.backupReference,
                              totalAmount: totalDue,
                            );
                            if (result != null && result.success) {
                              setDialogState(() {
                                gcashRef = result.referenceNo;
                              });
                            }
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 18),
                          label: Text(
                            'Proceed to GCash (PHP ${totalDue.toStringAsFixed(2)})',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              'OR ATTACH SCREENSHOT (OPTIONAL)',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final selected = await ImagePicker().pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (selected != null) {
                              setDialogState(() => proof = selected);
                            }
                          },
                          icon: Icon(
                            proof == null
                                ? Icons.add_photo_alternate_outlined
                                : Icons.check_circle_outline,
                          ),
                          label: Text(
                            proof == null
                                ? 'Attach GCash Receipt Screenshot'
                                : 'Receipt: ${proof!.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton.icon(
              onPressed: (method == 'gcash' && proof == null && gcashRef == null)
                  ? null
                  : () => Navigator.pop(context, true),
              icon: const Icon(Icons.check_circle_outline, size: 18),
              label: Text(
                method == 'cash'
                    ? 'Confirm Cash Payment'
                    : (gcashRef != null
                        ? 'Confirm Settlement (₱${totalDue.toStringAsFixed(2)})'
                        : 'Submit Payment Details'),
              ),
            ),
          ],
        );
      },
    ),
  );

  if (accepted != true) return null;
  return PaymentSelection(method: method, proof: proof, gcashReference: gcashRef);
}

Widget _buildBillingRow({
  required BuildContext context,
  required String label,
  required String value,
  required IconData icon,
  Color? valueColor,
}) {
  final colors = Theme.of(context).colorScheme;
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Icon(icon, size: 16, color: colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: colors.onSurface)),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? colors.onSurface,
          ),
        ),
      ],
    ),
  );
}

Future<RescheduleSelection?> showRescheduleDialog(
  BuildContext context,
  DriverReservation reservation,
) async {
  final today = DateUtils.dateOnly(DateTime.now());
  var startDate = DateTime.tryParse(reservation.reservationDate) ?? today;
  if (startDate.isBefore(today)) startDate = today;
  var endDate = DateTime.tryParse(reservation.endDate) ?? startDate;
  if (endDate.isBefore(startDate)) endDate = startDate;
  var startTime = _parseTime(reservation.startTime);
  var endTime = _parseTime(reservation.endTime);
  final reasonController = TextEditingController();

  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Reschedule ${reservation.backupReference}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The parking owner must approve the new schedule again.',
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Start date'),
                  subtitle: Text(_date(startDate)),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: today,
                      lastDate: today.add(const Duration(days: 365)),
                    );
                    if (selected == null) return;
                    setDialogState(() {
                      startDate = selected;
                      if (endDate.isBefore(startDate)) endDate = startDate;
                    });
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Start time'),
                  subtitle: Text(startTime.format(context)),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (selected != null) {
                      setDialogState(() => startTime = selected);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('End date'),
                  subtitle: Text(_date(endDate)),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: endDate.isBefore(startDate)
                          ? startDate
                          : endDate,
                      firstDate: startDate,
                      lastDate: today.add(const Duration(days: 365)),
                    );
                    if (selected != null) {
                      setDialogState(() => endDate = selected);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.more_time_outlined),
                  title: const Text('End time'),
                  subtitle: Text(endTime.format(context)),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (selected != null) {
                      setDialogState(() => endTime = selected);
                    }
                  },
                ),
                TextField(
                  controller: reasonController,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Optional reason',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send for approval'),
          ),
        ],
      ),
    ),
  );

  final reason = reasonController.text.trim();
  reasonController.dispose();
  if (accepted != true) return null;

  return RescheduleSelection(
    reservationDate: _date(startDate),
    endDate: _date(endDate),
    startTime: _time(startTime),
    endTime: _time(endTime),
    reason: reason,
  );
}

Future<FeedbackSelection?> showFeedbackDialog(
  BuildContext context,
  DriverReservation reservation,
) async {
  var rating = 5;
  final commentController = TextEditingController();

  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Rate ${reservation.parkingSpaceName}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    tooltip: '$value star',
                    onPressed: () => setDialogState(() => rating = value),
                    icon: Icon(
                      value <= rating ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade700,
                      size: 34,
                    ),
                  );
                }),
              ),
              Text('$rating of 5 stars'),
              const SizedBox(height: 14),
              TextField(
                controller: commentController,
                maxLength: 2000,
                maxLines: 5,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Share your parking experience',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: commentController.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Submit feedback'),
          ),
        ],
      ),
    ),
  );

  final comment = commentController.text.trim();
  commentController.dispose();
  if (accepted != true) return null;
  return FeedbackSelection(rating: rating, comment: comment);
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0,
    minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
  );
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _time(TimeOfDay value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
