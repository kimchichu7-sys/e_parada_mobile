import 'dart:typed_data';

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
    final future = _load();
    setState(() {
      _future = future;
    });
    await future;
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
                const SizedBox(height: 8),
                _buildOcrBadge(context, vehicle.plateScanStatus),
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

  static Widget _buildOcrBadge(BuildContext context, String status) {
    final (label, icon, color) = switch (status) {
      'matched' => (
        'OCR: Plate Matched & Validated',
        Icons.verified_outlined,
        Colors.green.shade700,
      ),
      'mismatch' => (
        'OCR: Character Mismatch (Admin Audit)',
        Icons.warning_amber_rounded,
        Colors.red.shade700,
      ),
      'not_detected' => (
        'OCR: Plate Not Legible',
        Icons.blur_on_rounded,
        Colors.orange.shade800,
      ),
      'unavailable' => (
        'OCR: Unavailable (Manual Review)',
        Icons.help_outline_rounded,
        Colors.blueGrey.shade700,
      ),
      _ => (
        'OCR: Pending Verification',
        Icons.fact_check_outlined,
        Colors.blue.shade700,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
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
      imageQuality: 75,
      maxWidth: 1280,
      maxHeight: 1280,
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.document_scanner_outlined,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tesseract OCR Plate Verification',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ensure photos are clear and the license plate is directly readable. OCR extracts characters to cross-verify against Philippine LTO syntax (${RegistrationValidation.plateHint(_vehicleType)}).',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _photoUploadCard(
                    title: 'Vehicle Front',
                    subtitle: 'Front plate visible',
                    file: _frontPhoto,
                    onTap: _loading ? null : () => _pickPhoto((file) => _frontPhoto = file),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _photoUploadCard(
                    title: 'Vehicle Rear',
                    subtitle: 'Rear plate visible',
                    file: _backPhoto,
                    onTap: _loading ? null : () => _pickPhoto((file) => _backPhoto = file),
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

  Widget _photoUploadCard({
    required String title,
    required String subtitle,
    required XFile? file,
    required VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: file != null ? Colors.green.shade600 : colors.outlineVariant,
            width: file != null ? 1.5 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: file == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo_outlined, size: 28, color: colors.primary),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )
              : FutureBuilder<Uint8List>(
                  future: file.readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
                    }
                    if (snapshot.hasData) {
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(snapshot.data!, fit: BoxFit.cover),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.6),
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: 6,
                            left: 8,
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Positioned(
                            bottom: 6,
                            right: 8,
                            child: Text(
                              'Tap to change',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ),
                        ],
                      );
                    }
                    return Center(child: Text(file.name));
                  },
                ),
        ),
      ),
    );
  }
}
