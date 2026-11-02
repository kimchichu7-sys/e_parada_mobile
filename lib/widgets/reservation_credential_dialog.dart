import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../utils/web_file_download.dart';

Future<Uint8List> generateQrPassImageBytes({
  required String qrCode,
  required String backupReference,
  required String parkingSpaceName,
}) async {
  final qrData = qrCode.trim().isNotEmpty ? qrCode : backupReference;
  final painter = QrPainter(
    data: qrData,
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

  const double width = 720;
  const double height = 880;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // Background
  final bgPaint = Paint()..color = const Color(0xFFFFFFFF);
  canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), bgPaint);

  // Header band
  final headerPaint = Paint()..color = const Color(0xFF102B4B);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(24, 24, width - 48, 80),
      const Radius.circular(16),
    ),
    headerPaint,
  );

  // Header Title
  final headerPainter = TextPainter(
    text: const TextSpan(
      text: 'E-PARADA • ACTIVE PARKING PASS',
      style: TextStyle(
        color: Color(0xFFFACC15),
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 80);
  headerPainter.paint(
    canvas,
    Offset((width - headerPainter.width) / 2, 50),
  );

  // Space Name
  final spacePainter = TextPainter(
    text: TextSpan(
      text: parkingSpaceName,
      style: const TextStyle(
        color: Color(0xFF0F172A),
        fontSize: 26,
        fontWeight: FontWeight.w900,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 80);
  spacePainter.paint(
    canvas,
    Offset((width - spacePainter.width) / 2, 126),
  );

  // Subtitle
  final subPainter = TextPainter(
    text: const TextSpan(
      text: 'Scan at entrance/exit checkpoint or dictate backup reference',
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 80);
  subPainter.paint(
    canvas,
    Offset((width - subPainter.width) / 2, 166),
  );

  // QR Code Box border
  final qrBoxPaint = Paint()
    ..color = const Color(0xFFCBD5E1)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH((width - 480) / 2, 204, 480, 480),
      const Radius.circular(20),
    ),
    qrBoxPaint,
  );

  // Paint QR Code centered inside the box
  canvas.save();
  canvas.translate((width - 440) / 2, 224);
  painter.paint(canvas, const Size(440, 440));
  canvas.restore();

  // Backup Reference Banner
  final refBgPaint = Paint()..color = const Color(0xFFF1F5F9);
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(48, 706, width - 96, 94),
      const Radius.circular(14),
    ),
    refBgPaint,
  );

  final refLabelPainter = TextPainter(
    text: const TextSpan(
      text: 'BACKUP REFERENCE CODE',
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 13,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.0,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 120);
  refLabelPainter.paint(
    canvas,
    Offset((width - refLabelPainter.width) / 2, 720),
  );

  final refCodePainter = TextPainter(
    text: TextSpan(
      text: backupReference,
      style: const TextStyle(
        color: Color(0xFF1E3A8A),
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 2.0,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 120);
  refCodePainter.paint(
    canvas,
    Offset((width - refCodePainter.width) / 2, 748),
  );

  // Footer Note
  final footerPainter = TextPainter(
    text: const TextSpan(
      text: 'Offline Access Pass • Saved from E-Parada Mobile',
      style: TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: width - 80);
  footerPainter.paint(
    canvas,
    Offset((width - footerPainter.width) / 2, 826),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(width.toInt(), height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) {
    throw Exception('Failed to encode QR pass image as PNG.');
  }
  return byteData.buffer.asUint8List();
}

Future<bool> downloadReservationQrPass(
  BuildContext context, {
  required String qrCode,
  required String backupReference,
  required String parkingSpaceName,
}) async {
  try {
    final bytes = await generateQrPassImageBytes(
      qrCode: qrCode,
      backupReference: backupReference,
      parkingSpaceName: parkingSpaceName,
    );

    final safeRef = backupReference.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = 'EParada_QR_$safeRef.png';

    if (kIsWeb) {
      final success = await downloadFileOnWeb(
        bytes: bytes,
        filename: filename,
        mimeType: 'image/png',
      );
      if (!context.mounted) return success;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF059669),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('QR Pass downloaded ($filename). Accessible offline!'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        await Clipboard.setData(ClipboardData(text: qrCode.isNotEmpty ? qrCode : backupReference));
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('QR Code text copied to clipboard.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return success;
    } else {
      Directory? dir;
      File? file;

      if (Platform.isAndroid) {
        final downloads = Directory('/storage/emulated/0/Download');
        if (downloads.existsSync()) {
          try {
            final testFile = File('${downloads.path}/$filename');
            await testFile.writeAsBytes(bytes);
            file = testFile;
            dir = downloads;
          } catch (_) {
            // Permission denied or scoped storage fallback
          }
        }
        if (file == null) {
          dir = await getExternalStorageDirectory() ??
              await getApplicationDocumentsDirectory();
          final fallbackFile = File('${dir.path}/$filename');
          await fallbackFile.writeAsBytes(bytes);
          file = fallbackFile;
        }
      } else if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        dir = await getDownloadsDirectory() ??
            await getApplicationDocumentsDirectory();
        final desktopFile = File('${dir.path}/$filename');
        await desktopFile.writeAsBytes(bytes);
        file = desktopFile;
      } else {
        dir = await getApplicationDocumentsDirectory();
        final docFile = File('${dir.path}/$filename');
        await docFile.writeAsBytes(bytes);
        file = docFile;
      }

      if (!context.mounted) return true;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF059669),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text('QR Pass saved to Downloads ($filename)'),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return true;
    }
  } catch (e) {
    if (!context.mounted) return false;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.shade700,
        content: Text('Unable to save QR pass: $e'),
        behavior: SnackBarBehavior.floating,
      ),
    );
    return false;
  }
}

class _DownloadQrButton extends StatefulWidget {
  const _DownloadQrButton({
    required this.qrCode,
    required this.backupReference,
    required this.parkingSpaceName,
  });

  final String qrCode;
  final String backupReference;
  final String parkingSpaceName;

  @override
  State<_DownloadQrButton> createState() => _DownloadQrButtonState();
}

class _DownloadQrButtonState extends State<_DownloadQrButton> {
  bool _saving = false;
  bool _saved = false;

  Future<void> _handleDownload() async {
    if (_saving) return;
    setState(() {
      _saving = true;
    });

    final success = await downloadReservationQrPass(
      context,
      qrCode: widget.qrCode,
      backupReference: widget.backupReference,
      parkingSpaceName: widget.parkingSpaceName,
    );

    if (mounted) {
      setState(() {
        _saving = false;
        if (success) _saved = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: _saving ? null : _handleDownload,
      icon: _saving
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(
              _saved ? Icons.check_circle_rounded : Icons.download_rounded,
              size: 18,
            ),
      label: Text(
        _saving
            ? 'Generating Pass...'
            : (_saved ? 'QR Pass Downloaded' : 'Download QR Code'),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: _saved ? const Color(0xFF059669) : const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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
                _DownloadQrButton(
                  qrCode: qrCode,
                  backupReference: backupReference,
                  parkingSpaceName: parkingSpaceName,
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
