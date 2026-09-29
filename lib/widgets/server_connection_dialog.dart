import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../services/api_service.dart';

class ServerConnectionDialog extends StatefulWidget {
  const ServerConnectionDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (_) => const ServerConnectionDialog(),
    );
  }

  @override
  State<ServerConnectionDialog> createState() => _ServerConnectionDialogState();
}

class _ServerConnectionDialogState extends State<ServerConnectionDialog> {
  late final TextEditingController _urlController;
  bool _isTesting = false;
  String? _testResult;
  bool _testSuccess = false;

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: ApiConfig.baseUrl);
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _testConnection() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    try {
      // Temporarily apply for test
      await ApiConfig.setCustomBaseUrl(url);
      await ApiService.fetchParkingSpaces();
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testSuccess = true;
        _testResult = 'Connected successfully to E-Parada server!';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTesting = false;
        _testSuccess = false;
        _testResult = 'Cannot reach server: $e';
      });
    }
  }

  Future<void> _saveAndApply() async {
    final url = _urlController.text.trim();
    await ApiConfig.setCustomBaseUrl(url.isEmpty ? null : url);
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _resetToDefault() async {
    await ApiConfig.setCustomBaseUrl(null);
    if (!mounted) return;
    setState(() {
      _urlController.text = ApiConfig.baseUrl;
      _testResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.dns_outlined),
          SizedBox(width: 10),
          Text('Server Address', style: TextStyle(fontSize: 18)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configure the backend API endpoint to test locally or remotely across networks:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'API Base URL',
                hintText: 'https://your-tunnel.trycloudflare.com/api',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh, size: 20),
                  tooltip: 'Reset to default',
                  onPressed: _resetToDefault,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Quick Presets:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.cloud_done, size: 14, color: Color(0xFF10B981)),
                  label: const Text('Live Cloud (Render)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  onPressed: () => setState(() => _urlController.text = 'https://e-parada.onrender.com/api'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.phone_android, size: 14),
                  label: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 11)),
                  onPressed: () => setState(() => _urlController.text = 'http://10.0.2.2:8000/api'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.computer, size: 14),
                  label: const Text('Localhost (127.0.0.1)', style: TextStyle(fontSize: 11)),
                  onPressed: () => setState(() => _urlController.text = 'http://127.0.0.1:8000/api'),
                ),
                ActionChip(
                  avatar: const Icon(Icons.cloud_outlined, size: 14),
                  label: const Text('Cloudflare Tunnel', style: TextStyle(fontSize: 11)),
                  onPressed: () => setState(() {
                    if (!_urlController.text.contains('trycloudflare.com')) {
                      _urlController.text = 'https://demo-eparada.trycloudflare.com/api';
                    }
                  }),
                ),
                ActionChip(
                  avatar: const Icon(Icons.public, size: 14),
                  label: const Text('Ngrok Tunnel', style: TextStyle(fontSize: 11)),
                  onPressed: () => setState(() {
                    if (!_urlController.text.contains('ngrok-free.app')) {
                      _urlController.text = 'https://demo-eparada.ngrok-free.app/api';
                    }
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colors.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Tip: Run `cloudflared tunnel --url http://127.0.0.1:8000` to test from any device on mobile data anywhere in the Philippines.',
                style: TextStyle(fontSize: 11),
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _testSuccess ? Colors.green.shade50 : colors.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _testResult!,
                  style: TextStyle(
                    fontSize: 12,
                    color: _testSuccess ? Colors.green.shade900 : colors.onErrorContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isTesting ? null : _testConnection,
          child: _isTesting
              ? const SizedBox.square(dimension: 14, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Test Connection'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saveAndApply,
          child: const Text('Save & Apply'),
        ),
      ],
    );
  }
}
