import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/driver_reservation.dart';
import '../services/api_client.dart';
import '../services/reservation_service.dart';
import '../widgets/reservation_action_dialogs.dart';
import '../widgets/reservation_credential_dialog.dart';
import 'reservation_conversation_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  late Future<List<DriverReservation>> _future;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _future = ReservationService.fetchReservations();
  }

  Future<void> _refresh() async {
    final future = ReservationService.fetchReservations();
    setState(() => _future = future);
    await future;
  }

  Future<void> _perform(Future<String> Function() action) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      final message = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.error_outline),
          title: const Text('Unable to update reservation'),
          content: Text(error.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _cancel(DriverReservation reservation) async {
    final controller = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel ${reservation.backupReference}?'),
        content: TextField(
          controller: controller,
          maxLength: 1000,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Optional reason',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel reservation'),
          ),
        ],
      ),
    );
    final reason = controller.text.trim();
    controller.dispose();
    if (confirmed != true) return;
    await _perform(
      () => ReservationService.cancel(reservation.id, reason: reason),
    );
  }

  Future<void> _reschedule(DriverReservation reservation) async {
    if (reservation.vehicleId <= 0) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Vehicle unavailable'),
          content: const Text(
            'This reservation is missing its vehicle record and cannot be rescheduled.',
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    final selection = await showRescheduleDialog(context, reservation);
    if (selection == null) return;
    await _perform(
      () => ReservationService.reschedule(
        reservationId: reservation.id,
        vehicleId: reservation.vehicleId,
        reservationDate: selection.reservationDate,
        endDate: selection.endDate,
        startTime: selection.startTime,
        endTime: selection.endTime,
        reason: selection.reason,
      ),
    );
  }

  Future<void> _feedback(DriverReservation reservation) async {
    final selection = await showFeedbackDialog(context, reservation);
    if (selection == null) return;
    await _perform(
      () => ReservationService.submitFeedback(
        reservationId: reservation.id,
        rating: selection.rating,
        comment: selection.comment,
      ),
    );
  }

  Future<void> _extend(DriverReservation reservation) async {
    DateTime date = DateTime.tryParse(reservation.endDate) ?? DateTime.now();
    final currentParts = reservation.endTime.split(':');
    TimeOfDay time = TimeOfDay(
      hour: int.tryParse(currentParts.isNotEmpty ? currentParts[0] : '') ?? 0,
      minute: int.tryParse(currentParts.length > 1 ? currentParts[1] : '') ?? 0,
    );
    final reasonController = TextEditingController();

    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Extend ${reservation.backupReference}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('New end date'),
                subtitle: Text(_date(date)),
                onTap: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: date,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (selected != null) setDialogState(() => date = selected);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.more_time_outlined),
                title: const Text('New end time'),
                subtitle: Text(time.format(context)),
                onTap: () async {
                  final selected = await showTimePicker(
                    context: context,
                    initialTime: time,
                  );
                  if (selected != null) setDialogState(() => time = selected);
                },
              ),
              TextField(
                controller: reasonController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Optional reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Send request'),
            ),
          ],
        ),
      ),
    );
    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (accepted != true) return;

    await _perform(
      () => ReservationService.requestExtension(
        reservationId: reservation.id,
        endDate: _date(date),
        endTime: _time(time),
        reason: reason,
      ),
    );
  }

  Future<void> _pay(DriverReservation reservation) async {
    String method = 'gcash';
    XFile? proof;
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Pay ${reservation.backupReference}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: method,
                decoration: const InputDecoration(
                  labelText: 'Payment method',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'gcash', child: Text('GCash')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                ],
                onChanged: (value) =>
                    setDialogState(() => method = value ?? 'gcash'),
              ),
              if (method == 'gcash') ...[
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () async {
                    final selected = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                    if (selected != null) {
                      setDialogState(() => proof = selected);
                    }
                  },
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(
                    proof == null ? 'Choose proof image' : proof!.name,
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: method == 'gcash' && proof == null
                  ? null
                  : () => Navigator.pop(context, true),
              child: const Text('Submit payment'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true) return;
    final file = proof;
    await _perform(
      () async => ReservationService.submitPayment(
        reservationId: reservation.id,
        paymentMethod: method,
        paymentProof: file == null
            ? null
            : UploadFileData(
                bytes: await file.readAsBytes(),
                filename: file.name,
              ),
      ),
    );
  }

  Future<void> _showCredential(DriverReservation reservation) {
    return showReservationCredentialDialog(
      context: context,
      qrCode: reservation.qrCode,
      backupReference: reservation.backupReference,
      parkingSpaceName: reservation.parkingSpaceName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reservations')),
      body: Stack(
        children: [
          FutureBuilder<List<DriverReservation>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _Message(
                  message: snapshot.error.toString(),
                  onRetry: _refresh,
                );
              }
              final reservations = snapshot.data ?? const <DriverReservation>[];
              if (reservations.isEmpty) {
                return _Message(
                  message: 'No reservations yet.',
                  onRetry: _refresh,
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: reservations.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final reservation = reservations[index];
                    return _ReservationCard(
                      reservation: reservation,
                      disabled: _acting,
                      onCredential: () => _showCredential(reservation),
                      onReschedule: () => _reschedule(reservation),
                      onFeedback: () => _feedback(reservation),
                      onCancel: () => _cancel(reservation),
                      onExtend: () => _extend(reservation),
                      onPay: () => _pay(reservation),
                      onContact: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ReservationConversationScreen(
                            reservationId: reservation.id,
                            otherPartyName: reservation.ownerName,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          if (_acting)
            const Positioned.fill(
              child: ColoredBox(
                color: Color(0x33000000),
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _time(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.disabled,
    required this.onCredential,
    required this.onReschedule,
    required this.onFeedback,
    required this.onCancel,
    required this.onExtend,
    required this.onPay,
    required this.onContact,
  });

  final DriverReservation reservation;
  final bool disabled;
  final VoidCallback onCredential;
  final VoidCallback onReschedule;
  final VoidCallback onFeedback;
  final VoidCallback onCancel;
  final VoidCallback onExtend;
  final VoidCallback onPay;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    reservation.parkingSpaceName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Chip(label: Text(_title(reservation.status))),
              ],
            ),
            Text('${reservation.backupReference} | ${reservation.slotLabel}'),
            const Divider(height: 26),
            ReservationProgressTracker(
              status: reservation.status,
              paymentStatus: reservation.paymentStatus,
              timeIn: reservation.timeIn,
              timeOut: reservation.timeOut,
            ),
            const SizedBox(height: 14),
            _line(Icons.schedule_outlined, reservation.scheduleLabel),
            _line(
              Icons.directions_car_outlined,
              '${reservation.plateNumber} | ${reservation.vehicleType}',
            ),
            _line(Icons.payments_outlined, _paymentLabel(reservation)),
            if (reservation.ownerNotes.isNotEmpty)
              _line(Icons.notes_outlined, 'Owner: ${reservation.ownerNotes}'),
            if (reservation.extensionStatus.isNotEmpty)
              _line(
                Icons.more_time_outlined,
                'Extension ${_title(reservation.extensionStatus)}'
                '${reservation.extensionEndDate.isEmpty ? '' : ' to ${reservation.extensionEndDate} ${reservation.extensionEndTime}'}',
              ),
            if (reservation.feedbackRating != null)
              _line(
                Icons.star_outline_rounded,
                'Your feedback: ${reservation.feedbackRating}/5',
              ),
            if (reservation.overstayStatus != 'normal')
              _line(
                Icons.warning_amber_outlined,
                '${_title(reservation.overstayStatus)} | ${reservation.overstayMinutes} minutes | PHP ${reservation.overstayAmount.toStringAsFixed(2)}',
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (reservation.status == 'approved' &&
                    reservation.hasCredential)
                  FilledButton.icon(
                    onPressed: disabled ? null : onCredential,
                    icon: const Icon(Icons.qr_code_2),
                    label: const Text('Entry code'),
                  ),
                if (reservation.canReschedule)
                  OutlinedButton.icon(
                    onPressed: disabled ? null : onReschedule,
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: const Text('Reschedule'),
                  ),
                if (reservation.canSubmitFeedback)
                  FilledButton.icon(
                    onPressed: disabled ? null : onFeedback,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: const Text('Rate parking'),
                  ),
                if (reservation.canExtend)
                  OutlinedButton.icon(
                    onPressed: disabled ? null : onExtend,
                    icon: const Icon(Icons.more_time_outlined),
                    label: const Text('Extend'),
                  ),
                if (reservation.canSubmitPayment &&
                    reservation.paymentStatus == 'unpaid')
                  FilledButton.icon(
                    onPressed: disabled ? null : onPay,
                    icon: const Icon(Icons.payment_outlined),
                    label: const Text('Pay'),
                  ),
                if (reservation.status == 'approved' ||
                    reservation.status == 'completed')
                  OutlinedButton.icon(
                    onPressed: disabled ? null : onContact,
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text('Message provider'),
                  ),
                if (reservation.canCancel)
                  TextButton.icon(
                    onPressed: disabled ? null : onCancel,
                    icon: Icon(Icons.cancel_outlined, color: colors.error),
                    label: Text(
                      'Cancel',
                      style: TextStyle(color: colors.error),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _line(IconData icon, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 9),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  static String _paymentLabel(DriverReservation reservation) {
    final amount = reservation.totalAmount == null
        ? null
        : 'PHP ${reservation.totalAmount!.toStringAsFixed(2)}';

    return switch (reservation.paymentStatus) {
      'paid' => '${amount == null ? '' : '$amount | '}Payment verified',
      'pending_verification' =>
        '${amount == null ? '' : '$amount | '}Payment sent, awaiting owner verification',
      _ when reservation.status == 'completed' =>
        '${amount == null ? '' : '$amount | '}Payment due',
      _ => 'Payment will be available after checkout',
    };
  }

  static String _title(String value) => value
      .split('_')
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

class _Message extends StatelessWidget {
  const _Message({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.event_note_outlined, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}
