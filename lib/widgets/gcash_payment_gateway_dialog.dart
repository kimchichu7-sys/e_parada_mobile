import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/paymongo_service.dart';
import '../services/reservation_service.dart';

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
    this.reservationId,
  });

  final String parkingSpaceName;
  final String reservationReference;
  final double totalAmount;
  final String initialMobileNumber;
  final int? reservationId;

  static Future<GcashPaymentResult?> show({
    required BuildContext context,
    required String parkingSpaceName,
    required String reservationReference,
    required double totalAmount,
    String initialMobileNumber = '',
    int? reservationId,
  }) {
    return showDialog<GcashPaymentResult>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => GcashPaymentGatewayDialog(
        parkingSpaceName: parkingSpaceName,
        reservationReference: reservationReference,
        totalAmount: totalAmount,
        initialMobileNumber: initialMobileNumber,
        reservationId: reservationId,
      ),
    );
  }

  @override
  State<GcashPaymentGatewayDialog> createState() =>
      _GcashPaymentGatewayDialogState();
}

class _GcashPaymentGatewayDialogState extends State<GcashPaymentGatewayDialog> {
  int _step = 1; // 1: Choose / Initiate, 2: PayMongo Window Active, 3: In-App MPIN Simulator, 4: Success
  late final TextEditingController _phoneController;
  final TextEditingController _pinController = TextEditingController();
  bool _processing = false;
  String _generatedReference = '';
  String? _checkoutUrl;
  bool _isLiveGateway = false;

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
    setState(() => _processing = true);

    try {
      if (widget.reservationId != null) {
        // Backend creates official PayMongo checkout session like website
        final session = await ReservationService.createCheckoutSession(widget.reservationId!);
        final checkoutUrl = session['checkout_url']?.toString();
        _isLiveGateway = session['is_live'] == true;

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          _checkoutUrl = checkoutUrl;
          final uri = Uri.parse(checkoutUrl);
          await launchUrl(
            uri,
            mode: kIsWeb ? LaunchMode.platformDefault : LaunchMode.externalApplication,
            webOnlyWindowName: '_blank',
          );
        }

        if (!mounted) return;
        setState(() {
          _step = 2;
          _processing = false;
        });
        return;
      }

      // If reservationId is null (e.g. Wallet top-up), use direct interactive simulation
      if (!mounted) return;
      setState(() {
        _processing = false;
        _step = 3;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start PayMongo checkout: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _completeSuccessfulPayment({String? referenceId}) {
    final ref = referenceId ?? _generateGcashRef();
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
                          'GCash / PayMongo Gateway',
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
                                _isLiveGateway ? 'PayMongo Live' : 'PayMongo / GCash',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'E-Parada',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_step != 4)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
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
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Reservation: ${widget.reservationReference}',
                          style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                1 => _buildStep1Select(gcashBlue),
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

  Widget _buildStep1Select(Color gcashBlue) {
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
            icon: const Icon(Icons.open_in_browser_rounded),
            label: Text('Pay via PayMongo / GCash (₱${widget.totalAmount.toStringAsFixed(2)})'),
          ),
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
            label: const Text('Quick In-App GCash Simulation'),
          ),
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
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFF1D4ED8)),
                  SizedBox(width: 6),
                  Text(
                    'PayMongo Checkout Window Active',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF1D4ED8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6),
              Text(
                'Complete your payment in the PayMongo window opened in your browser.',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
              SizedBox(height: 4),
              Text(
                'Once your payment is authorized, return here and tap "I Have Completed Payment".',
                style: TextStyle(fontSize: 12, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16A34A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          onPressed: () => _completeSuccessfulPayment(
            referenceId: 'PAYMONGO-GCASH-${DateTime.now().millisecondsSinceEpoch % 1000000}',
          ),
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('I Have Completed Payment'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step = 1),
                child: const Text('Back'),
              ),
            ),
            if (_checkoutUrl != null) ...[
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (_checkoutUrl != null) {
                      await launchUrl(
                        Uri.parse(_checkoutUrl!),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  icon: const Icon(Icons.launch, size: 16),
                  label: const Text('Re-open Link'),
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
          'Enter your GCash MPIN (e.g. 1234) to authorize payment.',
          style: TextStyle(fontSize: 14, color: Colors.black54),
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
          style: const TextStyle(fontSize: 14, color: Colors.black54),
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
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF166534)),
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
              ),
            );
          },
          child: const Text('Done & Settle Reservation'),
        ),
      ],
    );
  }
}
