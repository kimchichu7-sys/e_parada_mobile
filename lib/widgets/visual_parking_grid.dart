import 'package:flutter/material.dart';

import '../models/reservation_availability.dart';

enum ParkingGridLayout {
  floorPlan,
  compactGrid,
}

class VisualParkingGrid extends StatefulWidget {
  const VisualParkingGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
    this.initialLayout = ParkingGridLayout.floorPlan,
  });

  final List<ReservationSlot> slots;
  final ReservationSlot? selectedSlot;
  final ValueChanged<ReservationSlot> onSlotSelected;
  final ParkingGridLayout initialLayout;

  @override
  State<VisualParkingGrid> createState() => _VisualParkingGridState();
}

class _VisualParkingGridState extends State<VisualParkingGrid> {
  late ParkingGridLayout _layout;

  @override
  void initState() {
    super.initState();
    _layout = widget.initialLayout;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (widget.slots.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: const Column(
          children: [
            Icon(Icons.local_parking_rounded, size: 36, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No parking slots available for the selected schedule.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header & Layout Switcher (Responsive Autofit for all phone widths)
        LayoutBuilder(
          builder: (context, constraints) {
            final isCompactPhone = constraints.maxWidth < 390;

            final switcher = SegmentedButton<ParkingGridLayout>(
              showSelectedIcon: false,
              style: const ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              segments: const [
                ButtonSegment(
                  value: ParkingGridLayout.floorPlan,
                  icon: Icon(Icons.layers_outlined, size: 16),
                  label: Text('Floor Plan', style: TextStyle(fontSize: 12)),
                ),
                ButtonSegment(
                  value: ParkingGridLayout.compactGrid,
                  icon: Icon(Icons.grid_view_rounded, size: 16),
                  label: Text('Grid', style: TextStyle(fontSize: 12)),
                ),
              ],
              selected: {_layout},
              onSelectionChanged: (selected) {
                if (selected.isNotEmpty) {
                  setState(() => _layout = selected.first);
                }
              },
            );

            if (isCompactPhone) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.dashboard_customize_outlined, size: 20, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Select Parking Bay',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: switcher,
                  ),
                ],
              );
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.dashboard_customize_outlined, size: 20, color: colors.primary),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Select Parking Bay',
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                switcher,
              ],
            );
          },
        ),
        const SizedBox(height: 10),

        // Legend
        _buildLegend(context),
        const SizedBox(height: 14),

        // Selected Bay Banner
        if (widget.selectedSlot != null)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: colors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Selected: ${widget.selectedSlot!.label} (Ready to reserve)',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                      fontSize: 13,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => widget.onSlotSelected(widget.selectedSlot!),
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: const Text('Change'),
                ),
              ],
            ),
          ),

        // Visual Viewport
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 250),
          crossFadeState: _layout == ParkingGridLayout.floorPlan
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          firstChild: _buildFloorPlanLayout(context),
          secondChild: _buildCompactGridLayout(context),
        ),
      ],
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(
          color: const Color(0xFF16A34A),
          label: 'Available',
          icon: Icons.check_circle_outline,
        ),
        _LegendItem(
          color: const Color(0xFFDC2626),
          label: 'Occupied',
          icon: Icons.block_rounded,
        ),
        _LegendItem(
          color: Theme.of(context).colorScheme.primary,
          label: 'Selected',
          icon: Icons.check_circle,
        ),
        _LegendItem(
          color: Colors.grey.shade500,
          label: 'Unsupported',
          icon: Icons.remove_circle_outline,
        ),
      ],
    );
  }

  Widget _buildFloorPlanLayout(BuildContext context) {
    final leftSlots = <ReservationSlot>[];
    final rightSlots = <ReservationSlot>[];

    for (var i = 0; i < widget.slots.length; i++) {
      if (i % 2 == 0) {
        leftSlots.add(widget.slots[i]);
      } else {
        rightSlots.add(widget.slots[i]);
      }
    }

    final rowCount = leftSlots.length > rightSlots.length ? leftSlots.length : rightSlots.length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Asphalt dark floor plan
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Entry Gate Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFBBF24),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.black),
                SizedBox(width: 6),
                Text(
                  'DRIVEWAY ENTRY & AISLE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: Colors.black,
                  ),
                ),
                SizedBox(width: 6),
                Icon(Icons.arrow_downward_rounded, size: 16, color: Colors.black),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Parking Aisle and Stalls
          for (var r = 0; r < rowCount; r++) ...[
            Row(
              children: [
                // Left Bay
                Expanded(
                  child: r < leftSlots.length
                      ? _ParkingStallCard(
                          slot: leftSlots[r],
                          isSelected: widget.selectedSlot?.id == leftSlots[r].id,
                          onTap: () => widget.onSlotSelected(leftSlots[r]),
                          alignment: StallAlignment.left,
                        )
                      : const SizedBox.shrink(),
                ),

                // Center Driving Aisle Divider
                Container(
                  width: 32,
                  height: 90,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE047).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 4,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE047).withValues(alpha: 0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Bay
                Expanded(
                  child: r < rightSlots.length
                      ? _ParkingStallCard(
                          slot: rightSlots[r],
                          isSelected: widget.selectedSlot?.id == rightSlots[r].id,
                          onTap: () => widget.onSlotSelected(rightSlots[r]),
                          alignment: StallAlignment.right,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
            if (r < rowCount - 1) const SizedBox(height: 10),
          ],

          const SizedBox(height: 10),
          // Exit Gate Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_downward_rounded, size: 14, color: Colors.white70),
                SizedBox(width: 6),
                Text(
                  'PARKING EXIT AISLE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactGridLayout(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.slots.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.sizeOf(context).width >= 700 ? 4 : 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.5,
      ),
      itemBuilder: (context, index) {
        final slot = widget.slots[index];
        final isSelected = widget.selectedSlot?.id == slot.id;
        return _CompactSlotCard(
          slot: slot,
          isSelected: isSelected,
          onTap: () => widget.onSlotSelected(slot),
        );
      },
    );
  }
}

enum StallAlignment { left, right }

class _ParkingStallCard extends StatelessWidget {
  const _ParkingStallCard({
    required this.slot,
    required this.isSelected,
    required this.onTap,
    required this.alignment,
  });

  final ReservationSlot slot;
  final bool isSelected;
  final VoidCallback onTap;
  final StallAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final isAvailable = slot.isAvailable;
    final isOccupied = slot.isOccupied;

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (isSelected) {
      borderColor = const Color(0xFF38BDF8); // Vibrant cyan-blue
      backgroundColor = const Color(0xFF0284C7).withValues(alpha: 0.35);
      textColor = Colors.white;
    } else if (isOccupied) {
      borderColor = const Color(0xFFEF4444).withValues(alpha: 0.5);
      backgroundColor = const Color(0xFF7F1D1D).withValues(alpha: 0.4);
      textColor = const Color(0xFFFCA5A5);
    } else if (isAvailable) {
      borderColor = const Color(0xFF22C55E);
      backgroundColor = const Color(0xFF14532D).withValues(alpha: 0.35);
      textColor = const Color(0xFF86EFAC);
    } else {
      borderColor = const Color(0xFF64748B);
      backgroundColor = const Color(0xFF334155).withValues(alpha: 0.3);
      textColor = const Color(0xFF94A3B8);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isAvailable ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        splashColor: isAvailable ? Colors.white24 : Colors.transparent,
        child: Container(
          height: 86,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              // Vehicle Stall Marker Lines
              Container(
                width: 3,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFFFBBF24).withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            slot.label,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isSelected)
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF38BDF8), size: 18)
                        else if (isOccupied)
                          const Icon(Icons.directions_car_filled_rounded, color: Color(0xFFF87171), size: 16)
                        else if (isAvailable)
                          const Icon(Icons.local_parking_rounded, color: Color(0xFF4ADE80), size: 16)
                        else
                          const Icon(Icons.not_interested_rounded, color: Color(0xFF94A3B8), size: 16),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSelected
                          ? 'SELECTED'
                          : isOccupied
                              ? 'OCCUPIED'
                              : isAvailable
                                  ? 'AVAILABLE'
                                  : 'UNSUPPORTED',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        color: textColor,
                      ),
                    ),
                    if (slot.supportedVehicleTypes.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        slot.supportedVehicleTypes.join(', '),
                        style: TextStyle(
                          fontSize: 9.5,
                          color: textColor.withValues(alpha: 0.75),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactSlotCard extends StatelessWidget {
  const _CompactSlotCard({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final ReservationSlot slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isAvailable = slot.isAvailable;

    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primaryContainer
              : isAvailable
                  ? colors.surfaceContainerHighest.withValues(alpha: 0.5)
                  : colors.errorContainer.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : isAvailable
                    ? colors.outlineVariant
                    : colors.error.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.local_parking_rounded,
                  color: isSelected
                      ? colors.primary
                      : isAvailable
                          ? Colors.green
                          : colors.error,
                  size: 20,
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: colors.primary, size: 18),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              slot.label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            Text(
              isSelected
                  ? 'Selected'
                  : slot.isOccupied
                      ? 'Occupied'
                      : isAvailable
                          ? 'Available'
                          : 'Unsupported',
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? colors.primary
                    : isAvailable
                        ? Colors.green.shade800
                        : colors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.icon,
  });

  final Color color;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
