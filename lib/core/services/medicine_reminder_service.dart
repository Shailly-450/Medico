import '../../models/medicine_reminder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MedicineReminderService {
  final String _baseUrl =
      'YOUR_API_BASE_URL'; // Replace with your actual API URL

  /// Get all reminders for the authenticated user
  Future<List<MedicineReminder>> getReminders() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/reminders'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MedicineReminder.fromJson(json)).toList();
      }
      throw Exception('Failed to load reminders');
    } catch (e) {
      throw Exception('Error getting reminders: $e');
    }
  }

  /// Create a new reminder
  Future<MedicineReminder> createReminder({
    required String medicineId,
    required String reminderName,
    required ReminderFrequency frequency,
    required int dosesPerDay,
    required List<DateTime> reminderTimes,
    required DateTime startDate,
    DateTime? endDate,
    int? totalDoses,
    String? instructions,
    bool takeWithFood = false,
    bool takeWithWater = true,
    String? customFrequencyDescription,
    int? customIntervalDays,
    List<int>? skipDays,
    bool hasNotifications = true,
    NotificationSettings? notificationSettings,
    bool reminderVibration = true,
    required String userId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reminders'),
        body: json.encode({
          'medicineId': medicineId,
          'reminderName': reminderName,
          'frequency': frequency.toString(),
          'dosesPerDay': dosesPerDay,
          'reminderTimes':
              reminderTimes.map((dt) => dt.toIso8601String()).toList(),
          'startDate': startDate.toIso8601String(),
          'instructions': instructions,
          'takeWithFood': takeWithFood,
          'hasNotifications': hasNotifications,
          'userId': userId,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 201) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create reminder');
    } catch (e) {
      throw Exception('Error creating reminder: $e');
    }
  }

  /// Mark a dose as taken
  Future<MedicineReminder> markDoseTaken(String reminderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reminders/$reminderId/take-dose'),
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to mark dose as taken');
    } catch (e) {
      throw Exception('Error marking dose as taken: $e');
    }
  }

  /// Get today's reminders
  Future<List<MedicineReminder>> getTodayReminders() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/api/reminders/today'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MedicineReminder.fromJson(json)).toList();
      }
      throw Exception('Failed to load today\'s reminders');
    } catch (e) {
      throw Exception('Error getting today\'s reminders: $e');
    }
  }

  /// Get overdue reminders
  Future<List<MedicineReminder>> getOverdueReminders() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/api/reminders/overdue'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MedicineReminder.fromJson(json)).toList();
      }
      throw Exception('Failed to load overdue reminders');
    } catch (e) {
      throw Exception('Error getting overdue reminders: $e');
    }
  }

  /// Update an existing reminder
  Future<MedicineReminder> updateReminder(
    String reminderId, {
    String? reminderName,
    ReminderFrequency? frequency,
    int? dosesPerDay,
    List<DateTime>? reminderTimes,
    DateTime? startDate,
    DateTime? endDate,
    int? totalDoses,
    int? dosesCompleted,
    bool? isActive,
    ReminderStatus? status,
    String? instructions,
    bool? takeWithFood,
    bool? takeWithWater,
    String? customFrequencyDescription,
    int? customIntervalDays,
    List<int>? skipDays,
    bool? hasNotifications,
    NotificationSettings? notificationSettings,
    bool? reminderVibration,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (reminderName != null) updates['reminderName'] = reminderName;
      if (instructions != null) updates['instructions'] = instructions;
      if (hasNotifications != null)
        updates['hasNotifications'] = hasNotifications;

      final response = await http.put(
        Uri.parse('$_baseUrl/api/reminders/$reminderId'),
        body: json.encode(updates),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to update reminder');
    } catch (e) {
      throw Exception('Error updating reminder: $e');
    }
  }

  /// Pause a reminder
  Future<MedicineReminder> pauseReminder(String reminderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reminders/$reminderId/pause'),
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to pause reminder');
    } catch (e) {
      throw Exception('Error pausing reminder: $e');
    }
  }

  /// Resume a paused reminder
  Future<MedicineReminder> resumeReminder(String reminderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reminders/$reminderId/resume'),
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to resume reminder');
    } catch (e) {
      throw Exception('Error resuming reminder: $e');
    }
  }

  /// Mark a dose as skipped
  Future<MedicineReminder> markDoseSkipped(String reminderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/reminders/$reminderId/skip-dose'),
      );

      if (response.statusCode == 200) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to mark dose as skipped');
    } catch (e) {
      throw Exception('Error marking dose as skipped: $e');
    }
  }

  /// Delete a reminder
  Future<bool> deleteReminder(String reminderId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/reminders/$reminderId'),
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting reminder: $e');
    }
  }

  /// Get reminder statistics
  Future<Map<String, dynamic>> getReminderStatistics() async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl/api/reminders/statistics'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      throw Exception('Failed to load reminder statistics');
    } catch (e) {
      throw Exception('Error getting reminder statistics: $e');
    }
  }

  /// Search reminders
  Future<List<MedicineReminder>> searchReminders(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/reminders/search?q=$query'),
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => MedicineReminder.fromJson(json)).toList();
      }
      throw Exception('Failed to search reminders');
    } catch (e) {
      throw Exception('Error searching reminders: $e');
    }
  }
}
