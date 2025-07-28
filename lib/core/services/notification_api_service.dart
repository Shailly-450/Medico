import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:medico/models/notification_item.dart';
import 'package:medico/core/config.dart';

class NotificationApiService {
  static String get baseUrl => AppConfig.apiBaseUrl;

  static Future<List<NotificationItem>> fetchNotifications(String authToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> notificationsJson = data['data'];
      return notificationsJson.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  static Future<List<NotificationItem>> fetchUnreadNotifications(String authToken) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/unread'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> notificationsJson = data['data'];
      return notificationsJson.map((json) => NotificationItem.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load unread notifications');
    }
  }

  static Future<NotificationItem> markNotificationAsRead(String authToken, String notificationId) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/$notificationId/read'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return NotificationItem.fromJson(data['data']);
    } else {
      throw Exception('Failed to mark notification as read');
    }
  }

  static Future<bool> markAllNotificationsAsRead(String authToken) async {
    final response = await http.put(
      Uri.parse('$baseUrl/notifications/read-all'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to mark all notifications as read');
    }
  }

  static Future<bool> deleteNotification(String authToken, String notificationId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/notifications/$notificationId'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to delete notification');
    }
  }

  static Future<NotificationItem> createNotification({
    required String authToken,
    required String type,
    required String title,
    required String message,
    required String recipientId,
    String? senderId,
    String priority = 'medium',
    List<String> channels = const [],
    String category = 'system',
    List<Map<String, dynamic>> actions = const [],
  }) async {
    final body = {
      'type': type,
      'title': title,
      'message': message,
      'recipientId': recipientId,
      if (senderId != null) 'senderId': senderId,
      'priority': priority,
      'channels': channels,
      'category': category,
      'actions': actions,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/notifications'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return NotificationItem.fromJson(data['data']);
    } else {
      throw Exception('Failed to create notification');
    }
  }
} 