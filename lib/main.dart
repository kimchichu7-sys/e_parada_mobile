import 'package:flutter/material.dart';
import 'app.dart';
import 'config/api_config.dart';
import 'config/app_theme.dart';
import 'services/push_notification_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationHandler.initialize();
  await ApiConfig.loadSavedBaseUrl();
  await AppTheme.loadThemeMode();

  final configurationError = ApiConfig.configurationError;
  runApp(
    configurationError == null
        ? const EParadaApp()
        : _ConfigurationErrorApp(message: configurationError),
  );
}

class _ConfigurationErrorApp extends StatefulWidget {
  const _ConfigurationErrorApp({required this.message});

  final String message;

  @override
  State<_ConfigurationErrorApp> createState() => _ConfigurationErrorAppState();
}

class _ConfigurationErrorAppState extends State<_ConfigurationErrorApp> {
  late final TextEditingController _controller;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ApiConfig.baseUrl.isNotEmpty
          ? ApiConfig.baseUrl
          : 'https://yacht-aka-profit-champions.trycloudflare.com/api',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _applyAndLaunch() async {
    final url = _controller.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await ApiConfig.setCustomBaseUrl(url);
      final error = ApiConfig.configurationError;
      if (error != null) {
        setState(() {
          _isLoading = false;
          _errorMessage = error;
        });
        return;
      }

      if (!mounted) return;
      runApp(const EParadaApp());
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-Parada',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF6FAFF),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/branding/eparada_general.png',
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Connect to E-Parada Server',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF173B64),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter your server backend address or choose a preset below:',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            labelText: 'Backend API URL',
                            hintText: 'https://your-domain.com/api',
                            prefixIcon: const Icon(Icons.link),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            ActionChip(
                              label: const Text('Live Tunnel', style: TextStyle(fontSize: 12)),
                              avatar: const Icon(Icons.cloud, size: 16),
                              onPressed: () {
                                _controller.text =
                                    'https://yacht-aka-profit-champions.trycloudflare.com/api';
                              },
                            ),
                            ActionChip(
                              label: const Text('Wi-Fi LAN', style: TextStyle(fontSize: 12)),
                              avatar: const Icon(Icons.wifi, size: 16),
                              onPressed: () {
                                _controller.text =
                                    'http://192.168.100.205:8000/api';
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _applyAndLaunch,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF173B64),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Save & Connect',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
