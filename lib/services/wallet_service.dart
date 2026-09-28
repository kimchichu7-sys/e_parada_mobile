import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum WalletTransactionType {
  topUp,
  payment,
  refund,
  surcharge;

  String get label {
    switch (this) {
      case WalletTransactionType.topUp:
        return 'Top-up';
      case WalletTransactionType.payment:
        return 'Parking Payment';
      case WalletTransactionType.refund:
        return 'Refund';
      case WalletTransactionType.surcharge:
        return 'Overstay Surcharge';
    }
  }
}

class WalletTransaction {
  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.type,
    required this.description,
    required this.reference,
    required this.timestamp,
  });

  final String id;
  final double amount;
  final WalletTransactionType type;
  final String description;
  final String reference;
  final DateTime timestamp;

  bool get isPositive =>
      type == WalletTransactionType.topUp || type == WalletTransactionType.refund;

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'type': type.name,
    'description': description,
    'reference': reference,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as String? ?? 'TX-${DateTime.now().millisecondsSinceEpoch}',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: WalletTransactionType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => WalletTransactionType.payment,
      ),
      description: json['description'] as String? ?? 'Transaction',
      reference: json['reference'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class WalletService {
  static const String _balanceKey = 'driver_wallet_balance';
  static const String _txKey = 'driver_wallet_transactions';

  static final ValueNotifier<double> balanceNotifier = ValueNotifier<double>(500.0);
  static final ValueNotifier<List<WalletTransaction>> transactionsNotifier =
      ValueNotifier<List<WalletTransaction>>([]);

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBalance = prefs.getDouble(_balanceKey);
      if (savedBalance != null) {
        balanceNotifier.value = savedBalance;
      } else {
        // Initial welcome wallet bonus
        balanceNotifier.value = 500.0;
        await prefs.setDouble(_balanceKey, 500.0);
      }

      final savedTxRaw = prefs.getStringList(_txKey);
      if (savedTxRaw != null && savedTxRaw.isNotEmpty) {
        transactionsNotifier.value = savedTxRaw
            .map((raw) {
              try {
                return WalletTransaction.fromJson(
                  Map<String, dynamic>.from(jsonDecode(raw) as Map),
                );
              } catch (_) {
                return null;
              }
            })
            .whereType<WalletTransaction>()
            .toList();
      } else {
        final initialTx = WalletTransaction(
          id: 'TX-INIT-${DateTime.now().millisecondsSinceEpoch}',
          amount: 500.0,
          type: WalletTransactionType.topUp,
          description: 'Welcome Driver Wallet Bonus',
          reference: 'PROMO-EPARADA',
          timestamp: DateTime.now(),
        );
        transactionsNotifier.value = [initialTx];
        await _saveTransactions(prefs, transactionsNotifier.value);
      }
      _initialized = true;
    } catch (_) {
      _initialized = true;
    }
  }

  static Future<double> getBalance() async {
    await init();
    return balanceNotifier.value;
  }

  static Future<bool> topUp({
    required double amount,
    required String method,
    String? reference,
  }) async {
    if (amount <= 0) return false;
    await init();

    final prefs = await SharedPreferences.getInstance();
    final newBalance = balanceNotifier.value + amount;
    balanceNotifier.value = newBalance;
    await prefs.setDouble(_balanceKey, newBalance);

    final tx = WalletTransaction(
      id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: WalletTransactionType.topUp,
      description: 'Top-up via $method',
      reference: reference ?? 'TOPUP-${DateTime.now().millisecondsSinceEpoch % 1000000}',
      timestamp: DateTime.now(),
    );

    final updatedTx = [tx, ...transactionsNotifier.value];
    transactionsNotifier.value = updatedTx;
    await _saveTransactions(prefs, updatedTx);
    return true;
  }

  static Future<bool> deduct({
    required double amount,
    required String description,
    required String reference,
    WalletTransactionType type = WalletTransactionType.payment,
  }) async {
    if (amount <= 0) return false;
    await init();

    if (balanceNotifier.value < amount) {
      return false; // Insufficient balance
    }

    final prefs = await SharedPreferences.getInstance();
    final newBalance = balanceNotifier.value - amount;
    balanceNotifier.value = newBalance;
    await prefs.setDouble(_balanceKey, newBalance);

    final tx = WalletTransaction(
      id: 'TX-${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      type: type,
      description: description,
      reference: reference,
      timestamp: DateTime.now(),
    );

    final updatedTx = [tx, ...transactionsNotifier.value];
    transactionsNotifier.value = updatedTx;
    await _saveTransactions(prefs, updatedTx);
    return true;
  }

  static Future<void> resetForTest() async {
    _initialized = false;
    balanceNotifier.value = 500.0;
    transactionsNotifier.value = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_balanceKey);
      await prefs.remove(_txKey);
    } catch (_) {}
  }

  static Future<void> _saveTransactions(
    SharedPreferences prefs,
    List<WalletTransaction> list,
  ) async {
    try {
      final encoded = list.take(50).map((t) => jsonEncode(t.toJson())).toList();
      await prefs.setStringList(_txKey, encoded);
    } catch (_) {}
  }
}
