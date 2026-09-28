import 'package:flutter/material.dart';

import '../models/admin_models.dart';
import '../services/admin_operations_service.dart';

class AdminOperationsScreen extends StatefulWidget {
  const AdminOperationsScreen({super.key});

  @override
  State<AdminOperationsScreen> createState() => _AdminOperationsScreenState();
}

class _AdminOperationsScreenState extends State<AdminOperationsScreen> {
  bool _acting = false;
  late Future<_OperationsData> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_OperationsData> _load() async {
    final results = await Future.wait([
      AdminOperationsService.fetchSupport(),
      AdminOperationsService.fetchActivity(),
    ]);
    return _OperationsData(
      support: results[0] as List<AdminSupportRequest>,
      activity: results[1] as AdminActivityData,
    );
  }

  Future<void> _refresh() async {
    final request = _load();
    setState(() {
      _future = request;
    });
    await request;
  }

  Future<void> _updateSupport(
    AdminSupportRequest request,
    String status,
  ) async {
    if (_acting || status == request.status) return;
    setState(() => _acting = true);
    try {
      final message = await AdminOperationsService.updateSupport(
        request.id,
        status,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
      await _refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _acting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Platform Operations'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.support_agent_outlined), text: 'Support'),
              Tab(icon: Icon(Icons.qr_code_scanner_outlined), text: 'QR logs'),
              Tab(icon: Icon(Icons.history_outlined), text: 'Audit'),
            ],
          ),
        ),
        body: Stack(
          children: [
            FutureBuilder<_OperationsData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || snapshot.data == null) {
                  return _Message(
                    text:
                        snapshot.error?.toString() ?? 'Operations unavailable.',
                    onRetry: _refresh,
                  );
                }
                final data = snapshot.data!;
                return TabBarView(
                  children: [
                    _SupportList(
                      requests: data.support,
                      onRefresh: _refresh,
                      onStatusChanged: _updateSupport,
                    ),
                    _QrLogList(logs: data.activity.qrLogs, onRefresh: _refresh),
                    _AuditList(
                      logs: data.activity.auditLogs,
                      onRefresh: _refresh,
                    ),
                  ],
                );
              },
            ),
            if (_acting)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OperationsData {
  const _OperationsData({required this.support, required this.activity});

  final List<AdminSupportRequest> support;
  final AdminActivityData activity;
}

class _SupportList extends StatelessWidget {
  const _SupportList({
    required this.requests,
    required this.onRefresh,
    required this.onStatusChanged,
  });

  final List<AdminSupportRequest> requests;
  final Future<void> Function() onRefresh;
  final Future<void> Function(AdminSupportRequest, String) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return _Message(text: 'No support requests found.', onRetry: onRefresh);
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.subject,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text('${request.name} | ${request.email}'),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        tooltip: 'Change status',
                        initialValue: request.status,
                        onSelected: (value) => onStatusChanged(request, value),
                        itemBuilder: (context) => const [
                          PopupMenuItem(value: 'open', child: Text('Open')),
                          PopupMenuItem(
                            value: 'in_progress',
                            child: Text('In progress'),
                          ),
                          PopupMenuItem(
                            value: 'resolved',
                            child: Text('Resolved'),
                          ),
                        ],
                        child: _Badge(
                          label: _label(request.status),
                          color: _supportColor(request.status),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 26),
                  Wrap(
                    spacing: 8,
                    children: [
                      Chip(label: Text(_label(request.category))),
                      Chip(label: Text(_label(request.userRole))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(request.message),
                  if (request.createdAt != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _timestamp(request.createdAt),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _QrLogList extends StatefulWidget {
  const _QrLogList({required this.logs, required this.onRefresh});

  final List<AdminQrLog> logs;
  final Future<void> Function() onRefresh;

  @override
  State<_QrLogList> createState() => _QrLogListState();
}

class _QrLogListState extends State<_QrLogList> {
  String? _selectedSpaceKey;

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return _Message(
        text: 'No QR validation activity found.',
        onRetry: widget.onRefresh,
      );
    }

    final options = <String, String>{};
    for (final log in widget.logs) {
      options[_spaceKey(log.parkingSpaceId, log.parkingSpaceName)] =
          log.parkingSpaceName;
    }
    final selectedKey = options.containsKey(_selectedSpaceKey)
        ? _selectedSpaceKey!
        : options.keys.first;
    final filteredLogs = widget.logs
        .where(
          (log) =>
              _spaceKey(log.parkingSpaceId, log.parkingSpaceName) ==
              selectedKey,
        )
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _ParkingSpaceLogFilter(
            label: 'QR logs for',
            options: options,
            selectedKey: selectedKey,
            count: filteredLogs.length,
            onChanged: (value) => setState(() => _selectedSpaceKey = value),
          ),
          const SizedBox(height: 12),
          for (final log in filteredLogs) ...[
            _QrLogCard(log: log),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}

class _QrLogCard extends StatelessWidget {
  const _QrLogCard({required this.log});

  final AdminQrLog log;

  @override
  Widget build(BuildContext context) {
    final color = log.wasSuccessful
        ? Colors.green
        : Theme.of(context).colorScheme.error;
    return Card(
      child: ListTile(
        isThreeLine: true,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          foregroundColor: color,
          child: Icon(log.wasSuccessful ? Icons.check : Icons.close),
        ),
        title: Text(
          '${_label(log.eventType)} | ${log.backupReference.isEmpty ? 'No reservation' : log.backupReference}',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          '${_label(log.lookupMethod)} by ${log.actorName}${log.failureReason.isEmpty ? '' : '\n${log.failureReason}'}\n${_timestamp(log.createdAt)}',
        ),
        trailing: _Badge(
          label: log.wasSuccessful ? 'Success' : 'Failed',
          color: color,
        ),
      ),
    );
  }
}

class _AuditList extends StatefulWidget {
  const _AuditList({required this.logs, required this.onRefresh});

  final List<AdminAuditLog> logs;
  final Future<void> Function() onRefresh;

  @override
  State<_AuditList> createState() => _AuditListState();
}

class _AuditListState extends State<_AuditList> {
  String? _selectedSpaceKey;

  @override
  Widget build(BuildContext context) {
    if (widget.logs.isEmpty) {
      return _Message(
        text: 'No audit activity found.',
        onRetry: widget.onRefresh,
      );
    }

    final options = <String, String>{};
    for (final log in widget.logs) {
      options[_spaceKey(log.parkingSpaceId, log.parkingSpaceName)] =
          log.parkingSpaceName;
    }
    final selectedKey = options.containsKey(_selectedSpaceKey)
        ? _selectedSpaceKey!
        : options.keys.first;
    final filteredLogs = widget.logs
        .where(
          (log) =>
              _spaceKey(log.parkingSpaceId, log.parkingSpaceName) ==
              selectedKey,
        )
        .toList(growable: false);

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _ParkingSpaceLogFilter(
            label: 'Audit activity for',
            options: options,
            selectedKey: selectedKey,
            count: filteredLogs.length,
            onChanged: (value) => setState(() => _selectedSpaceKey = value),
          ),
          const SizedBox(height: 12),
          for (final log in filteredLogs) ...[
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    log.parkingSpaceId == null
                        ? Icons.admin_panel_settings_outlined
                        : Icons.local_parking_outlined,
                  ),
                ),
                title: Text(
                  log.description.isEmpty
                      ? _label(log.action)
                      : log.description,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(
                  '${log.actorName} | ${log.subjectType}${log.subjectId == null ? '' : ' #${log.subjectId}'}\n${_timestamp(log.createdAt)}',
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _ParkingSpaceLogFilter extends StatelessWidget {
  const _ParkingSpaceLogFilter({
    required this.label,
    required this.options,
    required this.selectedKey,
    required this.count,
    required this.onChanged,
  });

  final String label;
  final Map<String, String> options;
  final String selectedKey;
  final int count;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            key: ValueKey(selectedKey),
            initialValue: selectedKey,
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: const Icon(Icons.local_parking_outlined),
              border: const OutlineInputBorder(),
            ),
            items: options.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(growable: false),
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 10),
        _Badge(label: '$count', color: Theme.of(context).colorScheme.primary),
      ],
    );
  }
}

String _spaceKey(int? parkingSpaceId, String parkingSpaceName) {
  if (parkingSpaceId == null) {
    return parkingSpaceName == 'Platform activity'
        ? 'platform'
        : 'unknown:$parkingSpaceName';
  }
  return 'space:$parkingSpaceId';
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.onRetry});

  final String text;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.admin_panel_settings_outlined, size: 52),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Refresh')),
          ],
        ),
      ),
    );
  }
}

Color _supportColor(String status) {
  return switch (status) {
    'resolved' => Colors.green,
    'in_progress' => Colors.orange,
    _ => Colors.blue,
  };
}

String _label(String value) {
  if (value.isEmpty) return 'Unknown';
  return value
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _timestamp(DateTime? value) {
  if (value == null) return 'Time unavailable';
  final local = value.toLocal();
  String two(int number) => number.toString().padLeft(2, '0');
  return '${local.year}-${two(local.month)}-${two(local.day)} ${two(local.hour)}:${two(local.minute)}';
}
