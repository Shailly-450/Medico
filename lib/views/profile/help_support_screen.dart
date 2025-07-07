import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: AppColors.paleBackground,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // FAQ Section
            Text('Frequently Asked Questions',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            _FaqCard(
              question: 'How do I book an appointment?',
              answer: 'Go to the Home or Doctors tab, select a doctor, and tap on "Book Appointment".',
            ),
            _FaqCard(
              question: 'How can I access my health records?',
              answer: 'Navigate to the Health Records section from the dashboard or profile.',
            ),
            _FaqCard(
              question: 'How do I reset my password?',
              answer: 'Go to Profile > Settings > Change Password to reset your password.',
            ),
            _FaqCard(
              question: 'How do I contact support?',
              answer: 'You can email, call, or chat with us using the options below.',
            ),
            const SizedBox(height: 28),
            // Contact Options
            Text('Contact Us',
                style: textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 1,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.email, color: AppColors.primary),
                    title: const Text('Email'),
                    subtitle: const Text('support@medicoapp.com'),
                    onTap: () {
                      // TODO: Implement email launch
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.phone, color: AppColors.primary),
                    title: const Text('Call Us'),
                    subtitle: const Text('+1 800 123 4567'),
                    onTap: () {
                      // TODO: Implement phone call
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.chat, color: AppColors.primary),
                    title: const Text('Live Chat'),
                    subtitle: const Text('Chat with our support team'),
                    onTap: () {
                      // TODO: Implement live chat
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            // Submit Request Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                icon: const Icon(Icons.help_outline),
                label: const Text('Submit a Request', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () {
                  // TODO: Implement submit request
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Submit request feature coming soon!')),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _FaqCard extends StatefulWidget {
  final String question;
  final String answer;
  const _FaqCard({required this.question, required this.answer});

  @override
  State<_FaqCard> createState() => _FaqCardState();
}

class _FaqCardState extends State<_FaqCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: AppColors.primary),
                ],
              ),
              if (_expanded) ...[
                const SizedBox(height: 10),
                Text(
                  widget.answer,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
} 