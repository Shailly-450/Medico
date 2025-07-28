import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medico/models/notification_item.dart';

class NotificationSenderService {
  static const String _oneSignalAppId = '23abe33b-dc2c-44ef-b407-ebafdfbcecdd';
  static const String _restApiKey = 'os_v2_app_eov6go64frco7nah5ox57phm3wspcdno2jguggv4issuxv3abfjh52pn4y5hrgbftll7zah7kxvr7zedzql2s3krc2cytiuizg5zrvq'; // Get this from OneSignal dashboard
  
  // Send notification to specific user
  static Future<bool> sendToUser({
    required String userId,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'app_id': _oneSignalAppId,
        'include_external_user_ids': [userId],
        'channel_for_external_user_ids': 'push',
        'headings': {'en': title},
        'contents': {'en': message},
        'isAnyWeb': false,
        'isEmail': false,
        'isSms': false,
        'data': {
          'type': _getNotificationTypeString(type),
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...?data,
        },
      };

      print('Sending OneSignal notification payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(payload),
      );

      print('OneSignal response status: ${response.statusCode}');
      print('OneSignal response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Notification sent successfully to user: $userId');
        return true;
      } else {
        print('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send notification to all users
  static Future<bool> sendToAll({
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'app_id': _oneSignalAppId,
        'included_segments': ['All'],
        'channel_for_external_user_ids': 'push',
        'headings': {'en': title},
        'contents': {'en': message},
        'isAnyWeb': false,
        'isEmail': false,
        'isSms': false,
        'data': {
          'type': _getNotificationTypeString(type),
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...?data,
        },
      };

      print('Sending OneSignal notification payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(payload),
      );

      print('OneSignal response status: ${response.statusCode}');
      print('OneSignal response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Notification sent successfully to all users');
        return true;
      } else {
        print('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  // Send notification to users with specific tags
  static Future<bool> sendToUsersWithTags({
    required Map<String, String> tags,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    try {
      final payload = {
        'app_id': _oneSignalAppId,
        'filters': tags.entries.map((entry) => {
          'field': 'tag',
          'key': entry.key,
          'relation': '=',
          'value': entry.value,
        }).toList(),
        'channel_for_external_user_ids': 'push',
        'headings': {'en': title},
        'contents': {'en': message},
        'isAnyWeb': false,
        'isEmail': false,
        'isSms': false,
        'data': {
          'type': _getNotificationTypeString(type),
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          ...?data,
        },
      };

      print('Sending OneSignal notification payload: ${jsonEncode(payload)}');

      final response = await http.post(
        Uri.parse('https://onesignal.com/api/v1/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Basic $_restApiKey',
        },
        body: jsonEncode(payload),
      );

      print('OneSignal response status: ${response.statusCode}');
      print('OneSignal response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Notification sent successfully to users with tags: $tags');
        return true;
      } else {
        print('Failed to send notification: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending notification: $e');
      return false;
    }
  }

  static String _getNotificationTypeString(NotificationType type) {
    switch (type) {
      case NotificationType.appointment_reminder:
        return 'appointment_reminder';
      case NotificationType.appointment_confirmed:
        return 'appointment_confirmed';
      case NotificationType.appointment_cancelled:
        return 'appointment_cancelled';
      case NotificationType.prescription_ready:
        return 'prescription_ready';
      case NotificationType.test_result_ready:
        return 'test_result_ready';
      case NotificationType.doctor_message:
        return 'doctor_message';
      case NotificationType.system_alert:
        return 'system_alert';
      case NotificationType.payment_reminder:
        return 'payment_reminder';
      case NotificationType.video_call_invite:
        return 'video_call_invite';
      case NotificationType.health_reminder:
        return 'health_reminder';
      case NotificationType.order_confirmed:
        return 'order_confirmed';
      case NotificationType.order_status_updated:
        return 'order_status_updated';
      case NotificationType.general:
      default:
        return 'general';
    }
  }
} 