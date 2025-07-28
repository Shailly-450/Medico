import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/notification_item.dart';
import '../core/services/notification_manager.dart';
import '../core/services/notification_sender_service.dart';
import '../core/services/notification_api_service.dart';

class NotificationViewModel extends BaseViewModel {
  List<NotificationItem> notifications = [];

  @override
  void init() {
    print('NotificationViewModel: Initializing...');
    // _loadDummyData(); // Remove dummy data for production
    NotificationManager.instance.setNotificationViewModel(this);
    print(
        'NotificationViewModel: Loaded  [1m${notifications.length} [0m notifications');
    print('NotificationViewModel: Unread count: $unreadCount');
    notifyListeners();
  }

  // Remove _loadDummyData and all references to old NotificationType values and imageUrl

  void markAsRead(String notificationId) {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = NotificationItem(
        id: notifications[index].id,
        title: notifications[index].title,
        message: notifications[index].message,
        timestamp: notifications[index].timestamp,
        type: notifications[index].type,
        isRead: true,
        data: notifications[index].data,
      );
      notifyListeners();
    }
  }

  void markAllAsRead() {
    notifications = notifications
        .map((notification) => NotificationItem(
              id: notification.id,
              title: notification.title,
              message: notification.message,
              timestamp: notification.timestamp,
              type: notification.type,
              isRead: true,
              data: notification.data,
            ))
        .toList();
    notifyListeners();
  }

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  void deleteNotification(String notificationId) {
    notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Method to add new notification from OneSignal
  void addNotification(NotificationItem notification) {
    notifications.insert(0, notification);
    notifyListeners();
  }

  // Method to send test notification
  Future<void> sendTestNotification() async {
    await NotificationManager.instance.sendTestNotification();
  }

  // Method to get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    return await NotificationManager.instance.getNotificationSettings();
  }

  // Method to update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    await NotificationManager.instance.updateNotificationSettings(settings);
  }

  // Method to send push notification to specific user
  Future<bool> sendPushNotificationToUser({
    required String userId,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    return await NotificationSenderService.sendToUser(
      userId: userId,
      title: title,
      message: message,
      type: type,
      data: data,
    );
  }

  // Method to send push notification to all users
  Future<bool> sendPushNotificationToAll({
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    return await NotificationSenderService.sendToAll(
      title: title,
      message: message,
      type: type,
      data: data,
    );
  }

  // Method to send push notification to users with specific tags
  Future<bool> sendPushNotificationToUsersWithTags({
    required Map<String, String> tags,
    required String title,
    required String message,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) async {
    return await NotificationSenderService.sendToUsersWithTags(
      tags: tags,
      title: title,
      message: message,
      type: type,
      data: data,
    );
  }

  Future<void> fetchNotifications(String authToken) async {
    notifications = await NotificationApiService.fetchNotifications(authToken);
    notifyListeners();
  }

  Future<void> fetchUnreadNotifications(String authToken) async {
    notifications = await NotificationApiService.fetchUnreadNotifications(authToken);
    notifyListeners();
  }

  Future<void> markNotificationAsReadOnServer(String authToken, String notificationId) async {
    try {
      final updatedNotification = await NotificationApiService.markNotificationAsRead(authToken, notificationId);
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index] = updatedNotification;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      // Fallback to local update if server call fails
      markAsRead(notificationId);
    }
  }

  Future<void> markAllAsReadOnServer(String authToken) async {
    try {
      final success = await NotificationApiService.markAllNotificationsAsRead(authToken);
      if (success) {
        markAllAsRead(); // Locally mark all as read
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
      markAllAsRead(); // Fallback to local update
    }
  }

  Future<void> deleteNotificationOnServer(String authToken, String notificationId) async {
    try {
      final success = await NotificationApiService.deleteNotification(authToken, notificationId);
      if (success) {
        deleteNotification(notificationId); // Locally remove the notification
      }
    } catch (e) {
      print('Error deleting notification: $e');
      deleteNotification(notificationId); // Fallback to local deletion
    }
  }

  Future<NotificationItem?> createNotificationOnServer({
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
    try {
      final newNotification = await NotificationApiService.createNotification(
        authToken: authToken,
        type: type,
        title: title,
        message: message,
        recipientId: recipientId,
        senderId: senderId,
        priority: priority,
        channels: channels,
        category: category,
        actions: actions,
      );
      
      // Add to local list
      addNotification(newNotification);
      return newNotification;
    } catch (e) {
      print('Error creating notification: $e');
      return null;
    }
  }
}
