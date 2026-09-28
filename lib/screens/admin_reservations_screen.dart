import 'package:flutter/material.dart';

import '../models/admin_models.dart';
import '../services/admin_operations_service.dart';

class AdminReservationsScreen extends StatefulWidget {
  const AdminReservationsScreen({super.key});

  @override
  State<AdminReservationsScreen> createState() =>
      _AdminReservationsScreenState();
}

class _AdminReservationsScreenState extends State<AdminReservationsScreen> {
  String _filter = '';
  bool _acting = false;
  late Future<List<AdminReservationReview>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<AdminReservationReview>> _load() {
    return AdminOperationsService.fetchReservations(
      disputeStatus: _filter.isEmpty ? null : _filter,
    );
  }

  Future<void> _refresh() async {
    final request = _load();
    setState(() {
      _future = request;
    });
    await request;
  }

  void _setFilter(String value) {
    if (_filter == value) return;
    setState(() {
      _filter = value;
      _future = _load();
    });
  }

  Future<void> _edit(AdminReservationReview reservation) async {
    String status = reservation.disputeStatus;
    final disputeController = TextEditingController(
      text: reservation.disputeNotes,
    );
    final internalController = TextEditingController(
      text: reservation.internalNotes,
    );

    final save = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Review ${reservation.backupReference}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: const InputDecoration(
                    labelText: 'Dispute status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(
                      value: 'under_review',
                      child: Text('Under review'),
                    ),
                    DropdownMenuItem(
                      value: 'resolved',
                      child: Text('Resolved'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setDialogState(() => status = value);
                  },
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: disputeController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Notes visible to involved users',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: internalController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Private admin notes',
                    helperText: 'Only administrators can see these notes.',
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
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save review'),
            ),
          ],
        ),
      ),
    );

    final disputeNotes = disputeController.text.trim();
    final internalNotes = internalController.text.trim();
    disputeController.dispose();
    internalController.dispose();
    if (save != true) return;

    setState(() => _acting = true);
    try {
      final message = await AdminOperationsService.updateReservation(
        reservation.id,
        disputeStatus: status,
        disputeNotes: disputeNotes,
        internalNotes: internalNotes,
      );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservation Monitor'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
          child: SizedBox(
            height: 54,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              children: [
                for (final value in const [
                  '',
                  'normal',
                  'under_review',
                  'resolved',
                ]) ...[
                  ChoiceChip(
                    label: Text(_label(value)),
                    selected: _filter == value,
                    onSelected: (_) => _setFilter(value),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          FutureBuilder<List<AdminReservationReview>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return _Message(
                  text: snapshot.error.toString(),
                  onRetry: _refresh,
                );
              }
              final reservations = snapshot.data ?? const [];
              if (reservations.isEmpty) {
                return _Message(
                  text:
                      'No ${_label(_filter).toLowerCase()} reservations found.',
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
                    onReview: () => _edit(reservations[index]),
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
}

class _ReservationCard extends StatelessWidget {
  const _ReservationCard({required this.reservation, required this.onReview});

  final AdminReservationReview reservation;
  final VoidCallback onReview;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final disputeColor = switch (reservation.disputeStatus) {
      'under_review' => Colors.orange,
      'resolved' => Colors.green,
      _ => colors.outline,
    };

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
                        '${reservation.backupReference} | ${reservation.parkingSpaceName}',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reservation.schedule,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _Badge(
                  label: _label(reservation.disputeStatus),
                  color: disputeColor,
                ),
              ],
            ),
            const Divider(height: 28),
            _Line(
              icon: Icons.person_outline,
              text: '${reservation.driverName} | ${reservation.driverEmail}',
            ),
            _Line(
              icon: Icons.storefront_outlined,
              text: 'Owner: ${reservation.ownerName}',
            ),
            _Line(
              icon: Icons.directions_car_outlined,
              text: reservation.vehicleLabel,
            ),
            _Line(
              icon: Icons.payments_outlined,
              text:
                  '${_label(reservation.paymentStatus)}${reservation.totalAmount == null ? '' : ' | PHP ${reservation.totalAmount!.toStringAsFixed(2)}'}',
            ),
            if (reservation.disputeNotes.isNotEmpty)
              _Line(icon: Icons.notes_outlined, text: reservation.disputeNotes),
            if (reservation.internalNotes.isNotEmpty)
              _Line(
                icon: Icons.admin_panel_settings_outlined,
                text: 'Private: ${reservation.internalNotes}',
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onReview,
                icon: const Icon(Icons.edit_note_outlined),
                label: const Text('Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
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
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onRetry});

  final String text;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined, size: 52),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}

String _label(String value) {
  if (value.isEmpty) return 'All';
  return value
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
