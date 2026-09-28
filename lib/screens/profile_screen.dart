import 'package:flutter/material.dart';

import '../config/app_theme.dart';
import '../models/auth_user.dart';
import '../services/auth_service.dart';
import '../widgets/app_feedback_dialog.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/paymongo_settings_dialog.dart';
import 'incident_report_screen.dart';
import 'vehicle_garage_screen.dart';
import 'support_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<AuthUser?> _future;

  @override
  void initState() {
    super.initState();
    _future = AuthService.fetchMe();
  }

  Future<void> _refresh() async {
    final request = AuthService.fetchMe();
    setState(() {
      _future = request;
    });
    await request;
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (_) => false,
    );
  }

  Future<void> _resendVerification() async {
    try {
      final message = await AuthService.resendVerificationEmail();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh account status',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: FutureBuilder<AuthUser?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _ProfileError(
              message:
                  snapshot.error?.toString() ?? 'Unable to load your profile.',
              onRetry: _refresh,
            );
          }

          final user = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _AccountCard(user: user),
                const SizedBox(height: 16),
                _StatusCard(
                  icon: user.emailVerified
                      ? Icons.mark_email_read_outlined
                      : Icons.mark_email_unread_outlined,
                  title: 'Email verification',
                  value: user.emailVerified ? 'Verified' : 'Action required',
                  approved: user.emailVerified,
                  actionLabel: user.emailVerified ? null : 'Resend email',
                  onAction: user.emailVerified ? null : _resendVerification,
                ),
                const SizedBox(height: 12),
                _StatusCard(
                  icon: Icons.verified_user_outlined,
                  title: 'Account review',
                  value: _verificationLabel(user.verificationStatus),
                  approved: user.verificationStatus == 'approved',
                ),
                if (user.isDriver) ...[
                  const SizedBox(height: 12),
                  _StatusCard(
                    icon: Icons.directions_car_outlined,
                    title: 'Approved vehicle',
                    value: user.hasApprovedVehicle
                        ? 'Available for reservations'
                        : 'Waiting for approval',
                    approved: user.hasApprovedVehicle,
                  ),
                  const SizedBox(height: 18),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.garage_outlined),
                      title: const Text(
                        'My vehicles',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${user.remainingVehicleSlots} of 3 registration slots remaining',
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VehicleGarageScreen(),
                          ),
                        );
                        if (mounted) await _refresh();
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _PermissionCard(
                    enabled: user.canReserve,
                    enabledTitle: 'Ready to reserve',
                    disabledTitle: 'Reservation access locked',
                    enabledText:
                        'Your account and vehicle meet the reservation requirements.',
                    disabledText:
                        'Verify your email and wait for account and vehicle approval.',
                  ),
                ] else if (user.isParkingOwner) ...[
                  const SizedBox(height: 18),
                  _PermissionCard(
                    enabled: user.canManageParkingSpaces,
                    enabledTitle: 'Parking management active',
                    disabledTitle: 'Parking management locked',
                    enabledText:
                        'Your parking owner account is ready to manage spaces.',
                    disabledText:
                        'Verify your email and wait for administrator approval.',
                  ),
                ] else ...[
                  const SizedBox(height: 18),
                  const _PermissionCard(
                    enabled: true,
                    enabledTitle: 'Administrator access active',
                    disabledTitle: 'Administrator access unavailable',
                    enabledText:
                        'Your account can review E-Parada platform activity.',
                    disabledText: '',
                  ),
                ],
                const SizedBox(height: 20),
                Card(
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: AppTheme.themeNotifier,
                    builder: (context, currentMode, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              currentMode == ThemeMode.dark
                                  ? Icons.dark_mode_rounded
                                  : (currentMode == ThemeMode.light
                                      ? Icons.light_mode_rounded
                                      : Icons.brightness_auto_rounded),
                              color: Theme.of(context).colorScheme.primary,
                              size: 24,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Appearance',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    currentMode == ThemeMode.dark
                                        ? 'Dark Mode'
                                        : (currentMode == ThemeMode.light
                                            ? 'Light Mode'
                                            : 'System Default'),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            SegmentedButton<ThemeMode>(
                              showSelectedIcon: false,
                              style: const ButtonStyle(
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_outlined, size: 16),
                                  tooltip: 'Light Mode',
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_outlined, size: 16),
                                  tooltip: 'Dark Mode',
                                ),
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto_outlined, size: 16),
                                  tooltip: 'System Default',
                                ),
                              ],
                              selected: {currentMode},
                              onSelectionChanged: (selected) {
                                if (selected.isNotEmpty) {
                                  AppTheme.setThemeMode(selected.first);
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.account_balance_wallet_outlined,
                      color: Color(0xFF005CE6),
                    ),
                    title: const Text(
                      'GCash Payment Gateway',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Configure PayMongo API keys, Sandbox/Live modes, and test connection',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => PaymongoSettingsDialog.show(context),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.report_problem_outlined),
                    title: const Text(
                      'Submit Incident Report',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Report property damage, spatial mismatch, overcharging, or bugs',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const IncidentReportScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.rate_review_outlined),
                    title: const Text(
                      'Rate E-Parada App',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Share your feedback and rating to improve platform experience',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => AppFeedbackDialog.show(context),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: const Text(
                      'Help & FAQs',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: const Text(
                      'Verification, reservations, QR backup, payments, and privacy',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SupportScreen()),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.error.withValues(alpha: 0.35),
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.delete_forever_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      'Delete Account',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    subtitle: const Text(
                      'Permanently remove your account and all associated personal data',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => DeleteAccountDialog.show(
                      context,
                      userEmail: user.email,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Log out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _verificationLabel(String status) {
    return switch (status) {
      'approved' => 'Approved',
      'rejected' => 'Rejected - contact E-Parada support',
      _ => 'Pending administrator review',
    };
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              child: const Icon(Icons.person, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(user.email),
                  const SizedBox(height: 10),
                  Text(
                    '${user.roleLabel} account',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.approved,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool approved;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final color = approved ? Colors.green : Colors.amber.shade800;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(value),
        trailing: actionLabel == null
            ? Icon(approved ? Icons.check_circle : Icons.schedule, color: color)
            : TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  const _PermissionCard({
    required this.enabled,
    required this.enabledTitle,
    required this.disabledTitle,
    required this.enabledText,
    required this.disabledText,
  });

  final bool enabled;
  final String enabledTitle;
  final String disabledTitle;
  final String enabledText;
  final String disabledText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          enabled ? Icons.check_circle_outline : Icons.info_outline,
        ),
        title: Text(
          enabled ? enabledTitle : disabledTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(enabled ? enabledText : disabledText),
      ),
    );
  }
}

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ),
      ),
    );
  }
}
