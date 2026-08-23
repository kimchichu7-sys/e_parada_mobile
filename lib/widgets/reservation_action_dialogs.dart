import 'package:flutter/material.dart';

import '../models/driver_reservation.dart';

class RescheduleSelection {
  const RescheduleSelection({
    required this.reservationDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  final String reservationDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String reason;
}

class FeedbackSelection {
  const FeedbackSelection({required this.rating, required this.comment});

  final int rating;
  final String comment;
}

Future<RescheduleSelection?> showRescheduleDialog(
  BuildContext context,
  DriverReservation reservation,
) async {
  final today = DateUtils.dateOnly(DateTime.now());
  var startDate = DateTime.tryParse(reservation.reservationDate) ?? today;
  if (startDate.isBefore(today)) startDate = today;
  var endDate = DateTime.tryParse(reservation.endDate) ?? startDate;
  if (endDate.isBefore(startDate)) endDate = startDate;
  var startTime = _parseTime(reservation.startTime);
  var endTime = _parseTime(reservation.endTime);
  final reasonController = TextEditingController();

  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Reschedule ${reservation.backupReference}'),
        content: SizedBox(
          width: 420,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'The parking owner must approve the new schedule again.',
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_outlined),
                  title: const Text('Start date'),
                  subtitle: Text(_date(startDate)),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: today,
                      lastDate: today.add(const Duration(days: 365)),
                    );
                    if (selected == null) return;
                    setDialogState(() {
                      startDate = selected;
                      if (endDate.isBefore(startDate)) endDate = startDate;
                    });
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.schedule_outlined),
                  title: const Text('Start time'),
                  subtitle: Text(startTime.format(context)),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: startTime,
                    );
                    if (selected != null) {
                      setDialogState(() => startTime = selected);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_available_outlined),
                  title: const Text('End date'),
                  subtitle: Text(_date(endDate)),
                  onTap: () async {
                    final selected = await showDatePicker(
                      context: context,
                      initialDate: endDate.isBefore(startDate)
                          ? startDate
                          : endDate,
                      firstDate: startDate,
                      lastDate: today.add(const Duration(days: 365)),
                    );
                    if (selected != null) {
                      setDialogState(() => endDate = selected);
                    }
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.more_time_outlined),
                  title: const Text('End time'),
                  subtitle: Text(endTime.format(context)),
                  onTap: () async {
                    final selected = await showTimePicker(
                      context: context,
                      initialTime: endTime,
                    );
                    if (selected != null) {
                      setDialogState(() => endTime = selected);
                    }
                  },
                ),
                TextField(
                  controller: reasonController,
                  maxLength: 1000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Optional reason',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Send for approval'),
          ),
        ],
      ),
    ),
  );

  final reason = reasonController.text.trim();
  reasonController.dispose();
  if (accepted != true) return null;

  return RescheduleSelection(
    reservationDate: _date(startDate),
    endDate: _date(endDate),
    startTime: _time(startTime),
    endTime: _time(endTime),
    reason: reason,
  );
}

Future<FeedbackSelection?> showFeedbackDialog(
  BuildContext context,
  DriverReservation reservation,
) async {
  var rating = 5;
  final commentController = TextEditingController();

  final accepted = await showDialog<bool>(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: Text('Rate ${reservation.parkingSpaceName}'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    tooltip: '$value star',
                    onPressed: () => setDialogState(() => rating = value),
                    icon: Icon(
                      value <= rating ? Icons.star : Icons.star_border,
                      color: Colors.amber.shade700,
                      size: 34,
                    ),
                  );
                }),
              ),
              Text('$rating of 5 stars'),
              const SizedBox(height: 14),
              TextField(
                controller: commentController,
                maxLength: 2000,
                maxLines: 5,
                onChanged: (_) => setDialogState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Share your parking experience',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Back'),
          ),
          FilledButton(
            onPressed: commentController.text.trim().isEmpty
                ? null
                : () => Navigator.pop(context, true),
            child: const Text('Submit feedback'),
          ),
        ],
      ),
    ),
  );

  final comment = commentController.text.trim();
  commentController.dispose();
  if (accepted != true) return null;
  return FeedbackSelection(rating: rating, comment: comment);
}

TimeOfDay _parseTime(String value) {
  final parts = value.split(':');
  return TimeOfDay(
    hour: int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 0,
    minute: int.tryParse(parts.length > 1 ? parts[1] : '') ?? 0,
  );
}

String _date(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

String _time(TimeOfDay value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
