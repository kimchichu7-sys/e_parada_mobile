import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

Future<void> showReservationCredentialDialog({
  required BuildContext context,
  required String qrCode,
  required String backupReference,
  required String parkingSpaceName,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.qr_code_2_rounded),
      title: const Text('Entry credential'),
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
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              if (qrCode.isNotEmpty)
                Semantics(
                  label: 'Scannable reservation QR code',
                  image: true,
                  child: Container(
                    width: 224,
                    height: 224,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
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
                )
              else
                const _CredentialNotice(
                  icon: Icons.qr_code_2_outlined,
                  message:
                      'The QR image is unavailable. Use the backup reference below.',
                ),
              const SizedBox(height: 16),
              Text(
                'The parking owner can scan the QR code or enter this permanent backup reference.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SelectableText(
                        backupReference,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Copy backup reference',
                      onPressed: () async {
                        await Clipboard.setData(
                          ClipboardData(text: backupReference),
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
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
          onPressed: () => Navigator.pop(context),
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
