import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faqs = <_FaqItem>[
    _FaqItem(
      category: 'Account',
      question: 'Why does my account still say pending?',
      answer:
          'Email verification and administrator review are separate. Verify your email first, then wait for an administrator to review the ID and account details you submitted.',
    ),
    _FaqItem(
      category: 'Vehicles',
      question: 'Why are front and back photos required?',
      answer:
          'The two views help the administrator compare the vehicle, plate, model, and color. They confirm access to the vehicle but are not official proof of ownership.',
    ),
    _FaqItem(
      category: 'Vehicles',
      question: 'Can I edit a submitted plate number?',
      answer:
          'No. Vehicle details are locked after submission to protect the verification record. If a rejected submission is incorrect, remove it and submit the vehicle again.',
    ),
    _FaqItem(
      category: 'Reservations',
      question: 'Why can\'t I reserve a parking space?',
      answer:
          'Drivers need a verified email, an approved driver account, and at least one approved vehicle. The selected time must also be within the parking space operating hours.',
    ),
    _FaqItem(
      category: 'Reservations',
      question: 'Can I extend my parking time?',
      answer:
          'Yes, when the space is still available after your current end time. Open the reservation and request an extension before the booking expires.',
    ),
    _FaqItem(
      category: 'Entry and exit',
      question: 'What if the QR code cannot be scanned?',
      answer:
          'Show the reservation backup reference to the parking provider. They can enter it manually on the validation screen. Entry and exit attempts are recorded in the transaction log.',
    ),
    _FaqItem(
      category: 'Payments',
      question: 'When is my payment marked as paid?',
      answer:
          'After you submit proof, the parking provider reviews it. The status changes from pending verification to paid once the provider confirms the payment.',
    ),
    _FaqItem(
      category: 'Privacy',
      question: 'Who can see my ID and vehicle photos?',
      answer:
          'Access is restricted to you, authorized administrators, and parking providers who need the vehicle details for an active reservation. Files are not public links.',
    ),
  ];

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
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.support_agent_rounded,
                    color: colors.onPrimary,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How can we help?',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Quick answers for using E-Parada safely and smoothly.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Frequently asked questions',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),
          ..._faqs.map(
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
                    size: 20,
                  ),
                ),
                title: Text(
                  faq.question,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                subtitle: Text(faq.category),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(faq.answer),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline_rounded),
              title: const Text(
                'Still need help?',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: const Text(
                'Use the Support page on the E-Parada website to send a detailed request to the team.',
              ),
            ),
          ),
        ],
      ),
    );
  }

  static IconData _categoryIcon(String category) {
    return switch (category) {
      'Account' => Icons.manage_accounts_outlined,
      'Vehicles' => Icons.directions_car_outlined,
      'Reservations' => Icons.calendar_month_outlined,
      'Entry and exit' => Icons.qr_code_scanner_outlined,
      'Payments' => Icons.payments_outlined,
      _ => Icons.privacy_tip_outlined,
    };
  }
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
