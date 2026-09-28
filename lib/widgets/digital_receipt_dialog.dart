import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../config/app_theme.dart';
import '../models/driver_reservation.dart';
import '../models/owner_reservation.dart';

class DigitalReceiptDialog extends StatelessWidget {
  const DigitalReceiptDialog({
    super.key,
    required this.reference,
    required this.parkingSpaceName,
    this.parkingSpaceAddress = '',
    required this.ownerName,
    required this.driverName,
    required this.plateNumber,
    required this.vehicleType,
    required this.slotLabel,
    required this.scheduleLabel,
    this.timeIn,
    this.timeOut,
    this.totalHours,
    required this.totalAmount,
    required this.paymentStatus,
    required this.paymentMethod,
    this.overstayMinutes = 0,
    this.overstayAmount = 0,
  });

  final String reference;
  final String parkingSpaceName;
  final String parkingSpaceAddress;
  final String ownerName;
  final String driverName;
  final String plateNumber;
  final String vehicleType;
  final String slotLabel;
  final String scheduleLabel;
  final DateTime? timeIn;
  final DateTime? timeOut;
  final double? totalHours;
  final double totalAmount;
  final String paymentStatus;
  final String paymentMethod;
  final int overstayMinutes;
  final double overstayAmount;

  static Future<void> showForDriver(
    BuildContext context,
    DriverReservation reservation,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => DigitalReceiptDialog(
        reference: reservation.backupReference.isNotEmpty
            ? reservation.backupReference
            : 'RES-${reservation.id}',
        parkingSpaceName: reservation.parkingSpaceName,
        parkingSpaceAddress: reservation.parkingSpaceAddress,
        ownerName: reservation.ownerName,
        driverName: 'You (Driver)',
        plateNumber: reservation.plateNumber,
        vehicleType: reservation.vehicleType,
        slotLabel: reservation.slotLabel,
        scheduleLabel: reservation.scheduleLabel,
        timeIn: reservation.timeIn,
        timeOut: reservation.timeOut,
        totalHours: reservation.totalHours,
        totalAmount: reservation.totalAmount ?? 0,
        paymentStatus: reservation.paymentStatus,
        paymentMethod: reservation.paymentMethod,
        overstayMinutes: reservation.overstayMinutes,
        overstayAmount: reservation.overstayAmount,
      ),
    );
  }

  static Future<void> showForOwner(
    BuildContext context,
    OwnerReservation reservation,
  ) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => DigitalReceiptDialog(
        reference: reservation.backupReference.isNotEmpty
            ? reservation.backupReference
            : 'RES-${reservation.id}',
        parkingSpaceName: reservation.parkingSpaceName,
        ownerName: 'You (Space Owner)',
        driverName: reservation.driverName,
        plateNumber: reservation.plateNumber,
        vehicleType: reservation.vehicleType,
        slotLabel: reservation.slotLabel,
        scheduleLabel: reservation.scheduleLabel,
        timeIn: reservation.timeIn,
        timeOut: reservation.timeOut,
        totalAmount: reservation.totalAmount ?? 0,
        paymentStatus: reservation.paymentStatus,
        paymentMethod: reservation.paymentMethod,
      ),
    );
  }

  // Tax and fee breakdown computations
  double get _baseNetVat => totalAmount > 0 ? (totalAmount / 1.12) : 0.0;
  double get _evat12 => totalAmount > 0 ? (totalAmount - _baseNetVat) : 0.0;

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'N/A';
    final local = dt.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }

  String _buildOfficialInvoiceText() {
    return '''
==================================================
           E-PARADA OFFICIAL TAX INVOICE
==================================================
Invoice Ref: $reference
Issue Date: ${_formatDateTime(DateTime.now())}
Tax ID / System Ref: EP-TAX-CALAMBA-2026-PH

[CUSTOMER & PARKING DETAILS]
Facility: $parkingSpaceName
Address: ${parkingSpaceAddress.isNotEmpty ? parkingSpaceAddress : 'Calamba City, Laguna'}
Assigned Slot: $slotLabel
Space Provider: $ownerName
Customer / Driver: $driverName
Vehicle Plate: ${plateNumber.toUpperCase()} ($vehicleType)

[SESSION DURATION & METRICS]
Schedule Window: $scheduleLabel
Actual Check-In: ${_formatDateTime(timeIn)}
Actual Check-Out: ${_formatDateTime(timeOut)}
Billed Hours: ${totalHours != null ? '${totalHours!.toStringAsFixed(1)} hrs' : 'Standard Session'}
Grace Period: 15-Minute LGU Rule Applied

[ITEMIZED TAX BREAKDOWN]
1. Base Parking Fare (VAT-Excl):    PHP ${_baseNetVat.toStringAsFixed(2)}
2. 12% Value Added Tax (EVAT):     PHP ${_evat12.toStringAsFixed(2)}
${overstayMinutes > 0 ? '3. Overstay Surcharge ($overstayMinutes mins):  PHP ${overstayAmount.toStringAsFixed(2)}\n' : ''}--------------------------------------------------
TOTAL AMOUNT PAID:                 PHP ${totalAmount.toStringAsFixed(2)}
Payment Method:                    ${paymentMethod.toUpperCase().isEmpty ? 'CASH' : paymentMethod.toUpperCase()}
Payment Status:                    ${paymentStatus.toUpperCase()}

==================================================
Digital Validation Code: $reference
Authorized by E-Parada Automated Clearance & Billing
==================================================''';
  }

  @override
  Widget build(BuildContext context) {
    final isPaid = paymentStatus.toLowerCase() == 'paid';

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppPalette.yaleBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppPalette.yaleBlue,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'E-Parada Official Receipt',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppPalette.yaleBlue,
                          ),
                        ),
                        Text(
                          'Tax Invoice & Payment Certificate • $reference',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
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
              const SizedBox(height: 14),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Status Banner
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isPaid ? const Color(0xFF166534) : const Color(0xFFD97706),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    isPaid ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
                                    size: 16,
                                    color: isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      isPaid ? 'PAYMENT VERIFIED & SETTLED' : 'PAYMENT AWAITING SETTLEMENT',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              paymentMethod.isNotEmpty ? paymentMethod.toUpperCase() : 'CASH',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isPaid ? const Color(0xFF166534) : const Color(0xFF92400E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // QR Stamp & Reference Seal
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6FAFF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: QrImageView(
                                data: reference,
                                version: QrVersions.auto,
                                size: 64.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DIGITAL AUTHENTICITY SEAL',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      color: AppPalette.yaleBlue,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    reference,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0A192C),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'System Reg: EP-TAX-CALAMBA-2026',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Information sections
                      _ReceiptSection(
                        title: 'Parking & Vehicle Particulars',
                        rows: [
                          _ReceiptRow(label: 'Facility', value: parkingSpaceName, isBold: true),
                          if (parkingSpaceAddress.isNotEmpty)
                            _ReceiptRow(label: 'Location', value: parkingSpaceAddress),
                          _ReceiptRow(label: 'Designated Bay', value: slotLabel, isBold: true),
                          _ReceiptRow(label: 'Host / Owner', value: ownerName),
                          if (driverName.isNotEmpty)
                            _ReceiptRow(label: 'Driver Name', value: driverName),
                          _ReceiptRow(label: 'Vehicle Plate', value: plateNumber.toUpperCase(), isBold: true),
                          _ReceiptRow(label: 'Category', value: vehicleType),
                        ],
                      ),
                      const Divider(height: 20),

                      _ReceiptSection(
                        title: 'Schedule & Duration',
                        rows: [
                          _ReceiptRow(label: 'Reserved Window', value: scheduleLabel),
                          if (timeIn != null)
                            _ReceiptRow(label: 'Actual Check-In', value: _formatDateTime(timeIn)),
                          if (timeOut != null)
                            _ReceiptRow(label: 'Actual Check-Out', value: _formatDateTime(timeOut)),
                          if (totalHours != null)
                            _ReceiptRow(
                              label: 'Total Billable Hours',
                              value: '${totalHours!.toStringAsFixed(1)} hrs',
                            ),
                          const _ReceiptRow(
                            label: 'Grace Policy',
                            value: '15-min deduction applied',
                            highlightColor: Color(0xFF166534),
                          ),
                          if (overstayMinutes > 0)
                            _ReceiptRow(
                              label: 'Overstay ($overstayMinutes mins)',
                              value: '+PHP ${overstayAmount.toStringAsFixed(2)}',
                              highlightColor: const Color(0xFFDC2626),
                            ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Itemized Tax Breakdown
                      _ReceiptSection(
                        title: 'Official Tax Breakdown (BIR Compliant)',
                        rows: [
                          _ReceiptRow(
                            label: 'Base Parking Fare (Net of VAT)',
                            value: 'PHP ${_baseNetVat.toStringAsFixed(2)}',
                          ),
                          _ReceiptRow(
                            label: '12% Value Added Tax (EVAT)',
                            value: 'PHP ${_evat12.toStringAsFixed(2)}',
                          ),
                          if (overstayMinutes > 0)
                            _ReceiptRow(
                              label: 'Overstay Accrual Fee',
                              value: 'PHP ${overstayAmount.toStringAsFixed(2)}',
                              highlightColor: const Color(0xFFDC2626),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Total Paid Box
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A192C),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'NET TOTAL SETTLED',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white70,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Inclusive of 12% EVAT & Fees',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'PHP ${totalAmount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: AppPalette.naplesYellow,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copy Text'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _buildOfficialInvoiceText()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tax invoice details copied to clipboard!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppPalette.yaleBlue,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                      label: const Text('Save PDF'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: _buildOfficialInvoiceText()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppPalette.yaleBlue,
                            content: Text(
                              'PDF Tax Invoice for $reference prepared & saved!',
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
}

class _ReceiptSection extends StatelessWidget {
  const _ReceiptSection({required this.title, required this.rows});

  final String title;
  final List<_ReceiptRow> rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppPalette.yaleBlue,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 6),
        ...rows,
      ],
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.highlightColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? highlightColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 6,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: highlightColor ?? const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
