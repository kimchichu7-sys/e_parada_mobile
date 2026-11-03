import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../services/auth_service.dart';

class TermsAndConditionsDialog extends StatefulWidget {
  const TermsAndConditionsDialog({super.key});

  static bool _isShowing = false;

  static Future<AuthUser?> show(BuildContext context) async {
    if (_isShowing) return null;
    _isShowing = true;
    try {
      return await showDialog<AuthUser>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const TermsAndConditionsDialog(),
      );
    } finally {
      _isShowing = false;
    }
  }

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  bool _agreed = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _submitAgreement() async {
    if (!_agreed || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final updatedUser = await AuthService.acceptTerms();
      if (!mounted) return;
      Navigator.of(context).pop(updatedUser);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'Could not save your agreement right now. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 8,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 680),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF173B64), Color(0xFF23538A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDE70).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: const Color(0xFFFFDE70).withValues(alpha: 0.4),
                            ),
                          ),
                          child: const Icon(
                            Icons.verified_user_rounded,
                            color: Color(0xFFFFDE70),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.22),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: const Text(
                                  'EMAIL VERIFIED • NEW ACCOUNT',
                                  style: TextStyle(
                                    color: Color(0xFF6EE7B7),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Terms and Conditions',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Welcome to E-Parada! Now that your email address has been verified, please read and agree to our Terms and Conditions below to continue.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Terms Body
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTermSection(
                        context,
                        title: '1. Marketplace Role & Account Responsibility',
                        body:
                            'E-Parada connects verified drivers, vehicle owners, and local parking space providers in Calamba City. Parking providers remain responsible for their property, operating hours, posted rates, space condition, and lawful handling of vehicles on their premises. Users are responsible for maintaining accurate account, identity, vehicle, and reservation details at all times.',
                      ),
                      const SizedBox(height: 12),
                      _buildTermSection(
                        context,
                        title: '2. Identity & Document Verification',
                        body:
                            '• Users must submit authentic documents matching their chosen registration role (Driver\'s License, Government ID, OR/CR, or Property Clearances).\n'
                            '• Submitting falsified identities, tampered plates, invalid OR/CR documents, or fraudulent payment proofs will result in immediate account suspension.\n'
                            '• Drivers must park only the approved vehicle in the assigned parking slot during the confirmed schedule.',
                      ),
                      const SizedBox(height: 12),
                      _buildTermSection(
                        context,
                        title: '3. Reservations & Mandatory 1-Hour Downpayment',
                        body:
                            'Once a parking provider approves your reservation, paying the mandatory 1-hour downpayment via GCash / PayMongo is required to lock in the bay and unlock your QR Gate Pass for checkpoint entry. Any remaining balance (for multi-hour bookings or approved extensions) is settled prior to or upon checkout.',
                        highlight: true,
                      ),
                      const SizedBox(height: 12),
                      _buildTermSection(
                        context,
                        title: '4. Overstaying, Grace Period & Unattended Vehicles',
                        body:
                            'If a vehicle remains parked after the reservation end time beyond the provider\'s grace period, E-Parada automatically applies the posted overstay penalty rate and notifies both parties. Vehicles left unattended beyond the provider\'s maximum threshold may be escalated to local barangay or traffic authorities in accordance with local ordinances.',
                      ),
                      const SizedBox(height: 12),
                      _buildTermSection(
                        context,
                        title: '5. Cancellations, Disputes & Data Privacy (RA 10173)',
                        body:
                            'Personal data and verification documents are processed strictly for identity verification, reservation security, and audit compliance under the Data Privacy Act of 2012 (RA 10173). Administrators reserve the right to restrict or suspend accounts that violate platform safety, privacy, or anti-fraud rules.',
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Checkbox + Button
              Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0D1E36)
                      : const Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: colors.error,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => setState(() => _agreed = !_agreed),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _agreed
                              ? colors.primary.withValues(alpha: 0.08)
                              : (isDark
                                    ? const Color(0xFF122744)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: _agreed
                                ? colors.primary
                                : colors.outlineVariant,
                            width: _agreed ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: _agreed,
                              onChanged: (val) =>
                                  setState(() => _agreed = val ?? false),
                              visualDensity: VisualDensity.compact,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'I have read and agreed to the Terms and Conditions and Privacy Policy of E-Parada.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilledButton.icon(
                      onPressed:
                          (_agreed && !_isSubmitting) ? _submitAgreement : null,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check_circle_outline_rounded),
                      label: Text(
                        _isSubmitting
                            ? 'Saving Agreement...'
                            : 'I Agree & Continue',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermSection(
    BuildContext context, {
    required String title,
    required String body,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlight
            ? (isDark
                  ? const Color(0xFF78350F).withValues(alpha: 0.25)
                  : const Color(0xFFFFFBEB))
            : (isDark
                  ? Colors.white.withValues(alpha: 0.04)
                  : const Color(0xFFF8FAFC)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlight
              ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
              : theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.45,
              fontSize: 12.5,
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

