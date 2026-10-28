import 'package:flutter/material.dart';

class VehicleChip extends StatelessWidget {
  final String label;

  const VehicleChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFFFEF08A).withValues(alpha: 0.12)
            : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark
              ? const Color(0xFFFACC15).withValues(alpha: 0.65)
              : const Color(0xFFEAB308).withValues(alpha: 0.7),
          width: 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getVehicleIcon(label),
            size: 15,
            color: isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: isDark ? const Color(0xFFFDE047) : const Color(0xFFB45309),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _getVehicleIcon(String label) {
    final lower = label.toLowerCase();
    if (lower.contains('motorcycle') || lower.contains('bike')) {
      return Icons.two_wheeler_rounded;
    }
    if (lower.contains('suv') || lower.contains('mpv')) {
      return Icons.directions_car_filled_rounded;
    }
    if (lower.contains('van') || lower.contains('pickup') || lower.contains('truck')) {
      return Icons.airport_shuttle_rounded;
    }
    return Icons.directions_car_rounded;
  }
}
