import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

enum PayMongoEnvironment {
  sandbox,
  live,
  simulation,
}

class PayMongoSourceResult {
  const PayMongoSourceResult({
    required this.id,
    required this.type,
    required this.amountCentavos,
    required this.currency,
    required this.status,
    this.checkoutUrl,
    this.successUrl,
    this.failedUrl,
    this.isSimulated = false,
    this.rawAttributes = const {},
  });

  final String id;
  final String type;
  final int amountCentavos;
  final String currency;
  final String status;
  final String? checkoutUrl;
  final String? successUrl;
  final String? failedUrl;
  final bool isSimulated;
  final Map<String, dynamic> rawAttributes;

  double get amountPhp => amountCentavos / 100.0;
  bool get isPending => status == 'pending';
  bool get isChargeable => status == 'chargeable';
  bool get isPaid => status == 'paid';
  bool get isExpired => status == 'expired';
  bool get isCancelled => status == 'cancelled';

  factory PayMongoSourceResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map ? json['data'] as Map<String, dynamic> : json;
    final id = data['id']?.toString() ?? '';
    final type = data['type']?.toString() ?? 'source';
    final attrs = data['attributes'] is Map ? data['attributes'] as Map<String, dynamic> : <String, dynamic>{};

    final amountCentavos = (attrs['amount'] as num?)?.toInt() ?? 0;
    final currency = attrs['currency']?.toString() ?? 'PHP';
    final status = attrs['status']?.toString() ?? 'pending';

    final redirect = attrs['redirect'] is Map ? attrs['redirect'] as Map<String, dynamic> : null;
    final checkoutUrl = redirect?['checkout_url']?.toString();
    final successUrl = redirect?['success']?.toString();
    final failedUrl = redirect?['failed']?.toString();

    return PayMongoSourceResult(
      id: id,
      type: type,
      amountCentavos: amountCentavos,
      currency: currency,
      status: status,
      checkoutUrl: checkoutUrl,
      successUrl: successUrl,
      failedUrl: failedUrl,
      isSimulated: false,
      rawAttributes: attrs,
    );
  }
}

class PayMongoService {
  static const String _prefPublicKey = 'paymongo_public_key';
  static const String _prefSecretKey = 'paymongo_secret_key';
  static const String _prefEnvironment = 'paymongo_environment';

  static String? _customPublicKey;
  static String? _customSecretKey;
  static PayMongoEnvironment _environment = PayMongoEnvironment.simulation;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customPublicKey = prefs.getString(_prefPublicKey);
      _customSecretKey = prefs.getString(_prefSecretKey);
      final envStr = prefs.getString(_prefEnvironment);
      if (envStr == 'live') {
        _environment = PayMongoEnvironment.live;
      } else if (envStr == 'sandbox') {
        _environment = PayMongoEnvironment.sandbox;
      } else {
        _environment = PayMongoEnvironment.simulation;
      }
    } catch (_) {}
  }

  static PayMongoEnvironment get environment => _environment;
  static String? get customPublicKey => _customPublicKey;
  static String? get customSecretKey => _customSecretKey;

  static bool get hasCustomKey =>
      _customPublicKey != null && _customPublicKey!.trim().isNotEmpty;

  static String get activePublicKey {
    if (hasCustomKey) {
      return _customPublicKey!.trim();
    }
    return '';
  }

  static bool get isLive => _environment == PayMongoEnvironment.live;
  static bool get isSandbox => _environment == PayMongoEnvironment.sandbox;
  static bool get isSimulation => _environment == PayMongoEnvironment.simulation;

  static Future<void> saveSettings({
    String? publicKey,
    String? secretKey,
    PayMongoEnvironment? environment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (publicKey != null) {
      final cleaned = publicKey.trim();
      _customPublicKey = cleaned.isNotEmpty ? cleaned : null;
      if (cleaned.isNotEmpty) {
        await prefs.setString(_prefPublicKey, cleaned);
      } else {
        await prefs.remove(_prefPublicKey);
      }
    }
    if (secretKey != null) {
      final cleaned = secretKey.trim();
      _customSecretKey = cleaned.isNotEmpty ? cleaned : null;
      if (cleaned.isNotEmpty) {
        await prefs.setString(_prefSecretKey, cleaned);
      } else {
        await prefs.remove(_prefSecretKey);
      }
    }
    if (environment != null) {
      _environment = environment;
      await prefs.setString(_prefEnvironment, environment.name);
    }
  }

  static Map<String, String> _buildHeaders() {
    final key = activePublicKey;
    final encoded = base64Encode(utf8.encode('$key:'));
    return {
      'Authorization': 'Basic $encoded',
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// Creates a GCash Source on PayMongo for the specified PHP amount.
  static Future<PayMongoSourceResult> createGcashSource({
    required double amountPhp,
    required String description,
    String? customerName,
    String? customerPhone,
    String? customerEmail,
    String successUrl = 'https://e-parada.ph/payment-success',
    String failedUrl = 'https://e-parada.ph/payment-failed',
  }) async {
    final amountCentavos = (amountPhp * 100).round();

    // If simulation mode or no custom key configured, return simulation source without launching external URL
    if (_environment == PayMongoEnvironment.simulation || !hasCustomKey) {
      final id = 'src_sim_${DateTime.now().millisecondsSinceEpoch}';
      return PayMongoSourceResult(
        id: id,
        type: 'source',
        amountCentavos: amountCentavos,
        currency: 'PHP',
        status: 'pending',
        checkoutUrl: null,
        successUrl: successUrl,
        failedUrl: failedUrl,
        isSimulated: true,
      );
    }

    final payload = {
      'data': {
        'attributes': {
          'amount': amountCentavos,
          'currency': 'PHP',
          'type': 'gcash',
          'redirect': {
            'success': successUrl,
            'failed': failedUrl,
          },
          'billing': {
            'name': customerName?.trim().isNotEmpty == true ? customerName : 'E-Parada Driver',
            'phone': customerPhone?.trim().isNotEmpty == true ? customerPhone : '09170000000',
            if (customerEmail?.trim().isNotEmpty == true) 'email': customerEmail,
          },
          'metadata': {
            'description': description,
            'platform': 'E-Parada Mobile',
          },
        },
      },
    };

    final response = await http.post(
      Uri.parse('https://api.paymongo.com/v1/sources'),
      headers: _buildHeaders(),
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return PayMongoSourceResult.fromJson(Map<String, dynamic>.from(decoded));
    }

    final errors = decoded['errors'] as List?;
    final detail = errors?.isNotEmpty == true
        ? errors!.first['detail']?.toString()
        : 'Payment gateway rejected the request (HTTP ${response.statusCode})';

    throw Exception(detail ?? 'PayMongo request failed');
  }

  /// Polls the status of a PayMongo source by ID.
  static Future<PayMongoSourceResult> fetchSourceStatus(String sourceId) async {
    if (sourceId.startsWith('src_sim_') || !hasCustomKey) {
      return PayMongoSourceResult(
        id: sourceId,
        type: 'source',
        amountCentavos: 10000,
        currency: 'PHP',
        status: 'chargeable',
        checkoutUrl: null,
        isSimulated: true,
      );
    }

    try {
      final response = await http.get(
        Uri.parse('https://api.paymongo.com/v1/sources/$sourceId'),
        headers: _buildHeaders(),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        return PayMongoSourceResult.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (e) {
      debugPrint('Error polling PayMongo source: $e');
    }

    return PayMongoSourceResult(
      id: sourceId,
      type: 'source',
      amountCentavos: 0,
      currency: 'PHP',
      status: 'pending',
      checkoutUrl: null,
    );
  }
}
