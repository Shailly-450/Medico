import '../../models/medicine_reminder.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';
import 'auth_service.dart';

class MedicineReminderService {
  final String _baseUrl = AppConfig.apiBaseUrl;

  Map<String, String> get _authHeaders {
    final token = AuthService.accessToken;
    if (token == null) {
      throw Exception('User not authenticated');
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all reminders for the authenticated user
  Future<List<MedicineReminder>> getReminders() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/medicine-reminders'),
        headers: _authHeaders,
      );
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
  }) async {
    try {
      // Convert frequency enum to string format expected by backend
      String frequencyString;
      switch (frequency) {
        case ReminderFrequency.once:
          frequencyString = 'once';
          break;
        case ReminderFrequency.daily:
          frequencyString = 'daily';
          break;
        case ReminderFrequency.everyOtherDay:
          frequencyString = 'everyOtherDay';
          break;
        case ReminderFrequency.weekly:
          frequencyString = 'weekly';
          break;
        case ReminderFrequency.biWeekly:
          frequencyString = 'biWeekly';
          break;
        case ReminderFrequency.monthly:
          frequencyString = 'monthly';
          break;
        case ReminderFrequency.asNeeded:
          frequencyString = 'asNeeded';
          break;
        case ReminderFrequency.custom:
          frequencyString = 'custom';
          break;
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/medicine-reminders'),
        body: json.encode({
          'reminderName': reminderName,
          'frequency': frequencyString,
          'dosesPerDay': dosesPerDay,
          'startDate': startDate.toIso8601String(),
          'reminderTimes': reminderTimes.map((dt) => dt.toIso8601String()).toList(),
          'instructions': instructions,
          'takeWithFood': takeWithFood,
          'takeWithWater': takeWithWater,
          'isActive': true,
        }),
        headers: _authHeaders,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return MedicineReminder.fromJson(json.decode(response.body));
      }
      throw Exception('Failed to create reminder: ${response.statusCode} - ${response.body}');
    } catch (e) {
      throw Exception('Error creating reminder: $e');
    }
  }

  /// Mark a dose as taken
  Future<MedicineReminder> markDoseTaken(String reminderId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/medicine-reminders/$reminderId/take-dose'),
        headers: _authHeaders,
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
      final response = await http.get(
        Uri.parse('$_baseUrl/medicine-reminders/today'),
        headers: _authHeaders,
      );
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
      final response = await http.get(
        Uri.parse('$_baseUrl/medicine-reminders/overdue'),
        headers: _authHeaders,
      );
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
      if (takeWithFood != null) updates['takeWithFood'] = takeWithFood;
      if (takeWithWater != null) updates['takeWithWater'] = takeWithWater;
      if (isActive != null) updates['isActive'] = isActive;

      final response = await http.put(
        Uri.parse('$_baseUrl/medicine-reminders/$reminderId'),
        body: json.encode(updates),
        headers: _authHeaders,
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
        Uri.parse('$_baseUrl/medicine-reminders/$reminderId/pause'),
        headers: _authHeaders,
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
        Uri.parse('$_baseUrl/medicine-reminders/$reminderId/resume'),
        headers: _authHeaders,
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
        Uri.parse('$_baseUrl/medicine-reminders/$reminderId/skip-dose'),
        headers: _authHeaders,
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
        Uri.parse('$_baseUrl/medicine-reminders/$reminderId'),
        headers: _authHeaders,
      );
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting reminder: $e');
    }
  }

  /// Get reminder statistics
  Future<Map<String, dynamic>> getReminderStatistics() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/medicine-reminders/statistics'),
        headers: _authHeaders,
      );
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
        Uri.parse('$_baseUrl/medicine-reminders/search?q=$query'),
        headers: _authHeaders,
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
