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

  Future<void> _openEditVehicle(Vehicle vehicle) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehicleScreen(existingVehicle: vehicle),
      ),
    );
    if (updated == true && mounted) await _refresh();
  }

  Future<void> _openUploadDocuments(Vehicle vehicle) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => _UploadVehicleDocumentsScreen(vehicle: vehicle),
      ),
    );
    if (updated == true && mounted) await _refresh();
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove rejected vehicle?'),
        content: Text(
          'Remove ${vehicle.plateNumber}? This frees up its vehicle slot so you can add another vehicle.',
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
                  'Approved and pending vehicles are locked. If a vehicle is rejected, you can edit and resubmit it or remove it to free a slot.',
                ),
                const SizedBox(height: 18),
                if (!data.result.accountVerified) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade700.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.verified_user_outlined, size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account verification required',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Your email and account must be verified by an administrator before you can add a vehicle.',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (data.result.vehicles.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        data.result.accountVerified
                            ? 'No vehicles registered yet. Tap Add vehicle below to register your first vehicle.'
                            : 'No vehicles registered yet. You can add a vehicle once your account is verified.',
                      ),
                    ),
                  ),
                ...data.result.vehicles.map(
                  (vehicle) => _VehicleCard(
                    vehicle: vehicle,
                    photoHeaders: data.photoHeaders,
                    onUploadDocuments:
                        ((vehicle.orPhotoUrl == null ||
                                vehicle.orPhotoUrl!.isEmpty) ||
                            (vehicle.crPhotoUrl == null ||
                                vehicle.crPhotoUrl!.isEmpty) ||
                            !vehicle.isApproved)
                        ? () => _openUploadDocuments(vehicle)
                        : null,
                    onEdit: vehicle.isRejected
                        ? () => _openEditVehicle(vehicle)
                        : null,
                    onDelete: vehicle.isRejected
                        ? () => _deleteVehicle(vehicle)
                        : null,
                  ),
                ),
                if (data.result.canAddVehicle && data.result.remaining > 0) ...[
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
                  fontSize: 14,
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
    this.onUploadDocuments,
    this.onEdit,
    this.onDelete,
  });

  final Vehicle vehicle;
  final Map<String, String> photoHeaders;
  final VoidCallback? onUploadDocuments;
  final VoidCallback? onEdit;
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
                          fontSize: 14,
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
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (vehicle.registrationExpiry != null)
                      Chip(
                        avatar: const Icon(Icons.event_outlined, size: 14),
                        label: Text(
                          'Exp: ${vehicle.registrationExpiry!.year}-${vehicle.registrationExpiry!.month.toString().padLeft(2, '0')}-${vehicle.registrationExpiry!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    Chip(
                      avatar: Icon(
                        vehicle.isOwnerDriving ? Icons.person_outline : Icons.drive_eta_outlined,
                        size: 14,
                        color: vehicle.isOwnerDriving ? Colors.green.shade800 : Colors.amber.shade900,
                      ),
                      label: Text(
                        vehicle.isOwnerDriving
                            ? 'Owner-Driven'
                            : 'Auth. Driver (${vehicle.registeredOwnerName ?? 'Non-owner'})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: vehicle.isOwnerDriving ? Colors.green.shade900 : Colors.amber.shade900,
                        ),
                      ),
                      backgroundColor: vehicle.isOwnerDriving
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.amber.withValues(alpha: 0.15),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    if (vehicle.orPhotoUrl != null && vehicle.orPhotoUrl!.isNotEmpty)
                      const Chip(
                        avatar: Icon(Icons.description_outlined, size: 14),
                        label: Text('OR Attached', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    if (vehicle.crPhotoUrl != null && vehicle.crPhotoUrl!.isNotEmpty)
                      const Chip(
                        avatar: Icon(Icons.description_outlined, size: 14),
                        label: Text('CR Attached', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        visualDensity: VisualDensity.compact,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                  ],
                ),
                if ((vehicle.orPhotoUrl == null || vehicle.orPhotoUrl!.isEmpty) ||
                    (vehicle.crPhotoUrl == null || vehicle.crPhotoUrl!.isEmpty)) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Missing LTO OR / CR document. Upload below so admins can verify it.',
                    style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                  ),
                ],
                if (vehicle.verificationNotes?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Admin note: ${vehicle.verificationNotes}',
                    style: TextStyle(color: colors.error),
                  ),
                ],
                if (onUploadDocuments != null) ...[
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onUploadDocuments,
                    icon: const Icon(Icons.upload_file_outlined),
                    label: Text(
                      (vehicle.orPhotoUrl == null || vehicle.orPhotoUrl!.isEmpty) ||
                              (vehicle.crPhotoUrl == null ||
                                  vehicle.crPhotoUrl!.isEmpty)
                          ? 'Upload OR / CR Documents'
                          : 'Update OR / CR Documents',
                    ),
                  ),
                ],
                if (onEdit != null) ...[
                  const SizedBox(height: 8),
                  FilledButton.tonalIcon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit & resubmit'),
                  ),
                ],
                if (onDelete != null) ...[
                  const SizedBox(height: 8),
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
              fontSize: 14,
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
  const AddVehicleScreen({super.key, this.existingVehicle});

  final Vehicle? existingVehicle;

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _plateController = TextEditingController();
  final _ownerNameController = TextEditingController();
  String _vehicleType = 'Car';
  String _vehicleMake = '';
  String _vehicleModel = '';
  String _vehicleColor = '';
  String? _initialMake;
  String? _initialModel;
  String? _initialColor;
  XFile? _frontPhoto;
  XFile? _backPhoto;
  XFile? _orPhoto;
  XFile? _crPhoto;
  XFile? _authLetter;
  DateTime? _registrationExpiry;
  bool _isOwnerDriving = true;
  bool _consent = false;
  bool _loading = false;
  bool _scanningPlate = false;
  bool _plateAutoFilled = false;
  int _scanEpoch = 0;
  String? _ocrHint;
  String? _frontDetectedPlate;
  String? _backDetectedPlate;
  String? _error;

  bool get _isEditing => widget.existingVehicle != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingVehicle;
    if (existing != null) {
      _plateController.text = existing.plateNumber;
      _vehicleType = VehicleService.vehicleTypes.contains(existing.vehicleType)
          ? existing.vehicleType
          : (existing.vehicleType.contains('Motorcycle')
                ? 'Motorcycle'
                : (existing.vehicleType.contains('Van') ||
                          existing.vehicleType.contains('Pickup')
                      ? 'Pickup/Van'
                      : 'Car'));
      _vehicleMake = existing.make;
      _vehicleModel = existing.model;
      _vehicleColor = existing.color;
      _initialMake = existing.make;
      _initialModel = existing.model;
      _initialColor = existing.color;
      _registrationExpiry = existing.registrationExpiry;
      _isOwnerDriving = existing.isOwnerDriving;
      _ownerNameController.text = existing.registeredOwnerName ?? '';
      _consent = true;
    }
  }

  Future<void> _pickPhoto(
    ValueSetter<XFile> onPicked, {
    String? scanSide,
  }) async {
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
      if (scanSide != null) {
        await _scanPickedVehiclePhoto(photo, side: scanSide);
      }
    }
  }

  Future<void> _scanPickedVehiclePhoto(
    XFile photo, {
    required String side,
  }) async {
    final sideLabel = side == 'back' ? 'rear' : 'front';
    final selectedType = _vehicleType;
    final epoch = ++_scanEpoch;

    setState(() {
      _scanningPlate = true;
      _ocrHint = 'Scanning $sideLabel photo for license plate...';
    });

    try {
      final bytes = await photo.readAsBytes();
      final detected = await VehicleService.scanPlateFromPhoto(
        photo: UploadFileData(bytes: bytes, filename: photo.name),
        vehicleType: selectedType,
        side: side,
      );
      if (!mounted || _vehicleType != selectedType || epoch != _scanEpoch) {
        return;
      }

      if (detected != null && detected.isNotEmpty) {
        final normalized = RegistrationValidation.normalizePlate(
          detected,
          _vehicleType,
        );
        final shouldAutofill =
            _plateController.text.trim().isEmpty || _plateAutoFilled;

        setState(() {
          if (side == 'back') {
            _backDetectedPlate = normalized;
          } else {
            _frontDetectedPlate = normalized;
          }
          if (shouldAutofill) {
            _plateController.text = normalized;
            _plateAutoFilled = true;
            _ocrHint = 'Auto-detected plate from $sideLabel photo: $normalized';
          } else {
            _ocrHint = 'Scanned $sideLabel photo: $normalized';
          }
        });
        return;
      }

      final otherDetected = side == 'back'
          ? _frontDetectedPlate
          : _backDetectedPlate;
      setState(() {
        if (side == 'back') {
          _backDetectedPlate = null;
        } else {
          _frontDetectedPlate = null;
        }
        if (otherDetected != null && otherDetected.isNotEmpty) {
          _ocrHint =
              'No plate detected in $sideLabel photo (keeping $otherDetected).';
        } else {
          _ocrHint =
              'No clear plate detected in $sideLabel photo. You can type it manually.';
        }
      });
    } finally {
      if (mounted && epoch == _scanEpoch) {
        setState(() => _scanningPlate = false);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && (_frontPhoto == null || _backPhoto == null)) {
      setState(() {
        _error = _frontPhoto == null
            ? 'Choose a clear front photo showing the plate.'
            : 'Choose a clear back photo showing the plate.';
      });
      return;
    }

    if (!_consent) {
      setState(() {
        _error = 'Consent is required before submitting the vehicle.';
      });
      return;
    }

    if (!_isOwnerDriving && _ownerNameController.text.trim().isEmpty) {
      setState(() {
        _error = 'Please enter the registered owner\'s full name.';
      });
      return;
    }

    final hasExistingAuth =
        widget.existingVehicle?.authorizationLetterUrl?.isNotEmpty == true;
    if (!_isOwnerDriving &&
        _authLetter == null &&
        (!_isEditing || !hasExistingAuth)) {
      setState(() {
        _error =
            'Please upload an authorization letter or deed of sale from the registered owner.';
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
      final frontData = _frontPhoto != null
          ? UploadFileData(
              bytes: await _frontPhoto!.readAsBytes(),
              filename: _frontPhoto!.name,
            )
          : null;
      final backData = _backPhoto != null
          ? UploadFileData(
              bytes: await _backPhoto!.readAsBytes(),
              filename: _backPhoto!.name,
            )
          : null;
      final orData = _orPhoto != null
          ? UploadFileData(
              bytes: await _orPhoto!.readAsBytes(),
              filename: _orPhoto!.name,
            )
          : null;
      final crData = _crPhoto != null
          ? UploadFileData(
              bytes: await _crPhoto!.readAsBytes(),
              filename: _crPhoto!.name,
            )
          : null;
      final authData = _authLetter != null
          ? UploadFileData(
              bytes: await _authLetter!.readAsBytes(),
              filename: _authLetter!.name,
            )
          : null;

      final String message;
      if (_isEditing) {
        message = await VehicleService.updateRejectedVehicle(
          vehicleId: widget.existingVehicle!.id,
          plateNumber: _plateController.text,
          vehicleType: _vehicleType,
          vehicleMake: _vehicleMake,
          vehicleColor: _vehicleColor,
          vehicleModel: _vehicleModel,
          vehiclePhoto: frontData,
          vehiclePhotoBack: backData,
          orPhoto: orData,
          crPhoto: crData,
          authorizationLetter: authData,
          registrationExpiry: _registrationExpiry,
          isOwnerDriving: _isOwnerDriving,
          registeredOwnerName:
              !_isOwnerDriving ? _ownerNameController.text.trim() : null,
        );
      } else {
        message = await VehicleService.addVehicle(
          plateNumber: _plateController.text,
          vehicleType: _vehicleType,
          vehicleMake: _vehicleMake,
          vehicleColor: _vehicleColor,
          vehicleModel: _vehicleModel,
          vehiclePhoto: frontData!,
          vehiclePhotoBack: backData!,
          orPhoto: orData,
          crPhoto: crData,
          authorizationLetter: authData,
          registrationExpiry: _registrationExpiry,
          isOwnerDriving: _isOwnerDriving,
          registeredOwnerName:
              !_isOwnerDriving ? _ownerNameController.text.trim() : null,
        );
      }
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
    _ownerNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final existing = widget.existingVehicle;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit & resubmit vehicle' : 'Add vehicle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (_isEditing &&
                existing?.verificationNotes != null &&
                existing!.verificationNotes!.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                ),
                child: Text(
                  'Admin rejection note: ${existing.verificationNotes}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            Text(
              _isEditing
                  ? 'Update any corrected details, plate number, or photos below. Resubmitting returns this vehicle to pending admin review.'
                  : 'The plate number and submitted vehicle details become read-only while pending or approved. Check them carefully before submitting.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _plateController,
              textCapitalization: TextCapitalization.characters,
              onChanged: (_) {
                if (_plateAutoFilled) {
                  _plateAutoFilled = false;
                }
              },
              decoration: InputDecoration(
                labelText: 'Plate number',
                hintText: RegistrationValidation.isMotorcycle(_vehicleType)
                    ? 'A 123 BC'
                    : 'ABC 1234 or ABC 123',
                helperText: _ocrHint ?? RegistrationValidation.plateHint(_vehicleType),
                helperMaxLines: 2,
                suffixIcon: _scanningPlate
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
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
                    _initialMake = null;
                    _initialModel = null;
                    _initialColor = null;
                    if (!_isEditing) {
                      _plateController.text = '';
                    }
                    _plateAutoFilled = false;
                    _frontDetectedPlate = null;
                    _backDetectedPlate = null;
                    _ocrHint = null;
                  });
                }
              },
            ),
            const SizedBox(height: 14),
            VehicleCatalogFields(
              key: ValueKey(_vehicleType),
              vehicleType: _vehicleType,
              enabled: !_loading,
              initialMake: _initialMake,
              initialModel: _initialModel,
              initialColor: _initialColor,
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
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Ensure photos are clear and the license plate is readable in at least one view (front or rear, such as rear motorcycle plates). OCR auto-scans both photos against Philippine LTO syntax (${RegistrationValidation.plateHint(_vehicleType)}).',
                          style: TextStyle(
                            fontSize: 14,
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
                    subtitle: _isEditing && existing?.photoUrl.isNotEmpty == true
                        ? 'Current photo on file (tap to replace)'
                        : 'Front view (auto-scans)',
                    file: _frontPhoto,
                    onTap: _loading
                        ? null
                        : () => _pickPhoto(
                            (file) => _frontPhoto = file,
                            scanSide: 'front',
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _photoUploadCard(
                    title: 'Vehicle Rear',
                    subtitle: _isEditing && existing?.photoBackUrl.isNotEmpty == true
                        ? 'Current photo on file (tap to replace)'
                        : 'Rear plate (auto-scans)',
                    file: _backPhoto,
                    onTap: _loading
                        ? null
                        : () => _pickPhoto(
                            (file) => _backPhoto = file,
                            scanSide: 'back',
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                ),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      const Text(
                        'LTO Registration Documents',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload Official Receipt (OR) and Certificate of Registration (CR) to expedite verification.',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _photoUploadCard(
                          title: 'Official Receipt (OR)',
                          subtitle: _isEditing &&
                                  (existing?.orPhotoUrl?.isNotEmpty == true)
                              ? 'On file (tap to replace)'
                              : 'Latest LTO OR',
                          file: _orPhoto,
                          onTap: _loading ? null : () => _pickPhoto((file) => _orPhoto = file),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _photoUploadCard(
                          title: 'Cert. of Reg. (CR)',
                          subtitle: _isEditing &&
                                  (existing?.crPhotoUrl?.isNotEmpty == true)
                              ? 'On file (tap to replace)'
                              : 'LTO CR document',
                          file: _crPhoto,
                          onTap: _loading ? null : () => _pickPhoto((file) => _crPhoto = file),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Registration Expiry Date', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      _registrationExpiry != null
                          ? '${_registrationExpiry!.year}-${_registrationExpiry!.month.toString().padLeft(2, '0')}-${_registrationExpiry!.day.toString().padLeft(2, '0')}'
                          : 'Not selected',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: OutlinedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _registrationExpiry ?? DateTime.now().add(const Duration(days: 365)),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2040),
                              );
                              if (picked != null && mounted) {
                                setState(() => _registrationExpiry = picked);
                              }
                            },
                      child: const Text('Select Date'),
                    ),
                  ),
                  const Divider(),
                  CheckboxListTile(
                    value: _isOwnerDriving,
                    onChanged: (val) => setState(() => _isOwnerDriving = val ?? true),
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                    title: const Text(
                      'I am the registered owner of this vehicle',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!_isOwnerDriving) ...[
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: const InputDecoration(
                        labelText: "Registered Owner's Full Name",
                        hintText: 'e.g., Juan Dela Cruz',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _photoUploadCard(
                      title: 'Owner Authorization Letter / Deed of Sale',
                      subtitle: _isEditing &&
                              (existing?.authorizationLetterUrl?.isNotEmpty == true)
                          ? 'On file (tap to replace)'
                          : 'Signed permission to operate',
                      file: _authLetter,
                      onTap: _loading ? null : () => _pickPhoto((file) => _authLetter = file),
                    ),
                  ],
                ],
                  ),
                ),
              ),
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
              label: Text(
                _loading
                    ? (_isEditing ? 'Resubmitting...' : 'Submitting...')
                    : (_isEditing ? 'Save & resubmit' : 'Submit for review'),
              ),
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
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
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
                                    fontSize: 12,
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
                              style: TextStyle(color: Colors.white70, fontSize: 12),
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

class _UploadVehicleDocumentsScreen extends StatefulWidget {
  const _UploadVehicleDocumentsScreen({required this.vehicle});

  final Vehicle vehicle;

  @override
  State<_UploadVehicleDocumentsScreen> createState() =>
      _UploadVehicleDocumentsScreenState();
}

class _UploadVehicleDocumentsScreenState
    extends State<_UploadVehicleDocumentsScreen> {
  final _picker = ImagePicker();
  late final TextEditingController _ownerNameController;
  late bool _isOwnerDriving;
  DateTime? _registrationExpiry;
  XFile? _orPhoto;
  XFile? _crPhoto;
  XFile? _authLetter;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _isOwnerDriving = widget.vehicle.isOwnerDriving;
    _registrationExpiry = widget.vehicle.registrationExpiry;
    _ownerNameController = TextEditingController(
      text: widget.vehicle.registeredOwnerName ?? '',
    );
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(void Function(XFile file) assign) async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (file == null || !mounted) return;
    setState(() => assign(file));
  }

  Future<void> _submit() async {
    if (_orPhoto == null && _crPhoto == null && _authLetter == null) {
      setState(() {
        _error = 'Choose at least an OR, CR, or authorization photo to upload.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final message = await VehicleService.uploadVehicleDocuments(
        vehicleId: widget.vehicle.id,
        orPhoto: _orPhoto != null
            ? UploadFileData(
                bytes: await _orPhoto!.readAsBytes(),
                filename: _orPhoto!.name,
              )
            : null,
        crPhoto: _crPhoto != null
            ? UploadFileData(
                bytes: await _crPhoto!.readAsBytes(),
                filename: _crPhoto!.name,
              )
            : null,
        authorizationLetter: _authLetter != null
            ? UploadFileData(
                bytes: await _authLetter!.readAsBytes(),
                filename: _authLetter!.name,
              )
            : null,
        registrationExpiry: _registrationExpiry,
        isOwnerDriving: _isOwnerDriving,
        registeredOwnerName:
            !_isOwnerDriving ? _ownerNameController.text.trim() : null,
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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text('OR / CR - ${widget.vehicle.plateNumber}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Upload Official Receipt (OR) and Certificate of Registration (CR) for ${widget.vehicle.plateNumber}. If both appear on one page, upload it in the OR card.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _docCard(
                  context,
                  title: 'Official Receipt (OR)',
                  subtitle: _orPhoto?.name ?? 'Tap to select OR photo',
                  selected: _orPhoto != null,
                  onTap: _loading
                      ? null
                      : () => _pickPhoto((file) => _orPhoto = file),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _docCard(
                  context,
                  title: 'Cert. of Reg. (CR)',
                  subtitle: _crPhoto?.name ?? 'Tap to select CR photo',
                  selected: _crPhoto != null,
                  onTap: _loading
                      ? null
                      : () => _pickPhoto((file) => _crPhoto = file),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_month_outlined),
            title: const Text(
              'Registration Expiry Date',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              _registrationExpiry != null
                  ? '${_registrationExpiry!.year}-${_registrationExpiry!.month.toString().padLeft(2, '0')}-${_registrationExpiry!.day.toString().padLeft(2, '0')}'
                  : 'Not selected',
            ),
            trailing: OutlinedButton(
              onPressed: _loading
                  ? null
                  : () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            _registrationExpiry ??
                            DateTime.now().add(const Duration(days: 365)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2040),
                      );
                      if (picked != null && mounted) {
                        setState(() => _registrationExpiry = picked);
                      }
                    },
              child: const Text('Select Date'),
            ),
          ),
          const Divider(),
          CheckboxListTile(
            value: _isOwnerDriving,
            onChanged: _loading
                ? null
                : (val) => setState(() => _isOwnerDriving = val ?? true),
            contentPadding: EdgeInsets.zero,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              'I am the registered owner of this vehicle',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          if (!_isOwnerDriving) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _ownerNameController,
              decoration: const InputDecoration(
                labelText: "Registered Owner's Full Name",
                hintText: 'e.g., Juan Dela Cruz',
              ),
            ),
            const SizedBox(height: 10),
            _docCard(
              context,
              title: 'Owner Authorization Letter / Deed of Sale',
              subtitle: _authLetter?.name ?? 'Tap to select authorization photo',
              selected: _authLetter != null,
              onTap: _loading
                  ? null
                  : () => _pickPhoto((file) => _authLetter = file),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Text(_error!, style: TextStyle(color: colors.error)),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _loading ? null : _submit,
            icon: _loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(_loading ? 'Uploading...' : 'Upload Documents'),
          ),
        ],
      ),
    );
  }

  Widget _docCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback? onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 112),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? colors.primaryContainer.withValues(alpha: 0.45)
              : colors.surfaceContainerHighest.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? colors.primary : colors.outlineVariant,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.upload_file_outlined,
              color: colors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
