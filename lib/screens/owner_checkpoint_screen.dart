import 'package:flutter/material.dart';

import '../models/checkpoint_transaction.dart';
import '../models/owner_parking_space.dart';
import '../services/owner_operations_service.dart';
import 'qr_scanner_screen.dart';

class OwnerCheckpointScreen extends StatefulWidget {
  const OwnerCheckpointScreen({super.key});

  @override
  State<OwnerCheckpointScreen> createState() => _OwnerCheckpointScreenState();
}

class _OwnerCheckpointScreenState extends State<OwnerCheckpointScreen> {
  final _credentialController = TextEditingController();
  late Future<OwnerCheckpointData> _future;
  OwnerCheckpointData? _data;
  int? _selectedSpaceId;
  bool _validating = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  @override
  void dispose() {
    _credentialController.dispose();
    super.dispose();
  }

  Future<OwnerCheckpointData> _load() async {
    final data = await OwnerOperationsService.fetchCheckpointData();
    if (mounted) {
      setState(() {
        _data = data;
        if (_selectedSpaceId == null && data.parkingSpaces.isNotEmpty) {
          _selectedSpaceId = data.parkingSpaces.first.id;
        }
      });
    }
    return data;
  }

  Future<void> _refresh() async {
    final request = _load();
    setState(() => _future = request);
    await request;
  }

  Future<void> _validate() async {
    final credential = _credentialController.text.trim();
    if (_selectedSpaceId == null) {
      _showMessage('Select a parking space checkpoint first.');
      return;
    }
    if (credential.isEmpty) {
      _showMessage('Enter the QR code or backup reference, such as RES-125.');
      return;
    }

    setState(() => _validating = true);
    try {
      final result = await OwnerOperationsService.validateCheckpoint(
        parkingSpaceId: _selectedSpaceId!,
        credential: credential,
      );
      if (!mounted) return;
      _credentialController.clear();
      setState(() {
        if (_data != null) {
          _data = OwnerCheckpointData(
            parkingSpaces: _data!.parkingSpaces,
            transactions: result.transactions,
          );
        }
      });
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            result.eventType == 'entry_recorded'
                ? Icons.login_rounded
                : Icons.logout_rounded,
          ),
          title: Text(result.message),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                result.reservation.backupReference,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(result.reservation.driverName),
              Text(result.reservation.vehicleLabel),
              Text(result.reservation.parkingSpaceName),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) setState(() => _validating = false);
    }
  }

  Future<void> _scanCredential() async {
    if (_validating) return;

    final credential = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (context) => const QrScannerScreen()),
    );
    if (!mounted || credential == null) return;

    _credentialController.text = credential;
    await _validate();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entry and Exit Validation')),
      body: FutureBuilder<OwnerCheckpointData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              _data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError && _data == null) {
            return _CheckpointMessage(
              message: snapshot.error.toString(),
              onRetry: _refresh,
            );
          }

          final data = _data ?? snapshot.data;
          if (data == null || data.parkingSpaces.isEmpty) {
            return _CheckpointMessage(
              message: 'Create a parking space before using a checkpoint.',
              onRetry: _refresh,
            );
          }

          final selectedSpace = data.parkingSpaces.firstWhere(
            (space) => space.id == _selectedSpaceId,
            orElse: () => data.parkingSpaces.first,
          );
          final selectedTransactions = data.transactions
              .where(
                (transaction) => transaction.parkingSpaceId == selectedSpace.id,
              )
              .toList(growable: false);

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _ValidationPanel(
                  spaces: data.parkingSpaces,
                  selectedSpaceId: _selectedSpaceId,
                  controller: _credentialController,
                  validating: _validating,
                  onSpaceChanged: (value) {
                    setState(() => _selectedSpaceId = value);
                  },
                  onValidate: _validate,
                  onScan: _scanCredential,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${selectedSpace.name} history',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    _HistoryCount(count: selectedTransactions.length),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Successful and failed attempts are retained for audit and backup.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 12),
                if (selectedTransactions.isEmpty)
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.history_outlined),
                      title: Text('No validation attempts for this space'),
                    ),
                  )
                else
                  for (final transaction in selectedTransactions) ...[
                    _TransactionCard(transaction: transaction),
                    const SizedBox(height: 10),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryCount extends StatelessWidget {
  const _HistoryCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ValidationPanel extends StatelessWidget {
  const _ValidationPanel({
    required this.spaces,
    required this.selectedSpaceId,
    required this.controller,
    required this.validating,
    required this.onSpaceChanged,
    required this.onValidate,
    required this.onScan,
  });

  final List<OwnerParkingSpace> spaces;
  final int? selectedSpaceId;
  final TextEditingController controller;
  final bool validating;
  final ValueChanged<int?> onSpaceChanged;
  final VoidCallback onValidate;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.qr_code_scanner_rounded, color: colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Validate at the correct checkpoint',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Use the QR identifier or the permanent RES-# backup reference. First validation records entry; second records exit.',
            style: TextStyle(color: colors.onPrimaryContainer),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            initialValue: selectedSpaceId,
            decoration: const InputDecoration(
              labelText: 'Parking space checkpoint',
              border: OutlineInputBorder(),
            ),
            items: spaces
                .map(
                  (space) => DropdownMenuItem(
                    value: space.id,
                    child: Text(
                      space.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: validating ? null : onSpaceChanged,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            enabled: !validating,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'QR code or backup reference',
              hintText: 'Example: RES-125',
              prefixIcon: Icon(Icons.confirmation_number_outlined),
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => onValidate(),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: validating ? null : onValidate,
              icon: const Icon(Icons.verified_user_outlined),
              label: Text(validating ? 'Validating...' : 'Validate credential'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: validating ? null : onScan,
              icon: const Icon(Icons.qr_code_scanner_rounded),
              label: const Text('Scan QR with camera'),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({required this.transaction});

  final CheckpointTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = transaction.wasSuccessful ? Colors.green : colors.error;
    final time = transaction.createdAt?.toLocal().toString().split('.').first;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(
            transaction.wasSuccessful
                ? Icons.check_rounded
                : Icons.close_rounded,
          ),
        ),
        title: Text(
          transaction.eventLabel,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          [
            if (transaction.backupReference.isNotEmpty)
              transaction.backupReference,
            if (transaction.parkingSpaceName.isNotEmpty)
              transaction.parkingSpaceName,
            if (transaction.driverName.isNotEmpty) transaction.driverName,
            if (!transaction.wasSuccessful &&
                transaction.failureReason.isNotEmpty)
              transaction.failureReason,
            ?time,
          ].join('\n'),
        ),
        isThreeLine: true,
      ),
    );
  }
}

class _CheckpointMessage extends StatelessWidget {
  const _CheckpointMessage({required this.message, required this.onRetry});

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
            const Icon(Icons.qr_code_scanner_outlined, size: 52),
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
