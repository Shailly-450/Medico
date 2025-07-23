import 'medicine_reminder_service.dart';
import '../../models/medicine_reminder.dart';

/// Example usage of the MedicineReminderService
/// This file demonstrates how to use the API service for medicine reminders
class MedicineReminderServiceExample {
  final MedicineReminderService _service = MedicineReminderService();

  /// Example: Get all reminders for the authenticated user
  Future<void> getAllReminders() async {
    try {
      final reminders = await _service.getReminders();
      print('Found ${reminders.length} reminders');

      for (final reminder in reminders) {
        print('Reminder: ${reminder.reminderName}');
        print('  Status: ${reminder.status}');
        print('  Frequency: ${reminder.frequencyDescription}');
        print('  Doses completed: ${reminder.dosesCompleted}');
        if (reminder.totalDoses != null) {
          print('  Total doses: ${reminder.totalDoses}');
          print(
            '  Completion: ${reminder.completionPercentage.toStringAsFixed(1)}%',
          );
        }
        print('---');
      }
    } catch (e) {
      print('Error loading reminders: $e');
    }
  }

  /// Example: Create a new reminder
  Future<void> createNewReminder() async {
    try {
      final reminder = await _service.createReminder(
        medicineId: 'medicine_123',
        reminderName: 'Morning Vitamin D',
        frequency: ReminderFrequency.daily,
        dosesPerDay: 1,
        reminderTimes: [
          DateTime.now().copyWith(
            hour: 8,
            minute: 0,
            second: 0,
            millisecond: 0,
          ),
        ],
        startDate: DateTime.now(),
        instructions: 'Take with breakfast',
        takeWithFood: true,
        hasNotifications: true,
        userId: 'YOUR_USER_ID_HERE', // <-- required argument
      );

      print('Created reminder: ${reminder.reminderName}');
      print('Reminder ID: ${reminder.id}');
    } catch (e) {
      print('Error creating reminder: $e');
    }
  }

  /// Example: Mark a dose as taken
  Future<void> markDoseAsTaken(String reminderId) async {
    try {
      final updatedReminder = await _service.markDoseTaken(reminderId);
      print('Marked dose as taken for: ${updatedReminder.reminderName}');
      print('Doses completed: ${updatedReminder.dosesCompleted}');

      if (updatedReminder.isCompleted) {
        print('Reminder course completed!');
      }
    } catch (e) {
      print('Error marking dose as taken: $e');
    }
  }

  /// Example: Get today's reminders
  Future<void> getTodayReminders() async {
    try {
      final todayReminders = await _service.getTodayReminders();
      print('Today\'s reminders: ${todayReminders.length}');

      for (final reminder in todayReminders) {
        print('${reminder.reminderName} - ${reminder.frequencyDescription}');
        if (reminder.isDueNow) {
          print('  ⚠️  DUE NOW!');
        }
      }
    } catch (e) {
      print('Error loading today\'s reminders: $e');
    }
  }

  /// Example: Get overdue reminders
  Future<void> getOverdueReminders() async {
    try {
      final overdueReminders = await _service.getOverdueReminders();
      print('Overdue reminders: ${overdueReminders.length}');

      for (final reminder in overdueReminders) {
        print('⚠️  ${reminder.reminderName} is overdue');
        print('  Next reminder: ${reminder.nextReminderTime}');
      }
    } catch (e) {
      print('Error loading overdue reminders: $e');
    }
  }

  /// Example: Update a reminder
  Future<void> updateReminder(String reminderId) async {
    try {
      final updatedReminder = await _service.updateReminder(
        reminderId,
        reminderName: 'Updated Reminder Name',
        instructions: 'Updated instructions',
        hasNotifications: false,
      );

      print('Updated reminder: ${updatedReminder.reminderName}');
    } catch (e) {
      print('Error updating reminder: $e');
    }
  }

  /// Example: Pause and resume a reminder
  Future<void> pauseAndResumeReminder(String reminderId) async {
    try {
      // Pause the reminder
      final pausedReminder = await _service.pauseReminder(reminderId);
      print('Paused reminder: ${pausedReminder.reminderName}');
      print('Status: ${pausedReminder.status}');

      // Wait a bit
      await Future.delayed(const Duration(seconds: 2));

      // Resume the reminder
      final resumedReminder = await _service.resumeReminder(reminderId);
      print('Resumed reminder: ${resumedReminder.reminderName}');
      print('Status: ${resumedReminder.status}');
    } catch (e) {
      print('Error pausing/resuming reminder: $e');
    }
  }

  /// Example: Delete a reminder
  Future<void> deleteReminder(String reminderId) async {
    try {
      final success = await _service.deleteReminder(reminderId);
      if (success) {
        print('Reminder deleted successfully');
      } else {
        print('Failed to delete reminder');
      }
    } catch (e) {
      print('Error deleting reminder: $e');
    }
  }

  /// Example: Get reminder statistics
  Future<void> getReminderStatistics() async {
    try {
      final stats = await _service.getReminderStatistics();
      print('Reminder Statistics:');
      print('  Total reminders: ${stats['totalReminders']}');
      print('  Active reminders: ${stats['activeReminders']}');
      print('  Completed today: ${stats['completedToday']}');
      print('  Overdue: ${stats['overdue']}');
      print('  Compliance rate: ${stats['complianceRate']}%');
    } catch (e) {
      print('Error loading statistics: $e');
    }
  }

  /// Example: Search reminders
  Future<void> searchReminders(String query) async {
    try {
      final results = await _service.searchReminders(query);
      print('Search results for "$query": ${results.length} reminders');

      for (final reminder in results) {
        print('  ${reminder.reminderName}');
      }
    } catch (e) {
      print('Error searching reminders: $e');
    }
  }
}

/// API Endpoints Summary:
/// 
/// GET /api/reminders - Get all reminders for authenticated user
/// GET /api/reminders/{id} - Get specific reminder by ID
/// POST /api/reminders - Create new reminder
/// PUT /api/reminders/{id} - Update existing reminder
/// DELETE /api/reminders/{id} - Delete reminder
/// 
/// POST /api/reminders/{id}/take-dose - Mark dose as taken
/// POST /api/reminders/{id}/skip-dose - Mark dose as skipped
/// POST /api/reminders/{id}/pause - Pause reminder
/// POST /api/reminders/{id}/resume - Resume reminder
/// 
/// GET /api/reminders/today - Get today's reminders
/// GET /api/reminders/upcoming?days=7 - Get upcoming reminders
/// GET /api/reminders/overdue - Get overdue reminders
/// GET /api/reminders/statistics - Get reminder statistics
/// GET /api/reminders/search?q=query - Search reminders
/// 
/// All endpoints require authentication via Bearer token in Authorization header 