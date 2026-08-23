import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/auth_user.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../widgets/vehicle_chip.dart';
import 'profile_screen.dart';
import 'reserve_parking_screen.dart';

class ParkingDetailsScreen extends StatefulWidget {
  final int parkingSpaceId;
  final String parkingName;
  final String address;
  final String status;
  final String price;
  final String description;
  final List<String> supportedVehicles;
  final String? imageUrl;
  final String operatingHours;
  final double? latitude;
  final double? longitude;

  const ParkingDetailsScreen({
    super.key,
    required this.parkingSpaceId,
    required this.parkingName,
    required this.address,
    required this.status,
    required this.price,
    required this.description,
    required this.supportedVehicles,
    this.imageUrl,
    this.operatingHours = 'Hours unavailable',
    this.latitude,
    this.longitude,
  });

  @override
  State<ParkingDetailsScreen> createState() => _ParkingDetailsScreenState();
}

class _ParkingDetailsScreenState extends State<ParkingDetailsScreen> {
  bool _checkingReadiness = false;

  bool get _hasCoordinates =>
      widget.latitude != null && widget.longitude != null;

  Future<void> _openDirections() async {
    if (!_hasCoordinates) return;

    final directionsUri = Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${widget.latitude},${widget.longitude}',
      'travelmode': 'driving',
    });
    final opened = await launchUrl(
      directionsUri,
      mode: LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Google Maps could not be opened.')),
      );
    }
  }

  Future<void> _startReservation() async {
    setState(() => _checkingReadiness = true);

    try {
      final user = await AuthService.fetchMe();
      if (!mounted) return;

      if (user == null) {
        await _showReadinessDialog(
          title: 'Session expired',
          message: 'Please log in again before reserving a parking space.',
        );
        return;
      }

      if (!user.canReserve) {
        await _showReadinessDialog(
          title: 'Reservation unavailable',
          message: _readinessMessage(user),
          showProfileAction: true,
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReserveParkingScreen(
            parkingSpaceId: widget.parkingSpaceId,
            parkingName: widget.parkingName,
            address: widget.address,
            price: widget.price,
          ),
        ),
      );
    } on ApiException catch (error) {
      if (mounted) {
        await _showReadinessDialog(
          title: 'Unable to check account',
          message: error.message,
        );
      }
    } catch (_) {
      if (mounted) {
        await _showReadinessDialog(
          title: 'Unable to check account',
          message: 'Check your connection and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _checkingReadiness = false);
    }
  }

  String _readinessMessage(AuthUser user) {
    if (!user.emailVerified) {
      return 'Verify your email address before making a reservation.';
    }

    if (user.verificationStatus != 'approved') {
      return 'Your driver account is still waiting for administrator approval.';
    }

    if (!user.hasApprovedVehicle) {
      return 'At least one registered vehicle must be approved before you can reserve.';
    }

    return 'Your account is not ready for reservations yet. Review its status in Profile.';
  }

  Future<void> _showReadinessDialog({
    required String title,
    required String message,
    bool showProfileAction = false,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          if (showProfileAction)
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: const Text('View profile'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedStatus = widget.status.trim().toLowerCase();
    final isAvailable =
        normalizedStatus == 'available' || normalizedStatus == 'open';

    return Scaffold(
      appBar: AppBar(title: const Text('Parking Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ParkingHeroImage(imageUrl: widget.imageUrl),
          const SizedBox(height: 20),
          Text(
            widget.parkingName,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(widget.address),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isAvailable
                        ? const Color(0xFF166534)
                        : const Color(0xFF991B1B),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                widget.price,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF4F46E5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _DetailRow(
            icon: Icons.schedule_rounded,
            label: 'Operating hours',
            value: widget.operatingHours,
          ),
          if (_hasCoordinates) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.location_on_outlined,
              label: 'Map location',
              value:
                  '${widget.latitude!.toStringAsFixed(5)}, ${widget.longitude!.toStringAsFixed(5)}',
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Text(
            widget.description,
            style: const TextStyle(fontSize: 15, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'Supported Vehicles',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.supportedVehicles
                .map((vehicle) => VehicleChip(label: vehicle))
                .toList(),
          ),
          if (_hasCoordinates) ...[
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Open Directions'),
              ),
            ),
          ],
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _checkingReadiness ? null : _startReservation,
              icon: _checkingReadiness
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.event_available_outlined),
              label: Text(
                _checkingReadiness
                    ? 'Checking account...'
                    : 'Reserve This Space',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose your date and time on the next screen. The app will check the parking space schedule before submission.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ParkingHeroImage extends StatelessWidget {
  const _ParkingHeroImage({required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final fallback = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.local_parking_rounded,
          size: 58,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl == null || imageUrl!.isEmpty
            ? fallback
            : Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => fallback,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return ColoredBox(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
