import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

String? firstUsableQrValue(Iterable<String?> values) {
  for (final value in values) {
    final trimmed = value?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  }
  return null;
}

String scannerErrorMessage(String? message) {
  final rawMessage = message?.trim() ?? '';
  final normalized = rawMessage.toLowerCase();

  if (normalized.contains('notreadableerror') ||
      normalized.contains('could not start video source')) {
    return 'Chrome found a camera, but Windows could not open it. Close other '
        'E-Parada scanner tabs and apps using the camera, then press Retry camera.';
  }

  if (normalized.contains('notallowederror') ||
      normalized.contains('permission')) {
    return 'Camera access is blocked. Allow camera access for this site in '
        'Chrome, then press Retry camera.';
  }

  return rawMessage.isNotEmpty
      ? rawMessage
      : 'Allow camera access and use HTTPS on phones, or enter the permanent '
            'RES-# reference manually.';
}

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late MobileScannerController _scannerController;
  int _scannerGeneration = 0;
  bool _handled = false;

  MobileScannerController _createScannerController() {
    return MobileScannerController(
      formats: const [BarcodeFormat.qrCode],
      facing: kIsWeb ? CameraFacing.front : CameraFacing.back,
      cameraResolution: const Size(640, 480),
    );
  }

  @override
  void initState() {
    super.initState();
    _scannerController = _createScannerController();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleCapture(BarcodeCapture capture) async {
    if (_handled) return;

    final credential = firstUsableQrValue(
      capture.barcodes.map((barcode) => barcode.rawValue),
    );
    if (credential == null) return;

    _handled = true;
    await _scannerController.stop();
    if (mounted) Navigator.pop(context, credential);
  }

  Future<void> _retryCamera() async {
    final previousController = _scannerController;

    try {
      await previousController.stop();
    } catch (_) {
      // A failed browser media stream can reject stop even though disposal
      // is still required before creating a fresh controller.
    }

    await previousController.dispose();
    if (!mounted) return;

    setState(() {
      _scannerController = _createScannerController();
      _scannerGeneration++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan reservation QR'),
        actions: [
          IconButton(
            tooltip: 'Toggle flashlight',
            onPressed: _scannerController.toggleTorch,
            icon: const Icon(Icons.flashlight_on_outlined),
          ),
          IconButton(
            tooltip: 'Switch camera',
            onPressed: _scannerController.switchCamera,
            icon: const Icon(Icons.cameraswitch_outlined),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            key: ValueKey(_scannerGeneration),
            controller: _scannerController,
            onDetect: _handleCapture,
            errorBuilder: (context, error) => _ScannerUnavailable(
              message: error.errorDetails?.message,
              onRetry: _retryCamera,
            ),
          ),
          IgnorePointer(
            child: Center(
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: colors.primary, width: 4),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 32,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Place the driver\'s reservation QR code inside the frame. '
                  'The credential will be validated automatically.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, height: 1.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerUnavailable extends StatelessWidget {
  const _ScannerUnavailable({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined, size: 52),
              const SizedBox(height: 14),
              Text(
                'Camera scanning is unavailable',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(scannerErrorMessage(message), textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Retry camera'),
                  ),
                  FilledButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.keyboard_outlined),
                    label: const Text('Enter manually'),
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
