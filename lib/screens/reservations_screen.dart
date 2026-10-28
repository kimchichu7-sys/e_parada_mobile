import 'dart:async';
import 'package:flutter/material.dart';

import '../models/driver_reservation.dart';
import '../models/rebook_alternative.dart';
import '../services/api_client.dart';
import '../services/offline_parking_pass_service.dart';
import '../services/reservation_service.dart';
import '../utils/validators.dart';
import '../widgets/digital_receipt_dialog.dart';
import '../widgets/extend_parking_dialog.dart';
import '../widgets/live_overstay_tracker_card.dart';
import '../widgets/rebook_selection_dialog.dart';
import '../widgets/reservation_action_dialogs.dart';
import '../widgets/reservation_credential_dialog.dart';
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
  Timer? _statusPollTimer;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _statusPollTimer?.cancel();
    super.dispose();
  }

  void _checkPendingPoll(List<DriverReservation>? items) {
    final hasPending = items?.any((r) => r.status.toLowerCase() == 'pending') ?? false;
    if (hasPending && (_statusPollTimer == null || !_statusPollTimer!.isActive)) {
      _statusPollTimer?.cancel();
      _statusPollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        if (mounted) _refresh();
      });
    } else if (!hasPending && _statusPollTimer != null) {
      _statusPollTimer?.cancel();
      _statusPollTimer = null;
    }
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
      _checkPendingPoll(items);
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
      _checkPendingPoll(items);
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              maxLength: 1000,
              maxLines: 3,
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm Cancellation'),
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

  Future<void> _rebook(DriverReservation reservation) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    RebookAlternativesResponse? data;
    try {
      data = await ReservationService.fetchRebookAlternatives(reservation.id);
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Unable to load alternatives'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
      return;
    }

    if (!mounted) return;
    Navigator.pop(context);

    if (data.alternatives.isEmpty) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.search_off_rounded, size: 40, color: Colors.amber),
          title: const Text('No Nearby Spaces Available'),
          content: const Text(
            'We could not find any other nearby parking spaces with available slots for your vehicle type at this time.\n\nYou can cancel your reservation without penalty.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Reservation'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(ctx);
                _cancel(reservation);
              },
              child: const Text('Cancel Reservation'),
            ),
          ],
        ),
      );
      return;
    }

    final selection = await RebookSelectionDialog.show(
      context,
      reservation: reservation,
      alternativesResponse: data,
    );

    if (selection == null) return;

    await _perform(
      () => ReservationService.rebookReservation(
        reservationId: reservation.id,
        targetParkingSpaceId: selection.targetParkingSpaceId,
        targetParkingSlotId: selection.targetParkingSlotId,
      ),
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
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                        onRebook: () => _rebook(reservation),
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
    required this.onRebook,
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
  final VoidCallback onRebook;
  final VoidCallback onPay;
  final VoidCallback onReceipt;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
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
                Chip(
                  label: Text(
                    _title(reservation.status),
                    style: TextStyle(
                      color: _statusColor(reservation.status),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  backgroundColor: _statusColor(reservation.status).withValues(alpha: 0.12),
                  side: BorderSide(
                    color: _statusColor(reservation.status).withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
            Text(
              '${Validators.formatReservationNumber(reservation.backupReference, id: reservation.id)} | ${reservation.slotLabel}',
            ),
            if (reservation.isNoShowCancelled) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.4 : 0.5),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.timer_off_outlined, color: Color(0xFFEF4444), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto-Cancelled (60-Minute No-Show)',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This booking was automatically cancelled because arrival was not recorded within 60 minutes after scheduled start (${reservation.startTime}). Per policy, the 1-hour downpayment (PHP ${(reservation.downpaymentAmount ?? 0.0).toStringAsFixed(2)}) has been forfeited to compensate the space owner.',
                            style: TextStyle(
                              color: isDark ? const Color(0xFFFECACA) : const Color(0xFF991B1B),
                              fontSize: 14,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (reservation.needsRebook) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: isDark ? 0.15 : 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: isDark ? 0.5 : 0.6),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Action Required: Space Unavailable',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFFFDE68A) : Colors.amber.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      reservation.rebookReason.isNotEmpty
                          ? reservation.rebookReason
                          : 'The space provider reported this location unavailable. Please choose an option below:',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? const Color(0xFFFEF3C7) : Colors.amber.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: disabled ? null : onRebook,
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.amber.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.near_me_rounded, size: 16),
                          label: const Text('Rebook Nearest Space'),
                        ),
                        OutlinedButton.icon(
                          onPressed: disabled ? null : onCancel,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.error,
                            side: BorderSide(
                              color: colors.error.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                          ),
                          icon: const Icon(Icons.cancel_outlined, size: 16),
                          label: const Text('Cancel Reservation'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Divider(height: 26),
            ReservationProgressTracker(
              status: reservation.status,
              paymentStatus: reservation.paymentStatus,
              timeIn: reservation.timeIn,
              timeOut: reservation.timeOut,
            ),
            if (reservation.status == 'approved' && reservation.timeOut == null) ...[
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
            if (reservation.status == 'approved' && reservation.overstayStatus != 'normal')
              _line(
                Icons.warning_amber_outlined,
                '${_title(reservation.overstayStatus)} | ${reservation.overstayMinutes} minutes | PHP ${reservation.overstayAmount.toStringAsFixed(2)}',
              ),
            if (reservation.status == 'cancelled' &&
                reservation.cancellationReason.isNotEmpty)
              _line(
                Icons.cancel_outlined,
                'Cancellation: ${reservation.cancellationReason}',
              ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (reservation.canRebook || reservation.needsRebook)
                  FilledButton.icon(
                    onPressed: disabled ? null : onRebook,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFEA580C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.near_me_outlined, size: 18),
                    label: const Text('Rebook Space', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                if (reservation.status == 'approved' && reservation.timeOut == null && reservation.hasCredential)
                  FilledButton.icon(
                    onPressed: disabled ? null : onCredential,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB), // Royal Blue
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.qr_code_2, size: 18),
                    label: const Text('QR Code', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                if (reservation.status == 'approved' && reservation.timeOut == null)
                  FilledButton.icon(
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
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0D9488), // Deep Teal
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: const Text('Directions', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                if (reservation.canReschedule)
                  FilledButton.icon(
                    onPressed: disabled ? null : onReschedule,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706), // Warm Amber
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.edit_calendar_outlined, size: 18),
                    label: const Text('Reschedule', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                if (reservation.canSubmitPayment &&
                    reservation.paymentStatus == 'unpaid')
                  FilledButton.icon(
                    onPressed: disabled ? null : onPay,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF059669), // Emerald Green
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.payment_outlined, size: 18),
                    label: const Text('Pay', style: TextStyle(fontWeight: FontWeight.w800)),
                  ),
                if (reservation.canExtend)
                  FilledButton.icon(
                    onPressed: disabled ? null : onExtend,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5), // Indigo
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.more_time_outlined, size: 18),
                    label: const Text('Extend Time', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                if (reservation.status == 'approved' &&
                    reservation.timeOut == null)
                  FilledButton.icon(
                    onPressed: disabled ? null : onContact,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED), // Violet
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.forum_outlined, size: 18),
                    label: const Text('Message Provider', style: TextStyle(fontWeight: FontWeight.w700)),
                  )
                else if (reservation.status == 'completed')
                  OutlinedButton.icon(
                    onPressed: disabled ? null : onContact,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF7C3AED),
                      side: const BorderSide(color: Color(0xFF7C3AED)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Messages (Read-Only)'),
                  ),
                if (reservation.canSubmitFeedback)
                  FilledButton.icon(
                    onPressed: disabled ? null : onFeedback,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE11D48), // Rose
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.rate_review_outlined, size: 18),
                    label: const Text('Rate Parking', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                if (reservation.status == 'completed' ||
                    reservation.paymentStatus == 'paid')
                  FilledButton.icon(
                    onPressed: disabled ? null : onReceipt,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF334155), // Slate
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.receipt_long_rounded, size: 18),
                    label: const Text('E-Receipt', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                if (reservation.canCancel)
                  FilledButton.icon(
                    onPressed: disabled ? null : onCancel,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626), // Crimson Red
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
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

  static Color _statusColor(String status) => switch (status.toLowerCase()) {
    'approved' => const Color(0xFF10B981), // Emerald Green
    'completed' => const Color(0xFF235282), // Unified Yale Navy
    'rejected' || 'cancelled' => const Color(0xFFEF4444), // Red
    _ => const Color(0xFFF59E0B), // Amber for Pending
  };

  static String _paymentLabel(DriverReservation reservation) {
    final dpAmount = reservation.downpaymentAmount ?? 0.0;
    if (reservation.isNoShowCancelled) {
      return '1-Hour Downpayment (PHP ${dpAmount.toStringAsFixed(2)}) forfeited (No-show)';
    }

    final totalStr = reservation.totalAmount != null
        ? 'PHP ${reservation.totalAmount!.toStringAsFixed(2)}'
        : null;

    final downpaymentNote = reservation.isDownpaymentPaid
        ? '1-hr downpayment (PHP ${dpAmount.toStringAsFixed(2)}) paid'
        : (dpAmount > 0
            ? '1-hr downpayment (PHP ${dpAmount.toStringAsFixed(2)}) pending'
            : null);

    return switch (reservation.paymentStatus) {
      'paid' => '${totalStr ?? ''}${totalStr != null ? ' | ' : ''}Payment verified',
      'pending_verification' =>
        '${totalStr ?? ''}${totalStr != null ? ' | ' : ''}Payment sent, awaiting owner verification',
      _ when reservation.status == 'completed' =>
        '${reservation.remainingBalance != null ? 'Balance Due: PHP ${reservation.remainingBalance!.toStringAsFixed(2)}' : (totalStr ?? '')} | Exit payment due',
      _ when reservation.isDownpaymentPaid =>
        '${downpaymentNote ?? ''} | Balance payable upon exit',
      _ when reservation.status == 'approved' =>
        '${downpaymentNote ?? 'Downpayment due'} | Balance payable upon exit',
      _ => 'Payable upon booking approval and exit',
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
