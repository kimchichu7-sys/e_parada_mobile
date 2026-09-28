import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/wallet_service.dart';
import 'gcash_payment_gateway_dialog.dart';

class DriverWalletDialog extends StatefulWidget {
  const DriverWalletDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => const DriverWalletDialog(),
    );
  }

  @override
  State<DriverWalletDialog> createState() => _DriverWalletDialogState();
}

class _DriverWalletDialogState extends State<DriverWalletDialog> {
  final List<double> _presetAmounts = [100.0, 300.0, 500.0, 1000.0];
  double _selectedAmount = 300.0;
  String _selectedMethod = 'GCash';
  bool _isCustomAmount = false;
  final TextEditingController _customAmountController = TextEditingController();
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WalletService.init();
  }

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  Future<void> _handleTopUp() async {
    final amount = _isCustomAmount
        ? double.tryParse(_customAmountController.text.trim()) ?? 0.0
        : _selectedAmount;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount greater than ₱0'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _processing = true);

    try {
      if (_selectedMethod == 'GCash') {
        final gcashResult = await GcashPaymentGatewayDialog.show(
          context: context,
          parkingSpaceName: 'E-Parada Digital Wallet Top-up',
          reservationReference: 'TOPUP-${DateTime.now().millisecondsSinceEpoch % 1000000}',
          totalAmount: amount,
        );

        if (gcashResult == null || !gcashResult.success) {
          if (mounted) setState(() => _processing = false);
          return;
        }
      } else {
        await Future.delayed(const Duration(milliseconds: 600));
      }

      await WalletService.topUp(
        amount: amount,
        method: _selectedMethod,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade700,
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text('Successfully loaded ₱${amount.toStringAsFixed(2)} to your wallet!'),
            ],
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppPalette.yaleBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppPalette.yaleBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'E-Parada Wallet',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'Instant 1-tap parking checkout',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Balance Card
                      ValueListenableBuilder<double>(
                        valueListenable: WalletService.balanceNotifier,
                        builder: (context, balance, _) {
                          return Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppPalette.yaleBlue, Color(0xFF224E82)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppPalette.yaleBlue.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Available Balance',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppPalette.naplesYellow,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'ACTIVE',
                                        style: TextStyle(
                                          color: AppPalette.yaleBlue,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '₱${balance.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Linked to your E-Parada Driver ID',
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      // Top-Up Section
                      Text(
                        'Top-Up Balance',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Preset Amount Chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ..._presetAmounts.map((amount) {
                            final isSelected = !_isCustomAmount && _selectedAmount == amount;
                            return ChoiceChip(
                              label: Text('₱${amount.toInt()}'),
                              selected: isSelected,
                              selectedColor: AppPalette.yaleBlue,
                              labelStyle: TextStyle(
                                color: isSelected ? Colors.white : colors.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                              onSelected: (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedAmount = amount;
                                    _isCustomAmount = false;
                                  });
                                }
                              },
                            );
                          }),
                          ChoiceChip(
                            label: const Text('Custom'),
                            selected: _isCustomAmount,
                            selectedColor: AppPalette.yaleBlue,
                            labelStyle: TextStyle(
                              color: _isCustomAmount ? Colors.white : colors.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                            onSelected: (selected) {
                              setState(() => _isCustomAmount = selected);
                            },
                          ),
                        ],
                      ),

                      if (_isCustomAmount) ...[
                        const SizedBox(height: 8),
                        TextField(
                          controller: _customAmountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Enter amount (₱)',
                            prefixText: '₱ ',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),

                      // Method Selector
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.account_balance_wallet_rounded, size: 18),
                              label: const Text('GCash'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _selectedMethod == 'GCash'
                                      ? AppPalette.yaleBlue
                                      : colors.outlineVariant,
                                  width: _selectedMethod == 'GCash' ? 2 : 1,
                                ),
                                backgroundColor: _selectedMethod == 'GCash'
                                    ? AppPalette.yaleBlue.withValues(alpha: 0.08)
                                    : null,
                              ),
                              onPressed: () => setState(() => _selectedMethod = 'GCash'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.credit_card_rounded, size: 18),
                              label: const Text('Maya'),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _selectedMethod == 'Maya'
                                      ? AppPalette.yaleBlue
                                      : colors.outlineVariant,
                                  width: _selectedMethod == 'Maya' ? 2 : 1,
                                ),
                                backgroundColor: _selectedMethod == 'Maya'
                                    ? AppPalette.yaleBlue.withValues(alpha: 0.08)
                                    : null,
                              ),
                              onPressed: () => setState(() => _selectedMethod = 'Maya'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Submit Top-Up
                      FilledButton.icon(
                        icon: _processing
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.add_card_rounded),
                        label: Text(
                          _processing
                              ? 'Processing...'
                              : 'Load ₱${_isCustomAmount ? (_customAmountController.text.isEmpty ? '0.00' : _customAmountController.text) : _selectedAmount.toStringAsFixed(2)} Now',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.yaleBlue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _processing ? null : _handleTopUp,
                      ),
                      const SizedBox(height: 20),

                      // Transactions List
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Recent Transactions',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Text(
                            'Last 50 records',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      ValueListenableBuilder<List<WalletTransaction>>(
                        valueListenable: WalletService.transactionsNotifier,
                        builder: (context, list, _) {
                          if (list.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Center(
                                child: Text(
                                  'No transactions yet',
                                  style: TextStyle(color: colors.onSurfaceVariant),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: list.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final tx = list[index];
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundColor: tx.isPositive
                                      ? Colors.green.shade50
                                      : Colors.red.shade50,
                                  child: Icon(
                                    tx.isPositive
                                        ? Icons.arrow_downward_rounded
                                        : Icons.arrow_upward_rounded,
                                    size: 16,
                                    color: tx.isPositive
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                  ),
                                ),
                                title: Text(
                                  tx.description,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                                subtitle: Text(
                                  '${tx.reference} • ${_formatDate(tx.timestamp)}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Text(
                                  '${tx.isPositive ? '+' : '-'}₱${tx.amount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: tx.isPositive
                                        ? Colors.green.shade700
                                        : Colors.red.shade700,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
