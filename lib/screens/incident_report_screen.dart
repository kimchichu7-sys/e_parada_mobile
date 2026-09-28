import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';

class IncidentReportScreen extends StatefulWidget {
  const IncidentReportScreen({
    super.key,
    this.initialReference = '',
    this.initialSpaceName = '',
  });

  final String initialReference;
  final String initialSpaceName;

  @override
  State<IncidentReportScreen> createState() => _IncidentReportScreenState();
}

class _IncidentReportScreenState extends State<IncidentReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  String _category = 'Spatial Mismatch / Vehicle Overhang';
  String _severity = 'Medium';
  late final TextEditingController _referenceController;
  late final TextEditingController _spaceController;
  final _plateController = TextEditingController();
  final _descriptionController = TextEditingController();
  XFile? _evidencePhoto;
  bool _submitting = false;

  static const _categories = [
    'Spatial Mismatch / Vehicle Overhang',
    'Property Damage Complaint',
    'Overcharging / Billing Surcharge Dispute',
    'Unauthorized Vehicle in Slot',
    'System Issue / Technical Bug',
    'Safety or Hazard Concern',
    'Other Platform Concern',
  ];

  static const _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
    _referenceController = TextEditingController(text: widget.initialReference);
    _spaceController = TextEditingController(text: widget.initialSpaceName);
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _spaceController.dispose();
    _plateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (photo != null) {
      setState(() => _evidencePhoto = photo);
    }
  }

  String _generateIncidentId() {
    final random = Random();
    final num = List.generate(8, (_) => random.nextInt(10)).join();
    return 'INC-$num';
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _submitting = false);

    final incidentId = _generateIncidentId();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_rounded, color: Color(0xFF166534), size: 48),
        title: const Text('Incident Report Submitted'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your report has been securely submitted to E-Parada administrative moderation.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Incident Tracking ID:',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                  ),
                  const SizedBox(height: 2),
                  SelectableText(
                    incidentId,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF166534),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Our support team will review the details and reach out within 24-48 hours.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: const Text('Return to Profile'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Incident Report'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: theme.colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Administrative Moderation',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Report property damage, spatial mismatches, unauthorized parking, or system anomalies for official mediation.',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Category
              const Text(
                'Incident Category *',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                isExpanded: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _category = val ?? _category),
              ),
              const SizedBox(height: 18),

              // Severity
              const Text(
                'Severity Level *',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _severity,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.warning_amber_rounded),
                ),
                items: _severities
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) => setState(() => _severity = val ?? _severity),
              ),
              const SizedBox(height: 18),

              // Space / Location
              const Text(
                'Parking Space / Location',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _spaceController,
                decoration: const InputDecoration(
                  hintText: 'e.g. NU Laguna Parking Bay or Street Address',
                  prefixIcon: Icon(Icons.local_parking_rounded),
                ),
              ),
              const SizedBox(height: 18),

              // Reservation Reference & Vehicle Plate
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Reservation Ref (if any)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _referenceController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. EP-10293847',
                            prefixIcon: Icon(Icons.confirmation_number_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Vehicle Plate (if any)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        TextFormField(
                          controller: _plateController,
                          decoration: const InputDecoration(
                            hintText: 'e.g. ABC 1234',
                            prefixIcon: Icon(Icons.directions_car_outlined),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Description
              const Text(
                'Detailed Description *',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                maxLength: 1000,
                validator: (val) {
                  if (val == null || val.trim().length < 15) {
                    return 'Please provide at least 15 characters explaining what happened.';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: 'Describe the incident, spatial mismatch, vehicle obstruction, or damage clearly...',
                ),
              ),
              const SizedBox(height: 14),

              // Photo Attachment
              const Text(
                'Photo Evidence / Attachment',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _pickPhoto,
                icon: const Icon(Icons.photo_camera_back_outlined),
                label: Text(
                  _evidencePhoto == null ? 'Attach Photo Evidence' : 'Change Attached Photo',
                ),
              ),
              if (_evidencePhoto != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Color(0xFF166534), size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _evidencePhoto!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () => setState(() => _evidencePhoto = null),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 28),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _submitting ? null : _submitReport,
                  icon: _submitting
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send_rounded),
                  label: Text(_submitting ? 'Submitting Report...' : 'Submit Incident Report'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
