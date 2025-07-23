import 'package:flutter/material.dart';
import '../../shared/app_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../appointments/book_appointment_screen.dart';
import '../../schedule/schedule_screen.dart';
import '../../health_records/health_records_screen.dart';
import '../../medicine_reminders/medicine_reminders_screen.dart';
import '../../test_checkups/test_checkups_screen.dart';
import '../../prescriptions/prescriptions_screen.dart';
import '../../journey_tracker/journey_tracker_screen.dart';
import '../../insurance/insurance_screen.dart';
import '../../appointments/appointment_calendar_screen.dart';
import '../../chat/chat_list_screen.dart';

class QuickAction {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const QuickAction({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}

class QuickActionCard extends StatelessWidget {
  final QuickAction action;

  const QuickActionCard({Key? key, required this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => action.screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(action.icon, color: action.color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                action.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                action.subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Quick actions list
final List<QuickAction> quickActions = [
  QuickAction(
    title: 'Appointments',
    subtitle: 'Schedule or view appointments',
    icon: Icons.calendar_today,
    color: Colors.blue,
    screen: const AppointmentCalendarScreen(),
  ),
  QuickAction(
    title: 'Medicine',
    subtitle: 'Set medicine reminders',
    icon: Icons.medication,
    color: Colors.green,
    screen: const MedicineRemindersScreen(),
  ),
  QuickAction(
    title: 'Test Checkups',
    subtitle: 'Schedule health tests',
    icon: Icons.science,
    color: Colors.purple,
    screen: const TestCheckupsScreen(),
  ),
  QuickAction(
    title: 'Health Records',
    subtitle: 'View your medical history',
    icon: Icons.folder_open,
    color: Colors.orange,
    screen: const HealthRecordsScreen(),
  ),
  QuickAction(
    title: 'Insurance',
    subtitle: 'Manage your policies',
    icon: Icons.health_and_safety,
    color: Colors.indigo,
    screen: const InsuranceScreen(),
  ),
  QuickAction(
    title: 'Chat',
    subtitle: 'Connect with doctors',
    icon: Icons.chat,
    color: Colors.teal,
    screen: const ChatListScreen(),
  ),
];
