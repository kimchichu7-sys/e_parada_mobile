import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/vehicle.dart';
import '../services/api_client.dart';
import '../services/vehicle_service.dart';
import '../utils/registration_validation.dart';
import '../widgets/vehicle_catalog_fields.dart';

class VehicleGarageScreen extends StatefulWidget {
  const VehicleGarageScreen({super.key});

  @override
  State<VehicleGarageScreen> createState() => _VehicleGarageScreenState();
}

class _VehicleGarageScreenState extends State<VehicleGarageScreen> {
  late Future<_GarageData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_GarageData> _load() async {
    final result = await VehicleService.fetchVehicles();
    final headers = await VehicleService.photoHeaders();
    return _GarageData(result: result, photoHeaders: headers);
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
    await _future;
  }

  Future<void> _openAddVehicle() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddVehicleScreen()),
    );
    if (added == true && mounted) await _refresh();
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove rejected vehicle?'),
        content: Text(
          'Remove ${vehicle.plateNumber}? You may submit a replacement afterward.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final message = await VehicleService.deleteRejectedVehicle(vehicle.id);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My vehicles')),
      body: FutureBuilder<_GarageData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(error: snapshot.error, onRetry: _refresh);
          }

          final data = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  '${data.result.vehicles.length} of ${data.result.maximum} vehicles registered',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Plate numbers cannot be edited after submission. An administrator must approve each vehicle before it can be used for reservations.',
                ),
                const SizedBox(height: 18),
                if (data.result.vehicles.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('No vehicles registered yet.'),
                    ),
                  ),
                ...data.result.vehicles.map(
                  (vehicle) => _VehicleCard(
                    vehicle: vehicle,
                    photoHeaders: data.photoHeaders,
                    onDelete: vehicle.isRejected
                        ? () => _deleteVehicle(vehicle)
                        : null,
                  ),
                ),
                if (data.result.remaining > 0) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: _openAddVehicle,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(
                      'Add vehicle (${data.result.remaining} remaining)',
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GarageData {
  const _GarageData({required this.result, required this.photoHeaders});

  final VehicleListResult result;
  final Map<String, String> photoHeaders;
}

class _VehiclePhoto extends StatelessWidget {
  const _VehiclePhoto({
    required this.label,
    required this.url,
    required this.headers,
  });

  final String label;
  final String url;
  final Map<String, String> headers;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (url.isEmpty)
          const ColoredBox(
            color: Color(0xFFE2E8F0),
            child: Icon(Icons.directions_car_outlined, size: 46),
          )
        else
          Image.network(
            url,
            headers: headers,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(
              color: Color(0xFFE2E8F0),
              child: Icon(Icons.broken_image_outlined, size: 42),
            ),
          ),
        Positioned(
          left: 8,
          bottom: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.photoHeaders,
    this.onDelete,
  });

  final Vehicle vehicle;
  final Map<String, String> photoHeaders;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final statusColor = vehicle.isApproved
        ? Colors.green
        : vehicle.isRejected
        ? colors.error
        : Colors.amber.shade800;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 7,
            child: Row(
              children: [
                Expanded(
                  child: _VehiclePhoto(
                    label: 'Front',
                    url: vehicle.photoUrl,
                    headers: photoHeaders,
                  ),
                ),
                Expanded(
                  child: _VehiclePhoto(
                    label: 'Back',
                    url: vehicle.photoBackUrl,
                    headers: photoHeaders,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        vehicle.plateNumber,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _statusLabel(vehicle.verificationStatus),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${vehicle.color} ${vehicle.make.isEmpty ? '' : '${vehicle.make} '}${vehicle.model}',
                ),
                Text(vehicle.vehicleType),
                const SizedBox(height: 6),
                Text(
                  _plateScanLabel(vehicle.plateScanStatus),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (vehicle.verificationNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Admin note: ${vehicle.verificationNotes}',
                    style: TextStyle(color: colors.error),
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove rejected vehicle'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _statusLabel(String status) {
    return switch (status) {
      'approved' => 'Approved',
      'rejected' => 'Rejected',
      _ => 'Pending review',
    };
  }

  static String _plateScanLabel(String status) {
    return switch (status) {
      'matched' => 'Photo scan: plate matched',
      'mismatch' => 'Photo scan: mismatch - admin review required',
      'not_detected' => 'Photo scan: plate was not readable',
      'unavailable' => 'Photo scan: OCR unavailable - manual review',
      _ => 'Photo scan: manual review required',
    };
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48),
            const SizedBox(height: 12),
            Text(error.toString(), textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _plateController = TextEditingController();
  String _vehicleType = 'Car';
  String _vehicleMake = '';
  String _vehicleModel = '';
  String _vehicleColor = '';
  XFile? _frontPhoto;
  XFile? _backPhoto;
  bool _consent = false;
  bool _loading = false;
  String? _error;

  Future<void> _pickPhoto(ValueSetter<XFile> onPicked) async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (photo != null && mounted) {
      setState(() {
        onPicked(photo);
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_frontPhoto == null || _backPhoto == null || !_consent) {
      setState(() {
        _error = _frontPhoto == null
            ? 'Choose a clear front photo showing the plate.'
            : _backPhoto == null
            ? 'Choose a clear back photo showing the plate.'
            : 'Consent is required before submitting the photo.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    _plateController.text = RegistrationValidation.normalizePlate(
      _plateController.text,
      _vehicleType,
    );

    try {
      final message = await VehicleService.addVehicle(
        plateNumber: _plateController.text,
        vehicleType: _vehicleType,
        vehicleMake: _vehicleMake,
        vehicleColor: _vehicleColor,
        vehicleModel: _vehicleModel,
        vehiclePhoto: UploadFileData(
          bytes: await _frontPhoto!.readAsBytes(),
          filename: _frontPhoto!.name,
        ),
        vehiclePhotoBack: UploadFileData(
          bytes: await _backPhoto!.readAsBytes(),
          filename: _backPhoto!.name,
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add vehicle')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'The plate number and submitted vehicle details become read-only. Check them carefully before submitting.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              decoration: InputDecoration(
                labelText: 'Plate number',
                hintText: _vehicleType == RegistrationValidation.motorcycleType
                    ? 'A 123 BC'
                    : 'ABC 1234',
                helperText: RegistrationValidation.plateHint(_vehicleType),
              ),
              validator: (value) =>
                  RegistrationValidation.plate(value, _vehicleType),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _vehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle type'),
              items: VehicleService.vehicleTypes
                  .map(
                    (type) => DropdownMenuItem(value: type, child: Text(type)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _vehicleType = value;
                    _vehicleMake = '';
                    _vehicleModel = '';
                    _vehicleColor = '';
                    _plateController.text = '';
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            VehicleCatalogFields(
              key: ValueKey(_vehicleType),
              vehicleType: _vehicleType,
              enabled: !_loading,
              onChanged: (make, model, color) {
                _vehicleMake = make;
                _vehicleModel = model;
                _vehicleColor = color;
              },
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _pickPhoto((file) => _frontPhoto = file),
                    icon: Icon(
                      _frontPhoto == null
                          ? Icons.add_a_photo_outlined
                          : Icons.check_circle_outline,
                    ),
                    label: Text(_frontPhoto?.name ?? 'Vehicle front'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _loading
                        ? null
                        : () => _pickPhoto((file) => _backPhoto = file),
                    icon: Icon(
                      _backPhoto == null
                          ? Icons.add_a_photo_outlined
                          : Icons.check_circle_outline,
                    ),
                    label: Text(_backPhoto?.name ?? 'Vehicle back'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            CheckboxListTile(
              value: _consent,
              onChanged: (value) => setState(() => _consent = value ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('I consent to vehicle verification'),
              subtitle: const Text(
                'The front and back photos are used only to match the registered vehicle with the vehicle used for a reservation.',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _loading ? null : _submit,
              icon: _loading
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_loading ? 'Submitting...' : 'Submit for review'),
            ),
          ],
        ),
      ),
    );
  }
}
