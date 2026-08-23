import 'package:flutter/material.dart';

import '../models/owner_parking_space.dart';
import '../services/api_client.dart';
import '../services/owner_operations_service.dart';
import 'owner_space_form_screen.dart';

class OwnerSpacesScreen extends StatefulWidget {
  const OwnerSpacesScreen({super.key});

  @override
  State<OwnerSpacesScreen> createState() => _OwnerSpacesScreenState();
}

class _OwnerSpacesScreenState extends State<OwnerSpacesScreen> {
  late Future<List<OwnerParkingSpace>> _future;

  @override
  void initState() {
    super.initState();
    _future = OwnerOperationsService.fetchSpaces();
  }

  Future<void> _refresh() async {
    final request = OwnerOperationsService.fetchSpaces();
    setState(() => _future = request);
    await request;
  }

  Future<void> _openEditor([OwnerParkingSpace? space]) async {
    OwnerParkingSpace? details = space;

    if (space != null) {
      try {
        details = await OwnerOperationsService.fetchSpace(space.id);
      } catch (error) {
        if (!mounted) return;
        _showMessage(error.toString(), error: true);
        return;
      }
    }

    if (!mounted) return;
    final message = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => OwnerSpaceFormScreen(space: details)),
    );

    if (!mounted || message == null) return;
    _showMessage(message);
    await _refresh();
  }

  Future<void> _deleteSpace(OwnerParkingSpace space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete parking space?'),
        content: Text(
          'Delete “${space.name}”? This is only allowed when the space has no reservation history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep Space'),
          ),
          FilledButton.tonalIcon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final message = await OwnerOperationsService.deleteSpace(space.id);
      if (!mounted) return;
      _showMessage(message);
      await _refresh();
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    } catch (error) {
      if (mounted) _showMessage(error.toString(), error: true);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    final colors = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: error ? colors.error : null,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Parking Spaces')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openEditor,
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Add Space'),
      ),
      body: FutureBuilder<List<OwnerParkingSpace>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _MessageState(
              icon: Icons.cloud_off_outlined,
              message: snapshot.error.toString(),
              buttonLabel: 'Try again',
              onPressed: _refresh,
            );
          }

          final spaces = snapshot.data ?? const <OwnerParkingSpace>[];
          if (spaces.isEmpty) {
            return _MessageState(
              icon: Icons.local_parking_outlined,
              message: 'You have not submitted a parking space yet.',
              buttonLabel: 'Add Parking Space',
              onPressed: _openEditor,
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: spaces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _SpaceCard(
                space: spaces[index],
                onEdit: () => _openEditor(spaces[index]),
                onDelete: () => _deleteSpace(spaces[index]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.onEdit,
    required this.onDelete,
  });

  final OwnerParkingSpace space;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final openColor = space.isOpenNow ? Colors.green : colors.error;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (space.imageUrls.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Image.network(
                    space.imageUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => ColoredBox(
                      color: colors.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(Icons.broken_image_outlined, size: 36),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: const Icon(Icons.local_parking_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        space.name,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(space.address),
                    ],
                  ),
                ),
                _StatusChip(
                  label: space.isOpenNow ? 'Open' : 'Closed',
                  color: openColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.schedule_outlined,
                  label: space.operatingHours,
                ),
                _InfoChip(
                  icon: Icons.grid_view_outlined,
                  label: '${space.activeSlotsCount} active slots',
                ),
                _InfoChip(
                  icon: Icons.pending_actions_outlined,
                  label: '${space.pendingReservationsCount} pending requests',
                ),
                _InfoChip(
                  icon: Icons.verified_outlined,
                  label: _approvalLabel(space.approvalStatus),
                ),
              ],
            ),
            if (space.vehicleTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                space.vehicleTypes.join(' • '),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            if (space.approvalStatus == 'rejected' &&
                space.adminNotes?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Admin notes: ${space.adminNotes}',
                  style: TextStyle(color: colors.onErrorContainer),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDelete,
                  tooltip: 'Delete parking space',
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _approvalLabel(String status) {
    return switch (status) {
      'approved' => 'Approved',
      'rejected' => 'Changes required',
      _ => 'Pending review',
    };
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.message,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String message;
  final String buttonLabel;
  final Future<void> Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}
