import 'package:flutter/material.dart';
import '../services/paymongo_service.dart';

class PaymongoSettingsDialog extends StatefulWidget {
  const PaymongoSettingsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (_) => const PaymongoSettingsDialog(),
    );
  }

  @override
  State<PaymongoSettingsDialog> createState() => _PaymongoSettingsDialogState();
}

class _PaymongoSettingsDialogState extends State<PaymongoSettingsDialog> {
  late PayMongoEnvironment _environment;
  late final TextEditingController _publicKeyController;
  late final TextEditingController _secretKeyController;
  bool _testingConnection = false;
  String? _testMessage;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _environment = PayMongoService.environment;
    _publicKeyController = TextEditingController(
      text: PayMongoService.customPublicKey ?? '',
    );
    _secretKeyController = TextEditingController(
      text: PayMongoService.customSecretKey ?? '',
    );
  }

  @override
  void dispose() {
    _publicKeyController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  Future<void> _testGateway() async {
    setState(() {
      _testingConnection = true;
      _testMessage = null;
    });

    try {
      final source = await PayMongoService.createGcashSource(
        amountPhp: 20.0,
        description: 'E-Parada Gateway Connection Preflight Test',
      );

      if (!mounted) return;
      setState(() {
        _testingConnection = false;
        _testSuccess = true;
        _testMessage = 'Connection Successful! (Source ID: ${source.id})';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _testingConnection = false;
        _testSuccess = false;
        _testMessage = 'Gateway Test Failed: $e';
      });
    }
  }

  Future<void> _save() async {
    await PayMongoService.saveSettings(
      environment: _environment,
      publicKey: _publicKeyController.text,
      secretKey: _secretKeyController.text,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment gateway configuration saved.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF005CE6)),
          SizedBox(width: 10),
          Expanded(child: Text('GCash Payment Gateway')),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gateway Environment',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 8),
              SegmentedButton<PayMongoEnvironment>(
                segments: const [
                  ButtonSegment(
                    value: PayMongoEnvironment.sandbox,
                    label: Text('Sandbox'),
                    icon: Icon(Icons.science_outlined),
                  ),
                  ButtonSegment(
                    value: PayMongoEnvironment.live,
                    label: Text('Live'),
                    icon: Icon(Icons.flash_on_rounded),
                  ),
                  ButtonSegment(
                    value: PayMongoEnvironment.simulation,
                    label: Text('Simulated'),
                    icon: Icon(Icons.smartphone_rounded),
                  ),
                ],
                selected: {_environment},
                onSelectionChanged: (selected) {
                  setState(() => _environment = selected.first);
                },
              ),
              const SizedBox(height: 14),
              const Text(
                'PayMongo Public Key (Optional override)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _publicKeyController,
                decoration: InputDecoration(
                  hintText: 'pk_test_... or pk_live_...',
                  helperText: 'Leave empty to use default Sandbox credentials',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  prefixIcon: const Icon(Icons.key_rounded),
                ),
              ),
              const SizedBox(height: 14),
              if (_testMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _testSuccess ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _testSuccess ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                        color: _testSuccess ? const Color(0xFF166534) : colors.error,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _testMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _testSuccess ? const Color(0xFF166534) : colors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _testingConnection ? null : _testGateway,
                  icon: _testingConnection
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.network_check_rounded),
                  label: Text(_testingConnection ? 'Testing Gateway...' : 'Test PayMongo API Connection'),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _save,
          child: const Text('Save Settings'),
        ),
      ],
    );
  }
}
