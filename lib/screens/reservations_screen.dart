import 'package:flutter/material.dart';

import '../models/driver_reservation.dart';
import '../services/api_client.dart';
import '../services/offline_parking_pass_service.dart';
import '../services/reservation_service.dart';
import '../utils/validators.dart';
import '../widgets/digital_receipt_dialog.dart';
import '../widgets/extend_parking_dialog.dart';
import '../widgets/live_overstay_tracker_card.dart';
import '../widgets/offline_parking_pass_dialog.dart';
import '../widgets/reservation_action_dialogs.dart';
import '../widgets/reservation_credential_dialog.dart';
import '../widgets/security_gate_pass_dialog.dart';
import 'map_screen.dart';
import 'reservation_conversation_screen.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<DriverReservation>? _reservations;
  bool _loading = true;
  String? _errorMessage;
  bool _acting = false;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final items = await ReservationService.fetchReservations();
      await OfflineParkingPassService.cacheReservations(items);
      if (!mounted) return;
      setState(() {
        _reservations = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _refresh() async {
    try {
      final items = await ReservationService.fetchReservations();
      await OfflineParkingPassService.cacheReservations(items);
      if (!mounted) return;
      setState(() {
        _reservations = items;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _perform(Future<String> Function() action) async {
    if (_acting) return;
    setState(() {
      _acting = true;
    });
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
      if (mounted) {
        setState(() {
          _acting = false;
        });
      }
    }
  }

  Future<void> _cancel(DriverReservation reservation) async {
    final controller = TextEditingController();
    final ref = Validators.formatReservationNumber(
      reservation.backupReference,
      id: reservation.id,
    );
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel $ref?'),
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
    final refreshed = await ExtendParkingDialog.show(context, reservation);
    if (refreshed == true) {
      await _refresh();
    }
  }

  Future<void> _pay(DriverReservation reservation) async {
    final selection = await showBillingPaymentDialog(context, reservation);
    if (selection == null) return;
    final file = selection.proof;
    await _perform(
      () async => ReservationService.submitPayment(
        reservationId: reservation.id,
        paymentMethod: selection.method,
        referenceNumber: selection.gcashReference,
        paymentProof: file == null
            ? null
            : UploadFileData(
                bytes: await file.readAsBytes(),
                filename: file.name,
              ),
      ),
    );

    if (mounted) {
      final shouldRate = await showDialog<bool>(
        context: context,
        builder: (dialogCtx) => AlertDialog(
          title: const Text('Payment Recorded'),
          content: Text(
            'Your payment for ${reservation.parkingSpaceName} has been submitted.\n\nWould you like to rate and review this parking space now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Maybe Later'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
              child: const Text('Rate Parking Space'),
            ),
          ],
        ),
      );

      if (shouldRate == true && mounted) {
        await _feedback(reservation);
      }
    }
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
          if (_loading && _reservations == null)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null && _reservations == null)
            _Message(
              message: _errorMessage!,
              onRetry: _fetch,
            )
          else if (_reservations == null || _reservations!.isEmpty)
            _Message(
              message: 'No reservations yet.',
              onRetry: _fetch,
            )
          else
            RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: _reservations!.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final reservation = _reservations![index];
                  return _ReservationCard(
                    reservation: reservation,
                    disabled: _acting,
                    onCredential: () => _showCredential(reservation),
                    onReschedule: () => _reschedule(reservation),
                    onFeedback: () => _feedback(reservation),
                    onCancel: () => _cancel(reservation),
                    onExtend: () => _extend(reservation),
                    onPay: () => _pay(reservation),
                    onReceipt: () =>
                        DigitalReceiptDialog.showForDriver(context, reservation),
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
    required this.onReceipt,
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
  final VoidCallback onReceipt;
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
            Text(
              '${Validators.formatReservationNumber(reservation.backupReference, id: reservation.id)} | ${reservation.slotLabel}',
            ),
            const Divider(height: 26),
            ReservationProgressTracker(
              status: reservation.status,
              paymentStatus: reservation.paymentStatus,
              timeIn: reservation.timeIn,
              timeOut: reservation.timeOut,
            ),
            if (reservation.status == 'approved' ||
                (reservation.timeIn != null && reservation.timeOut == null)) ...[
              const SizedBox(height: 10),
              LiveOverstayTrackerCard(
                reservation: reservation,
                onExtensionRequested: onExtend,
              ),
            ],
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
                if ((reservation.status == 'approved' &&
                        reservation.hasCredential) ||
                    (reservation.timeIn != null && reservation.timeOut == null))
                  OutlinedButton.icon(
                    onPressed: disabled
                        ? null
                        : () {
                            OfflineParkingPassDialog.show(
                              context,
                              OfflinePassData.fromDriverReservation(
                                reservation,
                              ),
                            );
                          },
                    icon: const Icon(Icons.cloud_off_rounded),
                    label: const Text('Offline Pass'),
                  ),
                if ((reservation.status == 'approved' &&
                        reservation.hasCredential) ||
                    (reservation.timeIn != null && reservation.timeOut == null))
                  OutlinedButton.icon(
                    onPressed: disabled
                        ? null
                        : () => SecurityGatePassDialog.show(
                              context,
                              reservation: reservation,
                            ),
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Gate Pass'),
                  ),
                if ((reservation.status == 'approved') ||
                    (reservation.timeIn != null && reservation.timeOut == null))
                  OutlinedButton.icon(
                    onPressed: disabled
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MapScreen(
                                  focusedParkingSpaceId: reservation.parkingSpaceId,
                                  startNavigationMode: true,
                                ),
                              ),
                            );
                          },
                    icon: const Icon(Icons.directions_rounded),
                    label: const Text('Directions'),
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
                if (reservation.status == 'completed' ||
                    reservation.paymentStatus == 'paid')
                  FilledButton.tonalIcon(
                    onPressed: disabled ? null : onReceipt,
                    icon: const Icon(Icons.receipt_long_rounded),
                    label: const Text('View E-Receipt'),
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
