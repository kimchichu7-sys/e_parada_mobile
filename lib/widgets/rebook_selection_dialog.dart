import 'package:flutter/material.dart';

import '../models/driver_reservation.dart';
import '../models/rebook_alternative.dart';

class RebookSelection {
  const RebookSelection({
    required this.targetParkingSpaceId,
    required this.targetParkingSlotId,
    required this.targetParkingSpaceName,
    required this.slotLabel,
  });

  final int targetParkingSpaceId;
  final int targetParkingSlotId;
  final String targetParkingSpaceName;
  final String slotLabel;
}

class RebookSelectionDialog extends StatefulWidget {
  const RebookSelectionDialog({
    super.key,
    required this.reservation,
    required this.alternativesResponse,
  });

  final DriverReservation reservation;
  final RebookAlternativesResponse alternativesResponse;

  static Future<RebookSelection?> show(
    BuildContext context, {
    required DriverReservation reservation,
    required RebookAlternativesResponse alternativesResponse,
  }) {
    return showModalBottomSheet<RebookSelection>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RebookSelectionDialog(
        reservation: reservation,
        alternativesResponse: alternativesResponse,
      ),
    );
  }

  @override
  State<RebookSelectionDialog> createState() => _RebookSelectionDialogState();
}

class _RebookSelectionDialogState extends State<RebookSelectionDialog> {
  // Store selected slot ID for each space ID
  final Map<int, int> _selectedSlots = {};

  @override
  void initState() {
    super.initState();
    for (final alt in widget.alternativesResponse.alternatives) {
      if (alt.slots.isNotEmpty) {
        _selectedSlots[alt.spaceId] = alt.slots.first.id;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final alternatives = widget.alternativesResponse.alternatives;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.near_me_rounded,
                    color: Colors.amber,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nearest Available Spaces',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Recommended alternatives near "${widget.reservation.parkingSpaceName}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // List of alternatives
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: alternatives.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final alt = alternatives[index];
                final currentSlotId = _selectedSlots[alt.spaceId];

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: colors.outlineVariant.withValues(alpha: 0.6),
                    ),
                  ),
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
                                    alt.spaceName,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    alt.address,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colors.onSurface.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.near_me_outlined,
                                    size: 13,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    alt.distanceLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Badges / rates
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            _Pill(
                              icon: Icons.payments_outlined,
                              label: 'PHP ${alt.hourlyRate.toStringAsFixed(2)}/hr',
                              color: Colors.green,
                            ),
                            _Pill(
                              icon: Icons.grid_view_rounded,
                              label: '${alt.availableSlotsCount} available slot(s)',
                              color: Colors.deepPurple,
                            ),
                            if (alt.isOpen24Hours)
                              const _Pill(
                                icon: Icons.schedule_rounded,
                                label: 'Open 24/7',
                                color: Colors.teal,
                              ),
                          ],
                        ),

                        // Slot selector if multiple slots
                        if (alt.slots.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Select Slot: ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: colors.outlineVariant),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<int>(
                                      value: currentSlotId ?? alt.slots.first.id,
                                      isExpanded: true,
                                      icon: const Icon(Icons.arrow_drop_down, size: 20),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colors.onSurface,
                                      ),
                                      onChanged: (newId) {
                                        if (newId != null) {
                                          setState(() {
                                            _selectedSlots[alt.spaceId] = newId;
                                          });
                                        }
                                      },
                                      items: alt.slots.map((slot) {
                                        return DropdownMenuItem<int>(
                                          value: slot.id,
                                          child: Text('${slot.slotLabel} (#${slot.slotNumber})'),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 14),

                        // Rebook Action Button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.amber.shade800,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: alt.slots.isEmpty
                                ? null
                                : () {
                                    final slotId = currentSlotId ?? alt.slots.first.id;
                                    final chosenSlot = alt.slots.firstWhere(
                                      (s) => s.id == slotId,
                                      orElse: () => alt.slots.first,
                                    );
                                    Navigator.pop(
                                      context,
                                      RebookSelection(
                                        targetParkingSpaceId: alt.spaceId,
                                        targetParkingSlotId: chosenSlot.id,
                                        targetParkingSpaceName: alt.spaceName,
                                        slotLabel: chosenSlot.slotLabel,
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: Text(
                              alt.slots.isEmpty
                                  ? 'No Slots Available'
                                  : 'Rebook to ${alt.spaceName}',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final MaterialColor color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
