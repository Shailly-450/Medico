import 'package:flutter/material.dart';
import '../../shared/app_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../appointments/book_appointment_screen.dart';
import '../../appointments/appointment_calendar_screen.dart';
import '../../health_records/health_records_screen.dart';

class QuickActionCard extends StatelessWidget {
  final Map<String, dynamic> action;

  const QuickActionCard({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppCard(
      border:
          Border.all(color: AppColors.secondary.withOpacity(0.8), width: 1.2),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 6),
      margin: const EdgeInsets.only(bottom: 0),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (action['title'] == 'Book Appointment') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const BookAppointmentScreen()),
            );
          } else if (action['title'] == 'Calendar View') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const AppointmentCalendarScreen()),
            );
          } else if (action['title'] == 'Health Records') {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HealthRecordsScreen()),
            );
          }
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: action['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                action['icon'],
                color: action['color'],
                size: 28,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              action['title'],
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
