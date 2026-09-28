import 'package:flutter/material.dart';

import 'incident_report_screen.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  String _selectedCategory = 'All';

  static const _categories = [
    'All',
    'Troubleshooting',
    'Reservations',
    'QR & Checkpoint',
    'Payments & GCash',
    'Vehicles & Spaces',
    'Account & Privacy',
  ];

  static const _troubleshootingGuides = <_TroubleshootingGuide>[
    _TroubleshootingGuide(
      title: 'Camera / QR Code Scanner Not Working',
      icon: Icons.qr_code_scanner_rounded,
      steps: [
        'Ensure camera permissions are granted in your device or OS settings.',
        'If on Windows/desktop, close other apps (Teams, Zoom, Camera) that may be locking the webcam.',
        'Wipe the camera lens to ensure the QR code is in sharp focus.',
        'FALLBACK: Every reservation has an 8-digit Reference (e.g. EP-10293847). The parking owner can enter it manually on the Checkpoint screen for instant check-in/out.',
      ],
    ),
    _TroubleshootingGuide(
      title: 'Understanding the 15-Minute Grace Period',
      icon: Icons.timer_outlined,
      steps: [
        'E-Parada provides an automated 15-minute grace period upon exit.',
        'If you leave within 15 minutes of an extra hour block, that excess hour charge is waived.',
        'Overstaying beyond scheduled duration without extension will accrue standard overtime penalty rates as configured by the space owner.',
      ],
    ),
    _TroubleshootingGuide(
      title: 'GCash Payment Settlement & Reference',
      icon: Icons.account_balance_wallet_outlined,
      steps: [
        'Use the built-in GCash Payment Gateway for instant verification with reference code (GC-XXXXXXXXXX).',
        'If uploading a screenshot manually, ensure the GCash Reference Number and amount are clearly visible.',
        'The space owner will confirm cash or GCash settlement before the reservation marks as completed.',
      ],
    ),
    _TroubleshootingGuide(
      title: 'Spatial Mismatch / Vehicle Overhang',
      icon: Icons.aspect_ratio_rounded,
      steps: [
        'Compare your vehicle dimensions (Length × Width × Height) with the parking space specifications.',
        'If your vehicle cannot safely fit without obstructing traffic, do not force entry.',
        'Submit a Spatial Mismatch Incident Report immediately so administration can moderate the space.',
      ],
    ),
  ];

  static const _faqs = <_FaqItem>[
    _FaqItem(
      category: 'Account & Privacy',
      question: 'Why does my account still say pending review?',
      answer:
          'Email verification and administrator review are separate. Verify your email first via the Profile screen, then wait for an administrator to review the ID and account details you submitted.',
    ),
    _FaqItem(
      category: 'Vehicles & Spaces',
      question: 'Why are front and back photos required for vehicles?',
      answer:
          'The two views help administrators verify the vehicle make, model, color, and LTO plate format. They confirm access to the vehicle but are not official proof of ownership.',
    ),
    _FaqItem(
      category: 'Vehicles & Spaces',
      question: 'Can I edit a submitted plate number?',
      answer:
          'No. Vehicle details are locked after submission to protect the integrity of verification records. If a rejected submission contains errors, remove it from My Vehicles and submit a new record.',
    ),
    _FaqItem(
      category: 'Reservations',
      question: 'Why can\'t I reserve a parking space?',
      answer:
          'Drivers need: 1) A verified email address, 2) An approved driver account, and 3) At least one approved vehicle matching the slot type. The selected time must also be within the space\'s operating hours.',
    ),
    _FaqItem(
      category: 'Reservations',
      question: 'Can I extend or reschedule my parking session?',
      answer:
          'Yes, if the parking space is available for the requested time. Open your active reservation and tap "Extend Booking" or "Reschedule" before the session concludes.',
    ),
    _FaqItem(
      category: 'QR & Checkpoint',
      question: 'What if the checkpoint scanner fails to read my QR code?',
      answer:
          'Present your 8-digit Backup Reference (e.g., EP-10293847) to the space owner. They can manually validate entry/exit on their Checkpoint screen. All transactions are logged with timestamps.',
    ),
    _FaqItem(
      category: 'Payments & GCash',
      question: 'How do GCash and Cash settlements work?',
      answer:
          'Drivers can pay via the simulated GCash Gateway for automatic instant verification or upload a transfer receipt. Cash payments are handed directly to the owner upon exit.',
    ),
    _FaqItem(
      category: 'Account & Privacy',
      question: 'Who can see my ID and vehicle photos?',
      answer:
          'Access is strictly restricted to you, platform administrators, and parking providers with an active reservation. Photos are never exposed through public unauthenticated links.',
    ),
  ];

  List<_FaqItem> get _filteredFaqs {
    if (_selectedCategory == 'All') return _faqs;
    return _faqs.where((f) => f.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Help & FAQs')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: colors.onPrimary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'E-Parada Support Hub',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Guides, step-by-step troubleshooting, and policy FAQs.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Card(
            color: const Color(0xFFFEE2E2),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
            ),
            child: ListTile(
              leading: const Icon(Icons.report_problem_rounded, color: Color(0xFF991B1B)),
              title: const Text(
                'Have an urgent issue or complaint?',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF991B1B),
                  fontSize: 14,
                ),
              ),
              subtitle: const Text(
                'Submit an incident report for property damage, overcharges, or system bugs.',
                style: TextStyle(color: Color(0xFF7F1D1D), fontSize: 12),
              ),
              trailing: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF991B1B),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const IncidentReportScreen()),
                ),
                child: const Text('File Report', style: TextStyle(fontSize: 12)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Step-by-Step Problem Solving',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ..._troubleshootingGuides.map(
            (guide) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ExpansionTile(
                leading: Icon(guide.icon, color: colors.primary),
                title: Text(
                  guide.title,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: guide.steps
                          .map(
                            (step) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '• ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colors.primary,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      step,
                                      style: const TextStyle(fontSize: 13, height: 1.4),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Frequently Asked Questions',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          ..._filteredFaqs.map(
            (faq) => Card(
              margin: const EdgeInsets.only(bottom: 10),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                leading: CircleAvatar(
                  backgroundColor: colors.secondaryContainer,
                  child: Icon(
                    _categoryIcon(faq.category),
                    color: colors.onSecondaryContainer,
                    size: 18,
                  ),
                ),
                title: Text(
                  faq.question,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                subtitle: Text(faq.category, style: const TextStyle(fontSize: 12)),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(faq.answer, style: const TextStyle(height: 1.4)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'Troubleshooting' => Icons.build_circle_outlined,
      'Reservations' => Icons.calendar_month_outlined,
      'QR & Checkpoint' => Icons.qr_code_scanner_outlined,
      'Payments & GCash' => Icons.payments_outlined,
      'Vehicles & Spaces' => Icons.directions_car_outlined,
      _ => Icons.manage_accounts_outlined,
    };
  }
}

class _TroubleshootingGuide {
  const _TroubleshootingGuide({
    required this.title,
    required this.icon,
    required this.steps,
  });

  final String title;
  final IconData icon;
  final List<String> steps;
}

class _FaqItem {
  const _FaqItem({
    required this.category,
    required this.question,
    required this.answer,
  });

  final String category;
  final String question;
  final String answer;
}
