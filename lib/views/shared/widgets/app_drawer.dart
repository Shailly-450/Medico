import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../appointments/appointment_calendar_screen.dart';
import '../../medicine_reminders/medicine_reminders_screen.dart';
import '../../test_checkups/test_checkups_screen.dart';
import '../../health_records/health_records_screen.dart';
import '../../insurance/insurance_screen.dart';
import '../../chat/chat_list_screen.dart';
import '../../ai_symptom/ai_symptom_chat_screen.dart';
import '../../journey_tracker/journey_tracker_screen.dart';
import '../../workflow/medical_workflow_screen.dart';

import '../../invoices/invoices_screen.dart';
import '../../testing/image_loading_test_screen.dart';
import '../../testing/order_api_diagnostic_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: AppColors.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.primary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Patient ID: P12345',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.smart_toy,
            title: 'AI Symptom Check',
            screen: const AISymptomChatScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.calendar_today,
            title: 'Appointments',
            screen: const AppointmentCalendarScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.timeline,
            title: 'Journey Tracker',
            screen: const JourneyTrackerScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.account_tree,
            title: 'Medical Workflow',
            screen: const MedicalWorkflowScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.medication,
            title: 'Medicine Reminders',
            screen: const MedicineRemindersScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.science,
            title: 'Test Checkups',
            screen: const TestCheckupsScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.folder,
            title: 'Health Records',
            screen: const HealthRecordsScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.receipt,
            title: 'Invoices',
            screen: const InvoicesScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.image,
            title: 'Image Loading Test',
            screen: const ImageLoadingTestScreen(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.bug_report,
            title: 'Order API Diagnostic',
            screen: const OrderApiDiagnosticScreen(),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () {
              // Handle logout
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Close drawer
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => screen),
        );
      },
    );
  }
}
