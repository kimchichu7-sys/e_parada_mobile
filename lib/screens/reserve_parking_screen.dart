import 'package:flutter/material.dart';

import '../models/reservation_availability.dart';
import '../models/vehicle.dart';
import '../services/api_client.dart';
import '../services/reservation_service.dart';
import '../services/vehicle_service.dart';
import '../widgets/smart_occupancy_heatmap_card.dart';
import '../widgets/visual_parking_grid.dart';

class ReserveParkingScreen extends StatefulWidget {
  const ReserveParkingScreen({
    super.key,
    required this.parkingSpaceId,
    required this.parkingName,
    required this.address,
    required this.price,
  });

  final int parkingSpaceId;
  final String parkingName;
  final String address;
  final String price;

  @override
  State<ReserveParkingScreen> createState() => _ReserveParkingScreenState();
}

class _ReserveParkingScreenState extends State<ReserveParkingScreen> {
  List<Vehicle> _vehicles = const [];
  Vehicle? _vehicle;
  ReservationAvailability? _availability;
  ReservationSlot? _slot;
  late DateTime _startDate;
  late DateTime _endDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  bool _loading = true;
  bool _checking = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final initial = DateTime.now().add(const Duration(hours: 1));
    _startDate = DateTime(initial.year, initial.month, initial.day);
    _endDate = _startDate;
    _startTime = TimeOfDay(hour: initial.hour, minute: 0);
    _endTime = TimeOfDay(hour: (initial.hour + 1) % 24, minute: 0);
    if (initial.hour == 23) {
      _endDate = _startDate.add(const Duration(days: 1));
    }
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    try {
      final result = await VehicleService.fetchVehicles();
      final approved = result.vehicles
          .where((vehicle) => vehicle.isApproved)
          .toList();
      if (!mounted) return;
      setState(() {
        _vehicles = approved;
        _vehicle = approved.isEmpty ? null : approved.first;
        _loading = false;
      });
      if (approved.isNotEmpty) await _checkAvailability();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkAvailability() async {
    final vehicle = _vehicle;
    if (vehicle == null || _checking) return;
    setState(() {
      _checking = true;
      _error = null;
      _slot = null;
    });

    try {
      final availability = await ReservationService.checkAvailability(
        parkingSpaceId: widget.parkingSpaceId,
        vehicleId: vehicle.id,
        reservationDate: _date(_startDate),
        endDate: _date(_endDate),
        startTime: _time(_startTime),
        endTime: _time(_endTime),
      );
      if (!mounted) return;
      setState(() => _availability = availability);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _availability = null;
        _error = error.toString();
      });
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _submit() async {
    final vehicle = _vehicle;
    final slot = _slot;
    if (vehicle == null || slot == null || _submitting) return;
    setState(() => _submitting = true);

    try {
      final message = await ReservationService.createReservation(
        parkingSpaceId: widget.parkingSpaceId,
        vehicleId: vehicle.id,
        vehicleType: vehicle.vehicleType,
        parkingSlotId: slot.id,
        reservationDate: _date(_startDate),
        endDate: _date(_endDate),
        startTime: _time(_startTime),
        endTime: _time(_endTime),
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: const Icon(Icons.check_circle_outline),
          title: const Text('Reservation sent'),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Done'),
            ),
          ],
        ),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) _showError(error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDate(bool start) async {
    final current = start ? _startDate : _endDate;
    final today = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: current.isBefore(today) ? today : current,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: today.add(const Duration(days: 365)),
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _startDate = selected;
        if (_endDate.isBefore(selected)) _endDate = selected;
      } else {
        _endDate = selected;
      }
      _availability = null;
      _slot = null;
    });
  }

  Future<void> _pickTime(bool start) async {
    final selected = await showTimePicker(
      context: context,
      initialTime: start ? _startTime : _endTime,
    );
    if (selected == null) return;
    setState(() {
      if (start) {
        _startTime = selected;
      } else {
        _endTime = selected;
      }
      _availability = null;
      _slot = null;
    });
  }

  void _showError(Object error) {
    final message = error is ApiException ? error.message : error.toString();
    final isConflict = error is ApiException &&
        (error.statusCode == 409 ||
            message.toLowerCase().contains('conflict') ||
            message.toLowerCase().contains('already booked') ||
            message.toLowerCase().contains('collision') ||
            message.toLowerCase().contains('overlapping'));

    if (isConflict) {
      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          icon: Icon(
            Icons.event_busy_rounded,
            color: Colors.orange.shade800,
            size: 32,
          ),
          title: const Text('Slot Booking Collision Detected'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Database concurrency locking protected against double-booking for this time slot.',
                        style: TextStyle(fontSize: 12, color: Colors.brown),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _checkAvailability();
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Choose Another Slot'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline),
        title: const Text('Unable to continue'),
        content: Text(message),
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
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Reserve Parking')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parkingName,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 6),
                        Text(widget.address),
                        const SizedBox(height: 8),
                        Text(
                          widget.price,
                          style: TextStyle(
                            color: colors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_vehicles.isEmpty)
                  _MessageCard(
                    icon: Icons.no_crash_outlined,
                    message:
                        'No approved vehicle is available. Submit a vehicle in Profile and wait for admin approval.',
                  )
                else ...[
                  _MultiVehicleSwitcher(
                    vehicles: _vehicles,
                    selectedVehicle: _vehicle,
                    onVehicleChanged: (vehicle) {
                      setState(() {
                        _vehicle = vehicle;
                        _availability = null;
                        _slot = null;
                      });
                      _checkAvailability();
                    },
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.sizeOf(context).width >= 600
                        ? 4
                        : 2,
                    childAspectRatio: MediaQuery.sizeOf(context).width >= 600
                        ? 3.0
                        : 2.2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: [
                      _PickerTile(
                        label: 'Start date',
                        value: _date(_startDate),
                        icon: Icons.calendar_today_outlined,
                        onTap: () => _pickDate(true),
                      ),
                      _PickerTile(
                        label: 'End date',
                        value: _date(_endDate),
                        icon: Icons.event_outlined,
                        onTap: () => _pickDate(false),
                      ),
                      _PickerTile(
                        label: 'Start time',
                        value: _startTime.format(context),
                        icon: Icons.schedule_outlined,
                        onTap: () => _pickTime(true),
                      ),
                      _PickerTile(
                        label: 'End time',
                        value: _endTime.format(context),
                        icon: Icons.more_time_outlined,
                        onTap: () => _pickTime(false),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _checking ? null : _checkAvailability,
                    icon: _checking
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _checking ? 'Checking...' : 'Check availability',
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    _MessageCard(icon: Icons.info_outline, message: _error!),
                  ],
                  if (_availability != null) ...[
                    const SizedBox(height: 20),
                    SmartOccupancyHeatmapCard(
                      slots: _availability!.slots,
                      onRefreshRequested: _checkAvailability,
                    ),
                    const SizedBox(height: 16),
                    VisualParkingGrid(
                      slots: _availability!.slots,
                      selectedSlot: _slot,
                      onSlotSelected: (slot) => setState(() => _slot = slot),
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: _slot == null || _submitting ? null : _submit,
                      icon: _submitting
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_outlined),
                      label: Text(
                        _submitting ? 'Submitting...' : 'Submit reservation',
                      ),
                    ),
                  ],
                ],
              ],
            ),
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

  static String _time(TimeOfDay value) =>
      '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          suffixIcon: Icon(icon),
        ),
        child: Text(value, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _MultiVehicleSwitcher extends StatelessWidget {
  const _MultiVehicleSwitcher({
    required this.vehicles,
    required this.selectedVehicle,
    required this.onVehicleChanged,
  });

  final List<Vehicle> vehicles;
  final Vehicle? selectedVehicle;
  final ValueChanged<Vehicle> onVehicleChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.directions_car_rounded, size: 18, color: colors.primary),
                const SizedBox(width: 6),
                const Text(
                  'Select Vehicle for Reservation',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                ),
              ],
            ),
            Text(
              '${vehicles.length} Available',
              style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 86,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vehicles.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              final isSelected = selectedVehicle?.id == vehicle.id;

              return InkWell(
                onTap: () => onVehicleChanged(vehicle),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 220,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colors.primaryContainer.withValues(alpha: 0.7)
                        : colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? colors.primary : colors.outlineVariant,
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors.primary.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.primary
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          vehicle.vehicleType.toLowerCase().contains('motor')
                              ? Icons.two_wheeler_rounded
                              : Icons.directions_car_filled_rounded,
                          color: isSelected ? colors.onPrimary : colors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    vehicle.plateNumber,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 4),
                                  Icon(Icons.check_circle_rounded, size: 14, color: colors.primary),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${vehicle.vehicleType} • ${vehicle.make.isNotEmpty ? vehicle.make : 'Default'}',
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

