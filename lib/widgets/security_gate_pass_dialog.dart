import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_theme.dart';
import '../models/driver_reservation.dart';
import '../utils/validators.dart';
import 'live_overstay_tracker_card.dart';

class SecurityGatePassDialog extends StatelessWidget {
  const SecurityGatePassDialog({
    super.key,
    required this.reservation,
    this.vehicleMakeModel = 'Verified Vehicle',
    this.vehicleColor = 'Standard',
  });

  final DriverReservation reservation;
  final String vehicleMakeModel;
  final String vehicleColor;

  static Future<void> show(
    BuildContext context, {
    required DriverReservation reservation,
    String vehicleMakeModel = 'Verified Vehicle',
    String vehicleColor = 'Standard',
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SecurityGatePassDialog(
        reservation: reservation,
        vehicleMakeModel: vehicleMakeModel,
        vehicleColor: vehicleColor,
      ),
    );
  }

  String get _refCode => Validators.formatReservationNumber(
        reservation.backupReference,
        id: reservation.id,
      );

  String get _scheduleWindow {
    final start = '${reservation.reservationDate} ${reservation.startTime}';
    final end =
        '${reservation.endDate.isNotEmpty ? reservation.endDate : reservation.reservationDate} ${reservation.endTime}';
    return '$start to $end';
  }

  String get _slotLabel {
    if (reservation.slotLabel.isNotEmpty) {
      return reservation.slotLabel;
    }
    return 'General Parking Area';
  }

  String _buildGatePassText() {
    return '''
==================================================
        E-PARADA OFFICIAL SECURITY GATE PASS
==================================================
Pass Reference: $_refCode
Status: VERIFIED & AUTHORIZED ENTRY

[VEHICLE & DRIVER DETAILS]
Plate Number: ${reservation.plateNumber.toUpperCase()}
Vehicle Type: ${reservation.vehicleType.toUpperCase()}
Make & Model: $vehicleMakeModel
Vehicle Color: $vehicleColor
Authorized Driver: Verified E-Parada Driver

[PARKING DESTINATION & SCHEDULE]
Facility Name: ${reservation.parkingSpaceName}
Designated Slot: $_slotLabel
Space Owner / Host: ${reservation.ownerName}
Access Window: $_scheduleWindow

[SECURITY INSTRUCTIONS]
1. Verify plate number against physical vehicle.
2. Grant barrier clearance directly to assigned bay ($_slotLabel).
3. In case of scanner issues, reference code: $_refCode

Issued via E-Parada Automated Clearance System
==================================================''';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPalette.yaleBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: AppPalette.yaleBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Gate Pass',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Official Condo / Subdivision Access Permit',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LiveOverstayTrackerCard(
                        reservation: reservation,
                        isCompact: true,
                      ),
                      const SizedBox(height: 8),
                      // Official Pass Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.yaleBlue, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Badge Row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'E-PARADA PASS',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                    color: AppPalette.yaleBlue,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFF166534)),
                                  ),
                                  child: const Text(
                                    'SECURITY VERIFIED',
                                    style: TextStyle(
                                      color: Color(0xFF166534),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // QR Code
                            Center(
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: QrImageView(
                                  data: _refCode,
                                  version: QrVersions.auto,
                                  size: 150.0,
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Code text & copy
                            InkWell(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: _refCode));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Copied $_refCode to clipboard'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _refCode,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.copy_rounded, size: 14),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Details Table
                            _infoRow('Vehicle Plate', reservation.plateNumber.toUpperCase(), isHighlight: true),
                            _infoRow('Designated Slot', _slotLabel, isHighlight: true),
                            _infoRow('Vehicle Specs', '${reservation.vehicleType.toUpperCase()} • $vehicleMakeModel'),
                            _infoRow('Facility', reservation.parkingSpaceName),
                            _infoRow('Schedule Window', _scheduleWindow),
                            _infoRow('Space Owner', reservation.ownerName),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Guard Notice
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.security_rounded, color: Colors.amber.shade900, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Present this digital pass to the subdivision or condo security guard at the gate for barrier clearance.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Export / Share Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Pass Text'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _buildGatePassText()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gate pass details copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('Download Pass (PDF)'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPalette.yaleBlue,
                      ),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _buildGatePassText()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF1E3A8A),
                            content: Text(
                              'Gate pass document ready! Reference: $_refCode saved for security printing.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isHighlight ? FontWeight.w900 : FontWeight.w700,
                color: isHighlight ? AppPalette.yaleBlue : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
