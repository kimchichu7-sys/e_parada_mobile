import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/admin_models.dart';
import '../services/admin_operations_service.dart';

enum _ReviewKind { accounts, vehicles, spaces }

class AdminReviewsScreen extends StatefulWidget {
  const AdminReviewsScreen({super.key});

  @override
  State<AdminReviewsScreen> createState() => _AdminReviewsScreenState();
}

class _AdminReviewsScreenState extends State<AdminReviewsScreen> {
  _ReviewKind _kind = _ReviewKind.accounts;
  String _status = 'pending';
  bool _acting = false;
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<dynamic>> _load() {
    return switch (_kind) {
      _ReviewKind.accounts => AdminOperationsService.fetchUsers(
        status: _status.isEmpty ? null : _status,
      ),
      _ReviewKind.vehicles => AdminOperationsService.fetchVehicles(
        status: _status.isEmpty ? null : _status,
      ),
      _ReviewKind.spaces => AdminOperationsService.fetchSpaces(
        status: _status.isEmpty ? null : _status,
      ),
    };
  }

  Future<void> _refresh() async {
    final request = _load();
    setState(() {
      _future = request;
    });
    await request;
  }

  void _changeKind(_ReviewKind kind) {
    if (_kind == kind) return;
    setState(() {
      _kind = kind;
      _status = 'pending';
      _future = _load();
    });
  }

  void _changeStatus(String status) {
    if (_status == status) return;
    setState(() {
      _status = status;
      _future = _load();
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

  Future<String?> _reasonDialog(String title) async {
    final controller = TextEditingController();
    String? error;
    final result = await showDialog<String>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            maxLength: 1000,
            decoration: InputDecoration(
              labelText: 'Reason',
              errorText: error,
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
                if (value.isEmpty) {
                  setDialogState(() => error = 'A reason is required.');
                  return;
                }
                Navigator.pop(context, value);
              },
              child: const Text('Reject'),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    return result;
  }

  Future<void> _showPrivateImage({
    required String title,
    required Future<Uint8List> Function() loader,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 480,
          child: FutureBuilder<Uint8List>(
            future: loader(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError || snapshot.data == null) {
                final message =
                    snapshot.error?.toString() ?? 'Image unavailable.';
                return Container(
                  height: 200,
                  padding: const EdgeInsets.all(20),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message.replaceFirst(RegExp(r'^Exception:\s*'), ''),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final imageData = snapshot.data!;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _openExamineImageViewer(
                        title: title,
                        bytes: imageData,
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.memory(
                              imageData,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                height: 200,
                                padding: const EdgeInsets.all(20),
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image_outlined,
                                      size: 48,
                                      color:
                                          Theme.of(context).colorScheme.error,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Unable to display image preview',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 7,
                              horizontal: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.8),
                                ],
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.zoom_in_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Tap image to enlarge & examine',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () => _openExamineImageViewer(
                      title: title,
                      bytes: imageData,
                    ),
                    icon: const Icon(Icons.fullscreen_rounded),
                    label: const Text('Examine Fullscreen (Zoom & Pan)'),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openExamineImageViewer({
    required String title,
    required Uint8List bytes,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => _InspectionImageViewerDialog(
          title: title,
          bytes: bytes,
        ),
      ),
    );
  }

  Future<void> _approveSpace(AdminParkingSpaceReview space) async {
    final rateControllers = {
      for (final type in space.vehicleTypes)
        type: TextEditingController(
          text: space.hourlyRates[type]?.toStringAsFixed(2) ?? '',
        ),
    };
    final notesController = TextEditingController(text: space.notes);
    String? error;

    final rates = await showDialog<Map<String, double>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Approve ${space.name}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Set an hourly rate for every supported vehicle.'),
                const SizedBox(height: 16),
                for (final entry in rateControllers.entries) ...[
                  TextField(
                    controller: entry.value,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: '${entry.key} rate (PHP)',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Optional admin notes',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = <String, double>{};
                for (final entry in rateControllers.entries) {
                  final value = double.tryParse(entry.value.text.trim());
                  if (value == null || value < 0) {
                    setDialogState(() {
                      error =
                          'Enter a valid non-negative rate for ${entry.key}.';
                    });
                    return;
                  }
                  parsed[entry.key] = value;
                }
                Navigator.pop(context, parsed);
              },
              child: const Text('Approve'),
            ),
          ],
        ),
      ),
    );

    for (final controller in rateControllers.values) {
      controller.dispose();
    }
    final notes = notesController.text.trim();
    notesController.dispose();
    if (rates == null) return;
    await _perform(
      () => AdminOperationsService.reviewSpace(
        space.id,
        status: 'approved',
        notes: notes,
        rates: rates,
      ),
    );
  }

  Future<void> _inspectSpace(AdminParkingSpaceReview space) async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(space.name),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (space.imageUrls.isNotEmpty) ...[
                  SizedBox(
                    height: 230,
                    child: PageView.builder(
                      itemCount: space.imageUrls.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            space.imageUrls[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const ColoredBox(
                                  color: Color(0x11000000),
                                  child: Center(
                                    child: Icon(
                                      Icons.broken_image_outlined,
                                      size: 42,
                                    ),
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${space.imageUrls.length} submitted photo(s). Swipe to inspect.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  const _ReviewDetailRow(
                    icon: Icons.no_photography_outlined,
                    label: 'No submitted photos',
                  ),
                  const SizedBox(height: 12),
                ],
                _ReviewDetailRow(
                  icon: Icons.person_outline,
                  label: '${space.ownerName} | ${space.ownerEmail}',
                ),
                _ReviewDetailRow(
                  icon: Icons.location_on_outlined,
                  label: space.address,
                ),
                if (space.latitude != null && space.longitude != null)
                  _ReviewDetailRow(
                    icon: Icons.my_location_outlined,
                    label:
                        '${space.latitude!.toStringAsFixed(6)}, ${space.longitude!.toStringAsFixed(6)}',
                  ),
                _ReviewDetailRow(
                  icon: Icons.schedule_outlined,
                  label: space.operatingHours,
                ),
                _ReviewDetailRow(
                  icon: Icons.local_parking_outlined,
                  label: '${space.activeSlots} active slot(s)',
                ),
                _ReviewDetailRow(
                  icon: Icons.directions_car_outlined,
                  label: space.vehicleTypes.join(', '),
                ),
                _ReviewDetailRow(
                  icon: Icons.square_foot_outlined,
                  label: '${space.dimensionsSqm.toStringAsFixed(1)} sqm',
                ),
                if (space.description.isNotEmpty) ...[
                  const Divider(height: 28),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(space.description),
                ],
                if (space.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Admin notes: ${space.notes}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Reviews')),
      body: Stack(
        children: [
          Column(
            children: [
              _ReviewToolbar(
                kind: _kind,
                status: _status,
                onKindChanged: _changeKind,
                onStatusChanged: _changeStatus,
              ),
              Expanded(
                child: FutureBuilder<List<dynamic>>(
                  future: _future,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _MessageState(
                        message: snapshot.error.toString(),
                        onRetry: _refresh,
                      );
                    }
                    final items = snapshot.data ?? const [];
                    if (items.isEmpty) {
                      return _MessageState(
                        message:
                            'No ${_status.isEmpty ? '' : '$_status '}reviews found.',
                        onRetry: _refresh,
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: _refresh,
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildCard(items[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
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

  Widget _buildCard(dynamic item) {
    if (item is AdminUserReview) {
      return _AccountCard(
        user: item,
        onDocument: item.hasIdentityDocument
            ? () => _showPrivateImage(
                title: '${item.name} - ${item.idType}',
                loader: () => AdminOperationsService.identityDocument(item.id),
              )
            : null,
        onDocumentBack: item.hasIdentityDocumentBack
            ? () => _showPrivateImage(
                title: '${item.name} - ${item.idType} back',
                loader: () =>
                    AdminOperationsService.identityDocumentBack(item.id),
              )
            : null,
        onApprove: () =>
            _perform(() => AdminOperationsService.approveUser(item.id)),
        onReject: () async {
          final reason = await _reasonDialog('Reject ${item.name}');
          if (reason != null) {
            await _perform(
              () => AdminOperationsService.rejectUser(item.id, reason),
            );
          }
        },
      );
    }
    if (item is AdminVehicleReview) {
      return _VehicleCard(
        vehicle: item,
        onPhoto: item.hasPhoto
            ? () => _showPrivateImage(
                title: '${item.plateNumber} verification photo',
                loader: () => AdminOperationsService.vehiclePhoto(item.id),
              )
            : null,
        onPhotoBack: item.hasPhotoBack
            ? () => _showPrivateImage(
                title: '${item.plateNumber} vehicle back',
                loader: () => AdminOperationsService.vehiclePhotoBack(item.id),
              )
            : null,
        onApprove: () async {
          if (item.plateScanStatus == 'mismatch' ||
              item.plateScanStatus == 'not_detected') {
            final proceed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.amber),
                    SizedBox(width: 8),
                    Expanded(child: Text('OCR Mismatch Warning')),
                  ],
                ),
                content: Text(
                  'Automated photo scan did not match "${item.plateNumber}".\n\n'
                  'Please ensure you have manually verified the vehicle front and back photos before approving.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel & Inspect'),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirm Approval'),
                  ),
                ],
              ),
            );
            if (proceed != true) return;
          }
          await _perform(
            () => AdminOperationsService.approveVehicle(item.id),
          );
        },
        onReject: () async {
          final reason = await _reasonDialog('Reject ${item.plateNumber}');
          if (reason != null) {
            await _perform(
              () => AdminOperationsService.rejectVehicle(item.id, reason),
            );
          }
        },
      );
    }
    final space = item as AdminParkingSpaceReview;
    return _SpaceCard(
      space: space,
      onInspect: () => _inspectSpace(space),
      onApprove: () => _approveSpace(space),
      onReject: () async {
        final reason = await _reasonDialog('Reject ${space.name}');
        if (reason != null) {
          await _perform(
            () => AdminOperationsService.reviewSpace(
              space.id,
              status: 'rejected',
              notes: reason,
            ),
          );
        }
      },
    );
  }
}

class _ReviewToolbar extends StatelessWidget {
  const _ReviewToolbar({
    required this.kind,
    required this.status,
    required this.onKindChanged,
    required this.onStatusChanged,
  });

  final _ReviewKind kind;
  final String status;
  final ValueChanged<_ReviewKind> onKindChanged;
  final ValueChanged<String> onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
        child: Column(
          children: [
            SegmentedButton<_ReviewKind>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(
                  value: _ReviewKind.accounts,
                  label: Text('Accounts'),
                  icon: Icon(Icons.people_outline),
                ),
                ButtonSegment(
                  value: _ReviewKind.vehicles,
                  label: Text('Vehicles'),
                  icon: Icon(Icons.directions_car_outlined),
                ),
                ButtonSegment(
                  value: _ReviewKind.spaces,
                  label: Text('Spaces'),
                  icon: Icon(Icons.local_parking_outlined),
                ),
              ],
              selected: {kind},
              onSelectionChanged: (values) => onKindChanged(values.first),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final value in const [
                    '',
                    'pending',
                    'approved',
                    'rejected',
                  ]) ...[
                    ChoiceChip(
                      label: Text(value.isEmpty ? 'All' : _title(value)),
                      selected: status == value,
                      onSelected: (_) => onStatusChanged(value),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.user,
    required this.onDocument,
    required this.onDocumentBack,
    required this.onApprove,
    required this.onReject,
  });

  final AdminUserReview user;
  final VoidCallback? onDocument;
  final VoidCallback? onDocumentBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      icon: Icons.person_search_outlined,
      title: user.name,
      subtitle: '${_title(user.role.replaceAll('_', ' '))} | ${user.email}',
      status: user.status,
      details: [
        '${user.emailVerified ? 'Verified' : 'Unverified'} email',
        '${user.vehiclesCount} registered vehicle(s)',
        if (user.notes.isNotEmpty) 'Notes: ${user.notes}',
      ],
      primaryAction: user.status == 'pending' ? onApprove : null,
      secondaryAction: user.status == 'pending' ? onReject : null,
      documentAction: onDocument,
      documentLabel: user.role == 'driver' ? 'License front' : user.idType,
      secondaryDocumentAction: onDocumentBack,
      secondaryDocumentLabel: 'License back',
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onPhoto,
    required this.onPhotoBack,
    required this.onApprove,
    required this.onReject,
  });

  final AdminVehicleReview vehicle;
  final VoidCallback? onPhoto;
  final VoidCallback? onPhotoBack;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      icon: Icons.directions_car_outlined,
      title: vehicle.plateNumber,
      subtitle: '${vehicle.driverName} | ${vehicle.driverEmail}',
      status: vehicle.status,
      details: [
        vehicle.description,
        if (vehicle.reviewerName.isNotEmpty)
          'Reviewed by ${vehicle.reviewerName}',
        if (vehicle.notes.isNotEmpty) 'Notes: ${vehicle.notes}',
      ],
      banner: _buildScanBanner(context, vehicle.plateScanStatus, vehicle.plateNumber),
      primaryAction: vehicle.status == 'pending' ? onApprove : null,
      secondaryAction: vehicle.status == 'pending' ? onReject : null,
      documentAction: onPhoto,
      documentLabel: 'Vehicle front',
      secondaryDocumentAction: onPhotoBack,
      secondaryDocumentLabel: 'Vehicle back',
    );
  }

  Widget _buildScanBanner(BuildContext context, String status, String plateNumber) {
    if (status == 'matched') {
      return Container(
        margin: const EdgeInsets.only(top: 2, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            const Text(
              'Photo scan: plate matched',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Quick approve ready',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'mismatch') {
      return Container(
        margin: const EdgeInsets.only(top: 2, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Theme.of(context).colorScheme.error.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 6),
                Text(
                  'Photo scan: mismatch detected',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'Plate characters in photo did not match $plateNumber. Admin manual checking recommended.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onErrorContainer,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 2, bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade700.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.amber.shade800),
          const SizedBox(width: 6),
          Text(
            'Photo scan: ${_scanStatus(status)}',
            style: TextStyle(
              color: Colors.amber.shade900,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _scanStatus(String status) {
    return switch (status) {
      'matched' => 'plate matched',
      'mismatch' => 'mismatch detected',
      'not_detected' => 'plate not readable',
      'unavailable' => 'OCR unavailable; inspect manually',
      _ => 'manual inspection required',
    };
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.onInspect,
    required this.onApprove,
    required this.onReject,
  });

  final AdminParkingSpaceReview space;
  final VoidCallback onInspect;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return _ReviewCard(
      icon: Icons.local_parking_outlined,
      title: space.name,
      subtitle: '${space.ownerName} | ${space.ownerEmail}',
      status: space.status,
      details: [
        space.address,
        '${space.activeSlots} active slot(s) | ${space.operatingHours}',
        '${space.dimensionsSqm.toStringAsFixed(1)} sqm | ${space.vehicleTypes.join(', ')}',
        if (space.notes.isNotEmpty) 'Notes: ${space.notes}',
      ],
      previewImageUrl: space.imageUrls.isEmpty ? null : space.imageUrls.first,
      documentAction: onInspect,
      documentLabel: 'Inspect submission',
      primaryAction: space.status == 'pending' ? onApprove : null,
      secondaryAction: space.status == 'pending' ? onReject : null,
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.details,
    this.primaryAction,
    this.secondaryAction,
    this.documentAction,
    this.documentLabel = 'View document',
    this.secondaryDocumentAction,
    this.secondaryDocumentLabel = 'View back',
    this.previewImageUrl,
    this.banner,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String status;
  final List<String> details;
  final VoidCallback? primaryAction;
  final VoidCallback? secondaryAction;
  final VoidCallback? documentAction;
  final String documentLabel;
  final VoidCallback? secondaryDocumentAction;
  final String secondaryDocumentLabel;
  final String? previewImageUrl;
  final Widget? banner;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (previewImageUrl != null && previewImageUrl!.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 16 / 7,
                  child: Image.network(
                    previewImageUrl!,
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
              children: [
                CircleAvatar(child: Icon(icon)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: status),
              ],
            ),
            const Divider(height: 28),
            for (final detail in details.where((item) => item.isNotEmpty)) ...[
              Text(detail),
              const SizedBox(height: 6),
            ],
            if (banner != null) ...[
              banner!,
              const SizedBox(height: 6),
            ],
            if (documentAction != null ||
                secondaryDocumentAction != null ||
                primaryAction != null ||
                secondaryAction != null) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (documentAction != null)
                    OutlinedButton.icon(
                      onPressed: documentAction,
                      icon: const Icon(Icons.visibility_outlined),
                      label: Text(documentLabel),
                    ),
                  if (secondaryDocumentAction != null)
                    OutlinedButton.icon(
                      onPressed: secondaryDocumentAction,
                      icon: const Icon(Icons.flip_to_back_outlined),
                      label: Text(secondaryDocumentLabel),
                    ),
                  if (secondaryAction != null)
                    OutlinedButton.icon(
                      onPressed: secondaryAction,
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                    ),
                  if (primaryAction != null)
                    FilledButton.icon(
                      onPressed: primaryAction,
                      icon: const Icon(Icons.check),
                      label: const Text('Approve'),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewDetailRow extends StatelessWidget {
  const _ReviewDetailRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final color = switch (status) {
      'approved' => Colors.green,
      'rejected' => colors.error,
      _ => Colors.orange,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        _title(status),
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

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
            const Icon(Icons.fact_check_outlined, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}

String _title(String value) {
  if (value.isEmpty) return value;
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

class _InspectionImageViewerDialog extends StatefulWidget {
  const _InspectionImageViewerDialog({
    required this.title,
    required this.bytes,
  });

  final String title;
  final Uint8List bytes;

  @override
  State<_InspectionImageViewerDialog> createState() =>
      _InspectionImageViewerDialogState();
}

class _InspectionImageViewerDialogState
    extends State<_InspectionImageViewerDialog> {
  final _transformationController = TransformationController();
  TapDownDetails? _doubleTapDetails;
  double _currentScale = 1.0;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onTransformationChanged);
  }

  void _onTransformationChanged() {
    final scale = _transformationController.value.getMaxScaleOnAxis();
    if ((scale - _currentScale).abs() > 0.05) {
      setState(() => _currentScale = scale);
    }
  }

  @override
  void dispose() {
    _transformationController.removeListener(_onTransformationChanged);
    _transformationController.dispose();
    super.dispose();
  }

  void _zoomIn() {
    final newScale = (_currentScale * 1.5).clamp(1.0, 8.0);
    _animateToScale(newScale);
  }

  void _zoomOut() {
    final newScale = (_currentScale / 1.5).clamp(1.0, 8.0);
    _animateToScale(newScale);
  }

  void _resetZoom() {
    _animateToScale(1.0);
  }

  void _animateToScale(double targetScale) {
    _transformationController.value = Matrix4.diagonal3Values(
      targetScale,
      targetScale,
      1.0,
    );
  }

  void _handleDoubleTap() {
    if (_currentScale > 1.2) {
      _resetZoom();
    } else {
      final position = _doubleTapDetails?.localPosition ?? Offset.zero;
      final x = -position.dx * 2.0;
      final y = -position.dy * 2.0;
      final matrix = Matrix4.diagonal3Values(3.0, 3.0, 1.0);
      matrix.setTranslationRaw(x, y, 0.0);
      _transformationController.value = matrix;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Zoom Out',
            icon: const Icon(Icons.zoom_out_rounded),
            onPressed: _currentScale > 1.05 ? _zoomOut : null,
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${(_currentScale * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Zoom In',
            icon: const Icon(Icons.zoom_in_rounded),
            onPressed: _currentScale < 7.9 ? _zoomIn : null,
          ),
          IconButton(
            tooltip: 'Reset to 100%',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: _currentScale != 1.0 ? _resetZoom : null,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          GestureDetector(
            onDoubleTapDown: (details) => _doubleTapDetails = details,
            onDoubleTap: _handleDoubleTap,
            child: Center(
              child: InteractiveViewer(
                transformationController: _transformationController,
                minScale: 1.0,
                maxScale: 8.0,
                clipBehavior: Clip.none,
                child: Image.memory(
                  widget.bytes,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white24),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pinch_rounded,
                      color: Colors.white70,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Pinch to zoom (up to 8x) • Drag to pan • Double-tap to quick zoom',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

