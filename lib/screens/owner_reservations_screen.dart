import 'package:flutter/material.dart';

import '../models/owner_reservation.dart';
import '../services/owner_operations_service.dart';
import '../widgets/reservation_credential_dialog.dart';
import 'reservation_conversation_screen.dart';

class OwnerReservationsScreen extends StatefulWidget {
  const OwnerReservationsScreen({super.key});

  @override
  State<OwnerReservationsScreen> createState() =>
      _OwnerReservationsScreenState();
}

class _OwnerReservationsScreenState extends State<OwnerReservationsScreen> {
  String _status = '';
  bool _acting = false;
  late Future<List<OwnerReservation>> _future;

  @override
  void initState() {
    super.initState();
    _future = OwnerOperationsService.fetchReservations();
  }

  Future<void> _refresh() async {
    final request = OwnerOperationsService.fetchReservations(
      status: _status.isEmpty ? null : _status,
    );
    setState(() => _future = request);
    await request;
  }

  void _setStatus(String status) {
    if (_status == status) return;
    setState(() {
      _status = status;
      _future = OwnerOperationsService.fetchReservations(
        status: status.isEmpty ? null : status,
      );
    });
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<void> _approve(OwnerReservation reservation) async {
    final notes = await _textDialog(
      title: 'Approve ${reservation.backupReference}',
      label: 'Optional arrival instructions',
      confirmLabel: 'Approve',
    );
    if (notes == null) return;
    await _perform(
      () => OwnerOperationsService.approveReservation(
        reservation.id,
        notes: notes,
      ),
    );
  }

  Future<void> _reject(OwnerReservation reservation) async {
    final notes = await _textDialog(
      title: 'Reject ${reservation.backupReference}',
      label: 'Reason for rejection',
      confirmLabel: 'Reject',
      requireText: true,
    );
    if (notes == null) return;
    await _perform(
      () => OwnerOperationsService.rejectReservation(
        reservation.id,
        notes: notes,
      ),
    );
  }

  Future<void> _cancel(OwnerReservation reservation) async {
    final reason = await _textDialog(
      title: 'Cancel ${reservation.backupReference}',
      label: 'Optional cancellation reason',
      confirmLabel: 'Cancel reservation',
    );
    if (reason == null) return;
    await _perform(
      () => OwnerOperationsService.cancelReservation(
        reservation.id,
        reason: reason,
      ),
    );
  }

  Future<void> _markPaid(OwnerReservation reservation) async {
    final method = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Verify ${reservation.backupReference} payment'),
        content: const Text(
          'Only confirm payment after checking the submitted proof or cash received.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          OutlinedButton.icon(
            onPressed: () => Navigator.pop(context, 'cash'),
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Cash'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context, 'gcash'),
            icon: const Icon(Icons.phone_android_outlined),
            label: const Text('GCash'),
          ),
        ],
      ),
    );
    if (method == null) return;
    await _perform(
      () => OwnerOperationsService.markPaid(
        reservation.id,
        paymentMethod: method,
      ),
    );
  }

  Future<void> _approveExtension(OwnerReservation reservation) async {
    final notes = await _textDialog(
      title: 'Approve extension for ${reservation.backupReference}',
      label: 'Optional instructions for the driver',
      confirmLabel: 'Approve extension',
    );
    if (notes == null) return;
    await _perform(
      () =>
          OwnerOperationsService.approveExtension(reservation.id, notes: notes),
    );
  }

  Future<void> _rejectExtension(OwnerReservation reservation) async {
    final notes = await _textDialog(
      title: 'Reject extension for ${reservation.backupReference}',
      label: 'Reason for rejecting the extension',
      confirmLabel: 'Reject extension',
      requireText: true,
    );
    if (notes == null) return;
    await _perform(
      () =>
          OwnerOperationsService.rejectExtension(reservation.id, notes: notes),
    );
  }

  Future<void> _viewPaymentProof(OwnerReservation reservation) async {
    if (_acting) return;
    setState(() => _acting = true);
    try {
      final bytes = await OwnerOperationsService.fetchPaymentProof(
        reservation.id,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('${reservation.backupReference} payment proof'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520, maxHeight: 620),
            child: InteractiveViewer(child: Image.memory(bytes)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  Future<String?> _textDialog({
    required String title,
    required String label,
    required String confirmLabel,
    bool requireText = false,
  }) async {
    final controller = TextEditingController();
    String? validationMessage;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: label,
              errorText: validationMessage,
              border: const OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();
                if (requireText && value.isEmpty) {
                  setDialogState(() {
                    validationMessage = 'Please provide a reason.';
                  });
                  return;
                }
                Navigator.pop(context, value);
              },
              child: Text(confirmLabel),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Requests'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _status.isEmpty,
                  onSelected: () => _setStatus(''),
                ),
                for (final status in const [
                  'pending',
                  'approved',
                  'completed',
                  'rejected',
                  'cancelled',
                ]) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: _title(status),
                    selected: _status == status,
                    onSelected: () => _setStatus(status),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<OwnerReservation>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _ReservationMessage(
                  message: snapshot.error.toString(),
                  onRetry: _refresh,
                );
              }

              final reservations = snapshot.data ?? const <OwnerReservation>[];
              if (reservations.isEmpty) {
                return _ReservationMessage(
                  message:
                      'No ${_status.isEmpty ? '' : '$_status '}reservations found.',
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
                  itemBuilder: (context, index) => _ReservationCard(
                    reservation: reservations[index],
                    disabled: _acting,
                    onApprove: () => _approve(reservations[index]),
                    onReject: () => _reject(reservations[index]),
                    onCancel: () => _cancel(reservations[index]),
                    onMarkPaid: () => _markPaid(reservations[index]),
                    onApproveExtension: () =>
                        _approveExtension(reservations[index]),
                    onRejectExtension: () =>
                        _rejectExtension(reservations[index]),
                    onViewPaymentProof: () =>
                        _viewPaymentProof(reservations[index]),
                    onContact: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => ReservationConversationScreen(
                          reservationId: reservations[index].id,
                          otherPartyName: reservations[index].driverName,
                        ),
                      ),
                    ),
                  ),
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

  static String _title(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({
    required this.reservation,
    required this.disabled,
    required this.onApprove,
    required this.onReject,
    required this.onCancel,
    required this.onMarkPaid,
    required this.onApproveExtension,
    required this.onRejectExtension,
    required this.onViewPaymentProof,
    required this.onContact,
  });

  final OwnerReservation reservation;
  final bool disabled;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onCancel;
  final VoidCallback onMarkPaid;
  final VoidCallback onApproveExtension;
  final VoidCallback onRejectExtension;
  final VoidCallback onViewPaymentProof;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = _statusColor(reservation.status, colors);

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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reservation.parkingSpaceName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${reservation.backupReference} | ${reservation.slotLabel}',
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _Badge(label: reservation.status, color: statusColor),
              ],
            ),
            const Divider(height: 28),
            ReservationProgressTracker(
              status: reservation.status,
              paymentStatus: reservation.paymentStatus,
              timeIn: reservation.timeIn,
              timeOut: reservation.timeOut,
            ),
            const SizedBox(height: 14),
            _DetailRow(
              icon: Icons.person_outline,
              title: reservation.driverName,
              subtitle: reservation.backupReference,
            ),
            _DetailRow(
              icon: Icons.directions_car_outlined,
              title: reservation.vehicleLabel,
              subtitle: 'Verify this vehicle when it arrives.',
            ),
            _DetailRow(
              icon: Icons.schedule_outlined,
              title: reservation.scheduleLabel,
              subtitle: 'Reserved schedule',
            ),
            _DetailRow(
              icon: Icons.payments_outlined,
              title: reservation.totalAmount == null
                  ? 'Amount not yet computed'
                  : 'PHP ${reservation.totalAmount!.toStringAsFixed(2)}',
              subtitle:
                  '${_title(reservation.paymentStatus)}${reservation.paymentMethod.isEmpty ? '' : ' via ${reservation.paymentMethod.toUpperCase()}'}',
            ),
            if (reservation.ownerNotes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                'Owner notes: ${reservation.ownerNotes}',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
            if (reservation.extensionStatus.isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon: Icons.more_time_outlined,
                title:
                    'Extension ${_title(reservation.extensionStatus)}${reservation.extensionEndDate.isEmpty ? '' : ' to ${reservation.extensionEndDate} ${reservation.extensionEndTime}'}',
                subtitle: reservation.extensionReason.isEmpty
                    ? 'No reason provided'
                    : reservation.extensionReason,
              ),
            ],
            if (reservation.isPending ||
                reservation.canCancel ||
                reservation.canMarkPaid ||
                reservation.hasPendingExtension ||
                reservation.hasPaymentProof ||
                reservation.status == 'approved' ||
                reservation.status == 'completed') ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (reservation.isPending)
                    FilledButton.icon(
                      onPressed: disabled ? null : onApprove,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Approve'),
                    ),
                  if (reservation.isPending)
                    OutlinedButton.icon(
                      onPressed: disabled ? null : onReject,
                      icon: const Icon(Icons.block_outlined),
                      label: const Text('Reject'),
                    ),
                  if (reservation.canMarkPaid)
                    FilledButton.icon(
                      onPressed: disabled ? null : onMarkPaid,
                      icon: const Icon(Icons.verified_outlined),
                      label: const Text('Verify payment'),
                    ),
                  if (reservation.hasPaymentProof)
                    OutlinedButton.icon(
                      onPressed: disabled ? null : onViewPaymentProof,
                      icon: const Icon(Icons.receipt_long_outlined),
                      label: const Text('View proof'),
                    ),
                  if (reservation.status != 'rejected' &&
                      reservation.status != 'cancelled')
                    OutlinedButton.icon(
                      onPressed: disabled ? null : onContact,
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text('Message driver'),
                    ),
                  if (reservation.hasPendingExtension)
                    FilledButton.icon(
                      onPressed: disabled ? null : onApproveExtension,
                      icon: const Icon(Icons.more_time_outlined),
                      label: const Text('Approve extension'),
                    ),
                  if (reservation.hasPendingExtension)
                    OutlinedButton.icon(
                      onPressed: disabled ? null : onRejectExtension,
                      icon: const Icon(Icons.timer_off_outlined),
                      label: const Text('Reject extension'),
                    ),
                  if (reservation.canCancel)
                    TextButton.icon(
                      onPressed: disabled ? null : onCancel,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancel'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _title(String value) {
    if (value.isEmpty) return value;
    return value
        .split('_')
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  static Color _statusColor(String status, ColorScheme colors) {
    return switch (status) {
      'approved' => Colors.blue,
      'completed' => Colors.green,
      'rejected' => colors.error,
      'cancelled' => Colors.grey,
      _ => Colors.amber.shade800,
    };
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _ReservationCard._title(label),
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _ReservationMessage extends StatelessWidget {
  const _ReservationMessage({required this.message, required this.onRetry});

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
