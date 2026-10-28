import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> _downloadQrCode(
  BuildContext context, {
  required String qrCode,
  required String backupReference,
  required String parkingSpaceName,
}) async {
  try {
    final painter = QrPainter(
      data: qrCode,
      version: QrVersions.auto,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    );

    final picData = await painter.toImageData(600);
    if (picData == null) {
      throw Exception('Could not generate QR image data.');
    }

    final bytes = picData.buffer.asUint8List();

    if (!kIsWeb) {
      Directory? dir;
      if (Platform.isAndroid) {
        final downloads = Directory('/storage/emulated/0/Download');
        if (downloads.existsSync()) {
          dir = downloads;
        } else {
          dir = await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        dir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final safeRef =
          backupReference.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
      final file = File('${dir.path}/EParada_QR_$safeRef.png');
      await file.writeAsBytes(bytes);

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF059669),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('QR Code saved to Downloads (EParada_QR_$safeRef.png)'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      await Clipboard.setData(ClipboardData(text: qrCode));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code text copied to clipboard.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text('Unable to save QR code: $e'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

Future<void> showReservationCredentialDialog({
  required BuildContext context,
  required String qrCode,
  required String backupReference,
  required String parkingSpaceName,
}) {
  return showDialog<void>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      icon: const Icon(Icons.qr_code_2_rounded, size: 32, color: Color(0xFF2563EB)),
      title: const Text(
        'QR Code (Entry & Exit)',
        style: TextStyle(fontWeight: FontWeight.w900),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                parkingSpaceName,
                textAlign: TextAlign.center,
                style: Theme.of(
                  dialogCtx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              if (qrCode.isNotEmpty) ...[
                Semantics(
                  label: 'Scannable reservation QR code',
                  image: true,
                  child: Container(
                    width: 224,
                    height: 224,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: qrCode,
                      version: QrVersions.auto,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => _downloadQrCode(
                    dialogCtx,
                    qrCode: qrCode,
                    backupReference: backupReference,
                    parkingSpaceName: parkingSpaceName,
                  ),
                  icon: const Icon(Icons.download_rounded, size: 18),
                  label: const Text('Download QR Code'),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ] else
                const _CredentialNotice(
                  icon: Icons.qr_code_2_outlined,
                  message:
                      'The QR image is unavailable. Use the backup reference below.',
                ),
              const SizedBox(height: 16),
              Text(
                'The parking provider scans this same QR code for both entry and exit, or you can enter this backup reference.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(dialogCtx).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  color: Theme.of(dialogCtx).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        backupReference,
                        style: Theme.of(dialogCtx).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy backup reference',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: backupReference),
                        );
                        if (!dialogCtx.mounted) return;
                        ScaffoldMessenger.of(dialogCtx).showSnackBar(
                          const SnackBar(
                            content: Text('Backup reference copied.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const _CredentialNotice(
                icon: Icons.shield_outlined,
                message:
                    'Only use this credential at the parking space named above.',
              ),
            ],
          ),
        ),
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.pop(dialogCtx),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF102B4B),
          ),
          child: const Text('Done'),
        ),
      ],
    ),
  );
}

class ReservationProgressTracker extends StatelessWidget {
  const ReservationProgressTracker({
    super.key,
    required this.status,
    required this.paymentStatus,
    required this.timeIn,
    required this.timeOut,
  });

  final String status;
  final String paymentStatus;
  final DateTime? timeIn;
  final DateTime? timeOut;

  @override
  Widget build(BuildContext context) {
    final approved = status == 'approved' || status == 'completed';
    final paymentSubmitted =
        paymentStatus == 'pending_verification' || paymentStatus == 'paid';
    final steps = <(String, IconData, bool)>[
      ('Requested', Icons.receipt_long_outlined, true),
      ('Approved', Icons.task_alt_rounded, approved),
      ('Checked in', Icons.login_rounded, timeIn != null),
      ('Checked out', Icons.logout_rounded, timeOut != null),
      ('Payment sent', Icons.upload_file_rounded, paymentSubmitted),
      ('Paid', Icons.verified_rounded, paymentStatus == 'paid'),
    ];

    return Semantics(
      label: 'Reservation progress',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final step in steps)
            _ProgressStep(label: step.$1, icon: step.$2, complete: step.$3),
        ],
      ),
    );
  }
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.label,
    required this.icon,
    required this.complete,
  });

  final String label;
  final IconData icon;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: complete
            ? colors.primaryContainer
            : colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            complete ? Icons.check_circle_rounded : icon,
            size: 16,
            color: complete ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: complete ? colors.primary : colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _CredentialNotice extends StatelessWidget {
  const _CredentialNotice({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(message)),
      ],
    );
  }
}
