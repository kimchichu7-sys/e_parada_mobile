import 'package:flutter/material.dart';

import '../models/auth_user.dart';
import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';
import '../widgets/dashboard_analytics_charts.dart';
import '../widgets/notification_action_button.dart';
import '../widgets/eparada_logo.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, required this.user});

  final AuthUser user;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late Future<DashboardSummary> _future;

  @override
  void initState() {
    super.initState();
    _future = DashboardService.fetchSummary();
  }

  Future<void> _refresh() async {
    final request = DashboardService.fetchSummary();
    setState(() {
      _future = request;
    });
    await request;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-Parada'),
        actions: [const NotificationActionButton()],
      ),
      body: FutureBuilder<DashboardSummary>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || snapshot.data == null) {
            return _DashboardError(
              message:
                  snapshot.error?.toString() ?? 'Unable to load dashboard.',
              onRetry: _refresh,
            );
          }

          final summary = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                _RoleHeader(user: widget.user, summary: summary),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: summary.metrics.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 300,
                    mainAxisExtent: 138,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, index) =>
                      _MetricCard(metric: summary.metrics[index]),
                ),
                if (widget.user.isParkingOwner || widget.user.isAdmin) ...[
                  const SizedBox(height: 20),
                  DashboardAnalyticsCharts(
                    summary: summary,
                    isOwnerOrAdmin: true,
                  ),
                ],
                const SizedBox(height: 20),
                _AccessCard(user: widget.user),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RoleHeader extends StatelessWidget {
  const _RoleHeader({required this.user, required this.summary});

  final AuthUser user;
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EParadaLogo.forUser(user, size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.title,
                  style: TextStyle(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary.subtitle,
                  style: TextStyle(color: colors.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(_metricIcon(metric.key), color: colors.primary),
            Text(
              '${metric.value}',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            Text(
              metric.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  static IconData _metricIcon(String key) {
    if (key.contains('vehicle')) return Icons.directions_car_outlined;
    if (key.contains('user')) return Icons.people_outline;
    if (key.contains('payment')) return Icons.payments_outlined;
    if (key.contains('space')) return Icons.local_parking_outlined;
    if (key.contains('reservation')) return Icons.event_note_outlined;
    return Icons.insights_outlined;
  }
}

class _AccessCard extends StatelessWidget {
  const _AccessCard({required this.user});

  final AuthUser user;

  @override
  Widget build(BuildContext context) {
    final approved =
        user.emailVerified &&
        user.verificationStatus == 'approved' &&
        (!user.isDriver || user.hasApprovedVehicle);

    return Card(
      child: ListTile(
        leading: Icon(
          approved ? Icons.verified_user_outlined : Icons.schedule_outlined,
          color: approved ? Colors.green : Colors.amber.shade800,
        ),
        title: Text(
          approved ? 'Account ready' : 'Verification in progress',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          approved
              ? '${user.roleLabel} access is active.'
              : 'Verify your email and wait for administrator approval.',
        ),
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message, required this.onRetry});

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
            const Icon(Icons.cloud_off_outlined, size: 52),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
