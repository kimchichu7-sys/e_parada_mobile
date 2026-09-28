import 'package:flutter/material.dart';

class AppFeedbackDialog extends StatefulWidget {
  const AppFeedbackDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => const AppFeedbackDialog(),
    );
  }

  @override
  State<AppFeedbackDialog> createState() => _AppFeedbackDialogState();
}

class _AppFeedbackDialogState extends State<AppFeedbackDialog> {
  int _rating = 5;
  String _satisfaction = 'Very Satisfied';
  final _commentController = TextEditingController();
  bool _submitting = false;

  static const _satisfactionLevels = [
    'Very Satisfied',
    'Satisfied',
    'Neutral',
    'Needs Improvement',
  ];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _submitting = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Your feedback helps us improve E-Parada.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF173B64)),
          SizedBox(width: 10),
          Text('Rate E-Parada App'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How was your experience using E-Parada?',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  icon: Icon(
                    starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: const Color(0xFFFFDE70),
                    size: 36,
                  ),
                  onPressed: () => setState(() => _rating = starIndex),
                );
              }),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _satisfaction,
              decoration: const InputDecoration(
                labelText: 'Overall Satisfaction',
                border: OutlineInputBorder(),
              ),
              items: _satisfactionLevels
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => setState(() => _satisfaction = val ?? _satisfaction),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _commentController,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(
                labelText: 'Suggestions or comments (Optional)',
                hintText: 'Tell us how we can make parking even easier...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: _submitting
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Feedback'),
        ),
      ],
    );
  }
}
