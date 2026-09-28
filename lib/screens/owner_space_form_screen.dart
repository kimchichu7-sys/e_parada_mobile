import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../models/owner_parking_space.dart';
import '../services/api_client.dart';
import '../services/owner_operations_service.dart';

class OwnerSpaceFormScreen extends StatefulWidget {
  const OwnerSpaceFormScreen({super.key, this.space});

  final OwnerParkingSpace? space;

  bool get isEditing => space != null;

  @override
  State<OwnerSpaceFormScreen> createState() => _OwnerSpaceFormScreenState();
}

class _OwnerSpaceFormScreenState extends State<OwnerSpaceFormScreen> {
  static const _calambaCenter = LatLng(14.2117, 121.1653);
  static const _graceOptions = [15, 30, 45, 60];
  static const _abandonedOptions = [24, 48, 72];

  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _dimensionsController = TextEditingController();
  final _descriptionController = TextEditingController();

  final Set<String> _vehicleTypes = <String>{};
  final List<List<String>> _slotVehicleTypes = <List<String>>[];
  final List<XFile> _images = <XFile>[];

  GoogleMapController? _mapController;
  LatLng? _location;
  bool _open24Hours = true;
  TimeOfDay _openingTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _closingTime = const TimeOfDay(hour: 20, minute: 0);
  int _graceMinutes = 30;
  int _abandonedHours = 24;
  bool _locating = false;
  bool _saving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final space = widget.space;

    if (space == null) {
      _vehicleTypes.add('Car');
      _slotVehicleTypes.add(<String>['Car']);
      return;
    }

    _nameController.text = space.name;
    _addressController.text = space.address;
    _dimensionsController.text = space.dimensionsSquareMeters?.toString() ?? '';
    _descriptionController.text = space.description;
    if (space.latitude != null && space.longitude != null) {
      _location = LatLng(space.latitude!, space.longitude!);
    }
    _vehicleTypes.addAll(space.vehicleTypes);
    _open24Hours = space.isOpen24Hours;
    _openingTime = _parseTime(space.openingTime) ?? _openingTime;
    _closingTime = _parseTime(space.closingTime) ?? _closingTime;
    _graceMinutes = _graceOptions.contains(space.overstayGraceMinutes)
        ? space.overstayGraceMinutes
        : 30;
    _abandonedHours = _abandonedOptions.contains(space.abandonedAfterHours)
        ? space.abandonedAfterHours
        : 24;

    if (space.slots.isNotEmpty) {
      for (final slot in space.slots) {
        _slotVehicleTypes.add(List<String>.from(slot.supportedVehicleTypes));
      }
    } else {
      final slotCount = space.totalSlots > 0 ? space.totalSlots : 1;
      for (var index = 0; index < slotCount; index++) {
        _slotVehicleTypes.add(List<String>.from(_vehicleTypes));
      }
    }

    if (_vehicleTypes.isEmpty) {
      _vehicleTypes.add('Car');
    }
    _normaliseSlots();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _dimensionsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() {
      _locating = true;
      _errorMessage = null;
    });

    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const ApiException('Turn on location services, then try again.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw const ApiException(
          'Location permission is required to use your current position.',
        );
      }

      final position = await Geolocator.getCurrentPosition();
      final location = LatLng(position.latitude, position.longitude);
      if (!mounted) return;

      setState(() => _location = location);
      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(location, 17),
      );
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  Future<void> _pickImages() async {
    final selected = await _picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (!mounted || selected.isEmpty) return;

    final remaining = 5 - _images.length;
    if (remaining <= 0) {
      _showMessage('You can upload up to five images.');
      return;
    }

    setState(() {
      _images.addAll(selected.take(remaining));
      _errorMessage = null;
    });

    if (selected.length > remaining) {
      _showMessage('Only the first five selected images were added.');
    }
  }

  Future<void> _pickTime({required bool opening}) async {
    final initial = opening ? _openingTime : _closingTime;
    final selected = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (selected == null || !mounted) return;

    setState(() {
      if (opening) {
        _openingTime = selected;
      } else {
        _closingTime = selected;
      }
    });
  }

  void _toggleVehicleType(String type, bool selected) {
    setState(() {
      if (selected) {
        _vehicleTypes.add(type);
      } else if (_vehicleTypes.length > 1) {
        _vehicleTypes.remove(type);
      }
      _normaliseSlots();
    });
  }

  void _normaliseSlots() {
    final fallback = _vehicleTypes.first;
    for (final slotTypes in _slotVehicleTypes) {
      slotTypes.removeWhere((type) => !_vehicleTypes.contains(type));
      if (slotTypes.isEmpty) slotTypes.add(fallback);
    }
  }

  void _changeSlotCount(int delta) {
    setState(() {
      if (delta > 0 && _slotVehicleTypes.length < 100) {
        _slotVehicleTypes.add(List<String>.from(_vehicleTypes));
      } else if (delta < 0 && _slotVehicleTypes.length > 1) {
        _slotVehicleTypes.removeLast();
      }
    });
  }

  void _toggleSlotVehicle(int slot, String type, bool selected) {
    setState(() {
      final supported = _slotVehicleTypes[slot];
      if (selected) {
        if (!supported.contains(type)) supported.add(type);
      } else if (supported.length > 1) {
        supported.remove(type);
      }
    });
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (_location == null) {
      setState(() => _errorMessage = 'Choose the exact location on the map.');
      return;
    }
    if (!widget.isEditing && _images.isEmpty) {
      setState(
        () => _errorMessage = 'Upload at least one parking-space image.',
      );
      return;
    }
    if (!_open24Hours && _openingTime == _closingTime) {
      setState(() {
        _errorMessage = 'Opening and closing times must be different.';
      });
      return;
    }

    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      final uploads = <UploadFileData>[];
      for (final image in _images) {
        uploads.add(
          UploadFileData(
            bytes: await image.readAsBytes(),
            filename: image.name,
          ),
        );
      }

      final message = await OwnerOperationsService.saveSpace(
        parkingSpaceId: widget.space?.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        latitude: _location!.latitude,
        longitude: _location!.longitude,
        vehicleTypes: _vehicleTypes.toList(growable: false),
        dimensionsSquareMeters: double.parse(_dimensionsController.text.trim()),
        description: _descriptionController.text.trim(),
        isOpen24Hours: _open24Hours,
        openingTime: _formatTime(_openingTime),
        closingTime: _formatTime(_closingTime),
        overstayGraceMinutes: _graceMinutes,
        abandonedAfterHours: _abandonedHours,
        slotVehicleTypes: _slotVehicleTypes,
        images: uploads,
      );

      if (!mounted) return;
      Navigator.pop(context, message);
    } catch (error) {
      if (mounted) setState(() => _errorMessage = error.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final mapCenter = _location ?? _calambaCenter;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isEditing ? 'Edit Parking Space' : 'Add Parking Space',
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              if (widget.space?.approvalStatus == 'rejected' &&
                  widget.space?.adminNotes?.isNotEmpty == true)
                _Notice(
                  icon: Icons.report_outlined,
                  color: colors.error,
                  title: 'Admin review notes',
                  message: widget.space!.adminNotes!,
                ),
              _Section(
                title: 'Parking details',
                icon: Icons.local_parking_rounded,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(labelText: 'Space name'),
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    textInputAction: TextInputAction.next,
                    minLines: 2,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Complete address',
                      alignLabelWithHint: true,
                    ),
                    validator: _required,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _dimensionsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Area in square meters',
                      suffixText: 'sqm',
                    ),
                    validator: (value) {
                      final number = double.tryParse(value?.trim() ?? '');
                      return number != null && number > 0
                          ? null
                          : 'Enter an area greater than zero.';
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      hintText:
                          'Access instructions, landmarks, and useful details',
                    ),
                    validator: _required,
                  ),
                ],
              ),
              _Section(
                title: 'Exact location',
                icon: Icons.location_on_outlined,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      height: 280,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: mapCenter,
                          zoom: _location == null ? 12 : 17,
                        ),
                        onMapCreated: (controller) =>
                            _mapController = controller,
                        onTap: (position) =>
                            setState(() => _location = position),
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: true,
                        markers: _location == null
                            ? const <Marker>{}
                            : {
                                Marker(
                                  markerId: const MarkerId('parking-space'),
                                  position: _location!,
                                  draggable: true,
                                  onDragEnd: (position) {
                                    setState(() => _location = position);
                                  },
                                ),
                              },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _location == null
                              ? 'Tap the map to place the parking marker.'
                              : '${_location!.latitude.toStringAsFixed(6)}, '
                                    '${_location!.longitude.toStringAsFixed(6)}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: _locating ? null : _useCurrentLocation,
                        icon: _locating
                            ? const SizedBox.square(
                                dimension: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location_rounded),
                        label: const Text('My location'),
                      ),
                    ],
                  ),
                ],
              ),
              _Section(
                title: 'Vehicle support',
                icon: Icons.directions_car_outlined,
                children: [
                  Text(
                    'Choose every vehicle type that this space can accept.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: OwnerOperationsService.vehicleTypes
                        .map((type) {
                          return FilterChip(
                            label: Text(type),
                            selected: _vehicleTypes.contains(type),
                            onSelected: (selected) =>
                                _toggleVehicleType(type, selected),
                          );
                        })
                        .toList(growable: false),
                  ),
                ],
              ),
              _Section(
                title: 'Slots',
                icon: Icons.grid_view_outlined,
                trailing: _SlotStepper(
                  count: _slotVehicleTypes.length,
                  onDecrease: _slotVehicleTypes.length > 1
                      ? () => _changeSlotCount(-1)
                      : null,
                  onIncrease: _slotVehicleTypes.length < 100
                      ? () => _changeSlotCount(1)
                      : null,
                ),
                children: [
                  Text(
                    'Set which registered vehicle types fit in each slot.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  // Visual Layout Bay Preview
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.layers_outlined, size: 16, color: Color(0xFF38BDF8)),
                            SizedBox(width: 6),
                            Text(
                              'Visual Floor Plan Preview',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 52,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _slotVehicleTypes.length,
                            separatorBuilder: (_, _) => const SizedBox(width: 8),
                            itemBuilder: (context, i) {
                              return Container(
                                width: 72,
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF38BDF8), width: 1.5),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Bay ${i + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 11,
                                      ),
                                    ),
                                    Text(
                                      _slotVehicleTypes[i].isNotEmpty ? _slotVehicleTypes[i].first : 'Any',
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 9,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_slotVehicleTypes.length, (index) {
                    final supported = _slotVehicleTypes[index];
                    return ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: const EdgeInsets.only(bottom: 12),
                      title: Text(
                        'Slot ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(supported.join(', ')),
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _vehicleTypes
                                .map((type) {
                                  return FilterChip(
                                    label: Text(type),
                                    selected: supported.contains(type),
                                    onSelected: (selected) =>
                                        _toggleSlotVehicle(
                                          index,
                                          type,
                                          selected,
                                        ),
                                  );
                                })
                                .toList(growable: false),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              _Section(
                title: 'Operating policy',
                icon: Icons.schedule_outlined,
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _open24Hours,
                    onChanged: (value) => setState(() => _open24Hours = value),
                    title: const Text(
                      'Open 24 hours',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: const Text(
                      'Turn this off to set daily opening and closing times.',
                    ),
                  ),
                  if (!_open24Hours) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _TimeButton(
                            label: 'Opens',
                            time: _openingTime.format(context),
                            onPressed: () => _pickTime(opening: true),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _TimeButton(
                            label: 'Closes',
                            time: _closingTime.format(context),
                            onPressed: () => _pickTime(opening: false),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: _graceMinutes,
                    decoration: const InputDecoration(
                      labelText: 'Overstay grace period',
                    ),
                    items: _graceOptions
                        .map(
                          (minutes) => DropdownMenuItem(
                            value: minutes,
                            child: Text('$minutes minutes'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) setState(() => _graceMinutes = value);
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<int>(
                    initialValue: _abandonedHours,
                    decoration: const InputDecoration(
                      labelText: 'Unattended vehicle threshold',
                    ),
                    items: _abandonedOptions
                        .map(
                          (hours) => DropdownMenuItem(
                            value: hours,
                            child: Text('$hours hours'),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _abandonedHours = value);
                      }
                    },
                  ),
                ],
              ),
              _Section(
                title: 'Photos',
                icon: Icons.photo_library_outlined,
                children: [
                  if (widget.space?.imageUrls.isNotEmpty == true &&
                      _images.isEmpty) ...[
                    _PhotoStrip(networkUrls: widget.space!.imageUrls),
                    const SizedBox(height: 10),
                  ],
                  if (_images.isNotEmpty) ...[
                    _PhotoStrip(
                      files: _images,
                      onRemove: (index) =>
                          setState(() => _images.removeAt(index)),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: _images.length >= 5 ? null : _pickImages,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text(
                      widget.isEditing
                          ? 'Replace parking photos'
                          : 'Add parking photos',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.isEditing
                        ? 'Choosing new photos replaces the current gallery. Up to five JPG or PNG images.'
                        : 'Upload 1 to 5 clear JPG or PNG images of the actual parking area.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              _Notice(
                icon: Icons.admin_panel_settings_outlined,
                color: colors.primary,
                title: 'Admin approval required',
                message: widget.isEditing
                    ? 'Saving changes returns this space to pending review. Existing reservations are kept.'
                    : 'The space becomes visible to drivers only after an administrator approves it and sets the rates.',
              ),
              if (_errorMessage != null)
                _Notice(
                  icon: Icons.error_outline,
                  color: colors.error,
                  title: 'Could not save',
                  message: _errorMessage!,
                ),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Text(
                    _saving
                        ? 'Saving...'
                        : widget.isEditing
                        ? 'Save Changes'
                        : 'Submit for Review',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value?.trim().isNotEmpty == true ? null : 'This field is required.';

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static TimeOfDay? _parseTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SlotStepper extends StatelessWidget {
  const _SlotStepper({
    required this.count,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int count;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrease,
          tooltip: 'Remove last slot',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '$count',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        IconButton(
          onPressed: onIncrease,
          tooltip: 'Add slot',
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onPressed,
  });

  final String label;
  final String time;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.schedule_outlined),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelSmall),
            Text(time, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _PhotoStrip extends StatelessWidget {
  const _PhotoStrip({
    this.files = const [],
    this.networkUrls = const [],
    this.onRemove,
  });

  final List<XFile> files;
  final List<String> networkUrls;
  final ValueChanged<int>? onRemove;

  @override
  Widget build(BuildContext context) {
    final count = files.isNotEmpty ? files.length : networkUrls.length;
    return SizedBox(
      height: 106,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: count,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final image = files.isNotEmpty
              ? FutureBuilder<Uint8List>(
                  future: files[index].readAsBytes(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Image.memory(snapshot.data!, fit: BoxFit.cover);
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                )
              : Image.network(
                  networkUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Center(child: Icon(Icons.broken_image_outlined)),
                );

          return SizedBox(
            width: 132,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                    child: image,
                  ),
                  if (onRemove != null)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: IconButton.filled(
                        onPressed: () => onRemove!(index),
                        tooltip: 'Remove image',
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.color,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 3),
                Text(message),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
