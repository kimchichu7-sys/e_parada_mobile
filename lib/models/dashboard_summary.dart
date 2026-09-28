class DashboardMetric {
  const DashboardMetric({
    required this.key,
    required this.label,
    required this.value,
  });

  final String key;
  final String label;
  final int value;

  factory DashboardMetric.fromJson(Map<String, dynamic> json) {
    final rawVal = json['value'];
    int parsedVal = 0;
    if (rawVal is num) {
      parsedVal = rawVal.toInt();
    } else if (rawVal != null) {
      parsedVal = int.tryParse(rawVal.toString().replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    }

    return DashboardMetric(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      value: parsedVal,
    );
  }
}

class DashboardSummary {
  const DashboardSummary({
    required this.role,
    required this.title,
    required this.subtitle,
    required this.metrics,
  });

  final String role;
  final String title;
  final String subtitle;
  final List<DashboardMetric> metrics;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final rawMetrics = json['metrics'];

    return DashboardSummary(
      role: json['role']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Dashboard',
      subtitle: json['subtitle']?.toString() ?? '',
      metrics: rawMetrics is List
          ? rawMetrics
                .whereType<Map>()
                .map(
                  (item) =>
                      DashboardMetric.fromJson(Map<String, dynamic>.from(item)),
                )
                .toList()
          : const [],
    );
  }
}
