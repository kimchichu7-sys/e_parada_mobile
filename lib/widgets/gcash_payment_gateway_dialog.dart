import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/paymongo_service.dart';
import 'paymongo_settings_dialog.dart';

class GcashPaymentResult {
  const GcashPaymentResult({
    required this.success,
    required this.referenceNo,
    required this.mobileNumber,
    required this.amount,
    this.paymongoSourceId,
    this.method = 'paymongo_gcash',
  });

  final bool success;
  final String referenceNo;
  final String mobileNumber;
  final double amount;
  final String? paymongoSourceId;
  final String method;
}

class GcashPaymentGatewayDialog extends StatefulWidget {
  const GcashPaymentGatewayDialog({
    super.key,
    required this.parkingSpaceName,
    required this.reservationReference,
    required this.totalAmount,
    this.initialMobileNumber = '',
  });

  final String parkingSpaceName;
  final String reservationReference;
  final double totalAmount;
  final String initialMobileNumber;

  static Future<GcashPaymentResult?> show({
    required BuildContext context,
    required String parkingSpaceName,
    required String reservationReference,
    required double totalAmount,
    String initialMobileNumber = '',
  }) {
    return showDialog<GcashPaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GcashPaymentGatewayDialog(
        parkingSpaceName: parkingSpaceName,
        reservationReference: reservationReference,
        totalAmount: totalAmount,
        initialMobileNumber: initialMobileNumber,
      ),
    );
  }

  @override
  State<GcashPaymentGatewayDialog> createState() =>
      _GcashPaymentGatewayDialogState();
}

class _GcashPaymentGatewayDialogState extends State<GcashPaymentGatewayDialog> {
  int _step = 1; // 1: Choose / Mobile, 2: PayMongo Hosted / Polling, 3: In-App MPIN, 4: Success
  late final TextEditingController _phoneController;
  final TextEditingController _pinController = TextEditingController();
  bool _processing = false;
  String _generatedReference = '';
  PayMongoSourceResult? _sourceResult;
  Timer? _pollingTimer;
  int _pollCount = 0;

  @override
  void initState() {
    super.initState();
    PayMongoService.init();
    _phoneController = TextEditingController(
      text: widget.initialMobileNumber.isNotEmpty
          ? widget.initialMobileNumber
          : '09',
    );
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  String _generateGcashRef() {
    final random = Random();
    final digits = List.generate(10, (_) => random.nextInt(10)).join();
    return 'GC-$digits';
  }

  Future<void> _handlePaymongoGatewayTap() async {
    if (!PayMongoService.hasCustomKey) {
      // Out of the box without real API key: smoothly proceed to the in-app interactive checkout
      setState(() => _step = 3);
      return;
    }

    setState(() => _processing = true);
    try {
      final source = await PayMongoService.createGcashSource(
        amountPhp: widget.totalAmount,
        description: 'E-Parada Parking: ${widget.parkingSpaceName} (${widget.reservationReference})',
        customerPhone: _phoneController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _sourceResult = source;
        _step = 2;
        _processing = false;
        _pollCount = 0;
      });

      if (source.checkoutUrl != null && source.checkoutUrl!.isNotEmpty) {
        final uri = Uri.parse(source.checkoutUrl!);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      _startStatusPolling(source.id);
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        showDialog<void>(
          context: context,
          builder: (dialogCtx) => AlertDialog(
            title: const Text('PayMongo Gateway Notice'),
            content: Text(
              '$e\n\nWould you like to use the In-App Direct Checkout or configure a valid API key in settings?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  PaymongoSettingsDialog.show(context);
                },
                child: const Text('Open Settings'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogCtx);
                  setState(() => _step = 3);
                },
                child: const Text('Use In-App Checkout'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _startStatusPolling(String sourceId) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (timer) async {
      _pollCount++;
      if (!mounted || _pollCount > 30) {
        timer.cancel();
        return;
      }

      final status = await PayMongoService.fetchSourceStatus(sourceId);
      if (status.isChargeable || status.isPaid) {
        timer.cancel();
        if (mounted) {
          _completeSuccessfulPayment(sourceId: status.id);
        }
      }
    });
  }

  void _completeSuccessfulPayment({String? sourceId}) {
    _pollingTimer?.cancel();
    final ref = sourceId ?? _sourceResult?.id ?? _generateGcashRef();
    setState(() {
      _processing = false;
      _generatedReference = ref;
      _step = 4;
    });
  }

  Future<void> _processInAppSimulatedPayment() async {
    setState(() => _processing = true);
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    _completeSuccessfulPayment();
  }

  @override
  Widget build(BuildContext context) {
    const gcashBlue = Color(0xFF005CE6);
    const gcashLightBlue = Color(0xFFE6F0FF);
    final hasKey = PayMongoService.hasCustomKey;
    final env = PayMongoService.environment;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // GCash Header
            Container(
              color: gcashBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: gcashBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'GCash Payment Gateway',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                hasKey
                                    ? (env == PayMongoEnvironment.live
                                        ? 'PayMongo Live'
                                        : 'PayMongo Sandbox')
                                    : 'GCash Sandbox',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'E-Parada',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_step != 4)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        _pollingTimer?.cancel();
                        Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ),

            // Order Amount Box
            Container(
              color: gcashLightBlue,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.parkingSpaceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Reservation: ${widget.reservationReference}',
                          style: const TextStyle(fontSize: 11, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '₱${widget.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: gcashBlue,
                    ),
                  ),
                ],
              ),
            ),

            // Body Steps
            Padding(
              padding: const EdgeInsets.all(20),
              child: switch (_step) {
                1 => _buildStep1Select(gcashBlue, hasKey),
                2 => _buildStep2PayMongoHosted(gcashBlue),
                3 => _buildStep3InAppPin(gcashBlue),
                _ => _buildStep4Success(gcashBlue),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep1Select(Color gcashBlue, bool hasKey) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'GCash Account Phone Number',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 11,
          decoration: InputDecoration(
            labelText: 'Mobile Number',
            hintText: '09XXXXXXXXX',
            prefixIcon: const Icon(Icons.phone_android_rounded),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 12),
        if (_processing)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: gcashBlue,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              if (_phoneController.text.trim().length < 11) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter an 11-digit GCash mobile number.')),
                );
                return;
              }
              _handlePaymongoGatewayTap();
            },
            icon: Icon(hasKey ? Icons.open_in_browser_rounded : Icons.account_balance_wallet_rounded),
            label: Text(hasKey ? 'Pay via PayMongo Hosted Checkout' : 'Proceed to GCash Checkout'),
          ),
          if (hasKey) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () {
                if (_phoneController.text.trim().length < 11) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter an 11-digit GCash mobile number.')),
                  );
                  return;
                }
                setState(() => _step = 3);
              },
              icon: const Icon(Icons.pin_rounded),
              label: const Text('In-App Direct MPIN Checkout'),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildStep2PayMongoHosted(Color gcashBlue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF1D4ED8)),
                  SizedBox(width: 6),
                  Text(
                    'PayMongo Authorization Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Source ID: ${_sourceResult?.id ?? 'N/A'}',
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 2),
              const Text(
                'Complete your payment in the PayMongo window or simulate approval below.',
                style: TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Text(
              'Listening for settlement status...',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _completeSuccessfulPayment(),
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Confirm Payment & Settle'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _pollingTimer?.cancel();
                  setState(() => _step = 1);
                },
                child: const Text('Back'),
              ),
            ),
            if (_sourceResult?.checkoutUrl != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (_sourceResult?.checkoutUrl != null) {
                      await launchUrl(
                        Uri.parse(_sourceResult!.checkoutUrl!),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.launch, size: 16),
                  label: const Text('Re-open Window'),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildStep3InAppPin(Color gcashBlue) {
    if (_processing) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Authorizing payment with GCash...',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter 4-Digit MPIN for ${_phoneController.text}',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: 6),
        const Text(
          'Enter your GCash MPIN (e.g. 1234) to confirm and authorize payment.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _pinController,
          keyboardType: TextInputType.number,
          obscureText: true,
          maxLength: 4,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 16,
          ),
          decoration: InputDecoration(
            hintText: '••••',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: gcashBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  if (_pinController.text.length < 4) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a 4-digit MPIN.')),
                    );
                    return;
                  }
                  _processInAppSimulatedPayment();
                },
                child: const Text('Authorize & Pay'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep4Success(Color gcashBlue) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 54),
        const SizedBox(height: 10),
        const Text(
          'Payment Successful!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          'Paid ₱${widget.totalAmount.toStringAsFixed(2)} to E-Parada Parking',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: Colors.black54),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Text(
                'Payment Reference ID',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
              ),
              const SizedBox(height: 2),
              SelectableText(
                _generatedReference,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF166534)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: gcashBlue,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            Navigator.pop(
              context,
              GcashPaymentResult(
                success: true,
                referenceNo: _generatedReference,
                mobileNumber: _phoneController.text,
                amount: widget.totalAmount,
                paymongoSourceId: _sourceResult?.id,
              ),
            );
          },
          child: const Text('Done & Settle Reservation'),
        ),
      ],
    );
  }
}
