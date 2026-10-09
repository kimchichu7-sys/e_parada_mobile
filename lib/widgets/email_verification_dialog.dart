import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class EmailVerificationDialog extends StatefulWidget {
  const EmailVerificationDialog({
    super.key,
    required this.email,
  });

  final String email;

  static Future<void> show(
    BuildContext context, {
    required String email,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => EmailVerificationDialog(email: email),
    );
  }

  @override
  State<EmailVerificationDialog> createState() =>
      _EmailVerificationDialogState();
}

class _EmailVerificationDialogState extends State<EmailVerificationDialog> {
  bool _isResending = false;
  String? _statusMessage;
  bool _isSuccess = false;

  Future<void> _resendVerification() async {
    setState(() {
      _isResending = true;
      _statusMessage = null;
    });

    try {
      final message = await AuthService.resendVerificationEmail();
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _isSuccess = true;
        _statusMessage = message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isResending = false;
        _isSuccess = false;
        _statusMessage = 'Could not send verification email. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      elevation: 6,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mail Icon Header
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.mark_email_unread_outlined,
                size: 34,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 18),

            // Dialog Title
            Text(
              'Verify Your Email',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),

            // Intro text
            Text(
              'We sent a verification link to your email address:',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Highlighted email badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.email_outlined, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.email,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                        fontSize: 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Text(
              'Please check your inbox or spam folder to activate your account. You can also verify anytime from your Profile screen.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
                height: 1.35,
              ),
              textAlign: TextAlign.center,
            ),

            if (_statusMessage != null) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                      : colors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isSuccess
                          ? Icons.check_circle_outline_rounded
                          : Icons.error_outline_rounded,
                      size: 16,
                      color: _isSuccess
                          ? const Color(0xFF059669)
                          : colors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _statusMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _isSuccess
                              ? const Color(0xFF059669)
                              : colors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Resend action
            TextButton.icon(
              onPressed: _isResending ? null : _resendVerification,
              icon: _isResending
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded, size: 16),
              label: Text(
                _isResending ? 'Sending...' : 'Resend verification email',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),

            const SizedBox(height: 12),

            // Primary action: Continue to App
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue to App',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 6),

            // Secondary / Skip action
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Skip for now',
                  style: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
