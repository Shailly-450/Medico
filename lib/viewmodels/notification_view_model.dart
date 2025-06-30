import 'package:flutter/material.dart';
import '../core/viewmodels/base_view_model.dart';
import '../models/notification_item.dart';

class NotificationViewModel extends BaseViewModel {
  List<NotificationItem> notifications = [];

  @override
  void init() {
    print('NotificationViewModel: Initializing...');
    _loadDummyData();
    print(
        'NotificationViewModel: Loaded ${notifications.length} notifications');
    print('NotificationViewModel: Unread count: $unreadCount');
    notifyListeners();
  }

  void _loadDummyData() {
    // Dummy notifications
    notifications = [
      NotificationItem(
        id: '1',
        title: 'Appointment Reminder',
        message:
            'Your appointment with Dr. Sarah Johnson is scheduled for tomorrow at 2:00 PM',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: NotificationType.appointment,
        isRead: false,
      ),
      NotificationItem(
        id: '2',
        title: 'Special Offer',
        message: 'Get 20% off on your next consultation with any cardiologist',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        type: NotificationType.offer,
        isRead: false,
      ),
      NotificationItem(
        id: '3',
        title: 'New Hospital Added',
        message: 'City General Hospital is now available in your area',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.general,
        isRead: true,
      ),
      NotificationItem(
        id: '4',
        title: 'Medicine Reminder',
        message: 'Time to take your evening medication',
        timestamp: DateTime.now().subtract(const Duration(days: 2)),
        type: NotificationType.reminder,
        isRead: true,
      ),
      NotificationItem(
        id: '5',
        title: 'Lab Results Ready',
        message: 'Your blood test results are now available',
        timestamp: DateTime.now().subtract(const Duration(days: 3)),
        type: NotificationType.general,
        isRead: true,
      ),
      NotificationItem(
        id: '6',
        title: 'Video Call Scheduled',
        message:
            'Your video consultation with Dr. Emily Brown starts in 15 minutes',
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        type: NotificationType.appointment,
        isRead: false,
      ),
      NotificationItem(
        id: '7',
        title: 'Health Tips',
        message:
            'Stay hydrated! Drink 8 glasses of water daily for better health',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        type: NotificationType.general,
        isRead: false,
      ),
      NotificationItem(
        id: '8',
        title: 'Prescription Renewal',
        message:
            'Your prescription for blood pressure medication needs renewal',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: NotificationType.reminder,
        isRead: true,
      ),
      NotificationItem(
        id: '9',
        title: 'Discount Alert',
        message: '50% off on dental cleaning services this week only!',
        timestamp: DateTime.now().subtract(const Duration(hours: 8)),
        type: NotificationType.offer,
        isRead: false,
      ),
      NotificationItem(
        id: '10',
        title: 'Emergency Contact',
        message: 'Dr. Michael Chen is available for emergency consultations',
        timestamp: DateTime.now().subtract(const Duration(hours: 12)),
        type: NotificationType.general,
        isRead: true,
      ),
    ];
  }

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
        imageUrl: notifications[index].imageUrl,
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
              imageUrl: notification.imageUrl,
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
}
