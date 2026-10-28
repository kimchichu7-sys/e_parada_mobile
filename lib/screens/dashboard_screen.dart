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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color appBarBg = widget.user.isAdmin
        ? (isDark ? const Color(0xFF0F264A) : const Color(0xFF0B1E36))
        : (widget.user.isParkingOwner
            ? (isDark ? const Color(0xFF09261B) : const Color(0xFF062D22))
            : (isDark ? const Color(0xFF0B1E36) : const Color(0xFF102B4B)));

    final Color accentBorder = widget.user.isAdmin
        ? const Color(0xFF3B82F6)
        : (widget.user.isParkingOwner
            ? const Color(0xFF10B981)
            : const Color(0xFF38BDF8));

    final String roleBadge = widget.user.isAdmin
        ? 'ADMIN CONSOLE'
        : (widget.user.isParkingOwner ? 'SPACE PROVIDER' : 'DRIVER PORTAL');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBg,
        foregroundColor: Colors.white,
        elevation: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(
            color: accentBorder,
            height: 2,
          ),
        ),
        title: Row(
          children: [
            const Text(
              'E-Parada',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: accentBorder.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: accentBorder.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                roleBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: accentBorder,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        actions: const [NotificationActionButton()],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Distinct background gradient depending on role
    final gradient = user.isAdmin
        ? LinearGradient(
            colors: isDark
                ? const [Color(0xFF0F264A), Color(0xFF1E1333)]
                : const [Color(0xFF0A2540), Color(0xFF1E3A8A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : (user.isParkingOwner
            ? LinearGradient(
                colors: isDark
                    ? const [Color(0xFF09261B), Color(0xFF07242B)]
                    : const [Color(0xFF064E3B), Color(0xFF047857)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: isDark
                    ? const [Color(0xFF0B1E36), Color(0xFF14243A)]
                    : const [Color(0xFF0A2540), Color(0xFF2563EB)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.white24,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.roleLabel.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Hello, ${user.name}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  summary.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  summary.subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricPalette {
  const _MetricPalette({
    required this.bg,
    required this.border,
    required this.accent,
    required this.number,
    required this.text,
  });

  final Color bg;
  final Color border;
  final Color accent;
  final Color number;
  final Color text;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final DashboardMetric metric;

  static _MetricPalette _getMetricPalette(String key, bool isDark) {
    final k = key.toLowerCase();
    if (k.contains('pending_vehicle') || (k.contains('pending') && !k.contains('payment')) || k.contains('vehicle')) {
      // Amber palette
      return isDark
          ? const _MetricPalette(
              bg: Color(0xFF281E09),
              border: Color(0xFF854D0E),
              accent: Color(0xFFFCD34D),
              number: Color(0xFFFBBF24),
              text: Color(0xFFFDE68A),
            )
          : const _MetricPalette(
              bg: Color(0xFFFFFBEB),
              border: Color(0xFFFDE68A),
              accent: Color(0xFFD97706),
              number: Color(0xFFB45309),
              text: Color(0xFF92400E),
            );
    } else if (k.contains('space') || k.contains('approved') || k.contains('active')) {
      // Emerald palette
      return isDark
          ? const _MetricPalette(
              bg: Color(0xFF09261B),
              border: Color(0xFF065F46),
              accent: Color(0xFF6EE7B7),
              number: Color(0xFF34D399),
              text: Color(0xFFA7F3D0),
            )
          : const _MetricPalette(
              bg: Color(0xFFECFDF5),
              border: Color(0xFFA7F3D0),
              accent: Color(0xFF059669),
              number: Color(0xFF047857),
              text: Color(0xFF065F46),
            );
    } else if (k.contains('admin') || k.contains('system') || k.contains('report') || k.contains('completed')) {
      // Purple palette
      return isDark
          ? const _MetricPalette(
              bg: Color(0xFF1E1333),
              border: Color(0xFF581C87),
              accent: Color(0xFFD8B4FE),
              number: Color(0xFFC084FC),
              text: Color(0xFFE9D5FF),
            )
          : const _MetricPalette(
              bg: Color(0xFFFAF5FF),
              border: Color(0xFFE9D5FF),
              accent: Color(0xFF7E22CE),
              number: Color(0xFF6B21A8),
              text: Color(0xFF581C87),
            );
    } else if (k.contains('payment') || k.contains('revenue') || k.contains('paid')) {
      // Teal palette
      return isDark
          ? const _MetricPalette(
              bg: Color(0xFF07242B),
              border: Color(0xFF115E59),
              accent: Color(0xFF5EEAD4),
              number: Color(0xFF2DD4BF),
              text: Color(0xFF99F6E4),
            )
          : const _MetricPalette(
              bg: Color(0xFFF0FDFA),
              border: Color(0xFF99F6E4),
              accent: Color(0xFF0F766E),
              number: Color(0xFF115E59),
              text: Color(0xFF134E4A),
            );
    } else {
      // Royal Blue palette
      return isDark
          ? const _MetricPalette(
              bg: Color(0xFF0B1E36),
              border: Color(0xFF1E40AF),
              accent: Color(0xFF93C5FD),
              number: Color(0xFF60A5FA),
              text: Color(0xFFBFDBFE),
            )
          : const _MetricPalette(
              bg: Color(0xFFEFF6FF),
              border: Color(0xFFBFDBFE),
              accent: Color(0xFF2563EB),
              number: Color(0xFF1D4ED8),
              text: Color(0xFF1E40AF),
            );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final palette = _getMetricPalette(metric.key, isDark);

    return Container(
      decoration: BoxDecoration(
        color: palette.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: palette.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: palette.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_metricIcon(metric.key), color: palette.accent, size: 20),
            ),
            Text(
              '${metric.value}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: palette.number,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              metric.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: palette.text,
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final approved =
        user.emailVerified &&
        user.verificationStatus == 'approved' &&
        (!user.isDriver || user.hasApprovedVehicle);

    final bg = approved
        ? (isDark ? const Color(0xFF09261B) : const Color(0xFFECFDF5))
        : (isDark ? const Color(0xFF281E09) : const Color(0xFFFFFBEB));
    final border = approved
        ? (isDark ? const Color(0xFF065F46) : const Color(0xFFA7F3D0))
        : (isDark ? const Color(0xFF854D0E) : const Color(0xFFFDE68A));
    final iconColor = approved
        ? (isDark ? const Color(0xFF34D399) : const Color(0xFF059669))
        : (isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706));

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 1.5),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            approved ? Icons.verified_user_outlined : Icons.schedule_outlined,
            color: iconColor,
          ),
        ),
        title: Text(
          approved ? 'Account ready' : 'Verification in progress',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        subtitle: Text(
          approved
              ? '${user.roleLabel} access is active.'
              : 'Verify your email and wait for administrator approval.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white70 : const Color(0xFF334155),
          ),
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
