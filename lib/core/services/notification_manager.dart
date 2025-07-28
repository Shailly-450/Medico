import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../../viewmodels/notification_view_model.dart';
import '../../models/notification_item.dart';
import 'onesignal_service.dart';

class NotificationManager {
  static NotificationManager? _instance;
  static NotificationManager get instance => _instance ??= NotificationManager._();
  
  NotificationManager._();

  NotificationViewModel? _notificationViewModel;

  void setNotificationViewModel(NotificationViewModel viewModel) {
    _notificationViewModel = viewModel;
  }

  // Method to handle incoming notifications and add them to the local notification list
  void handleIncomingNotification(OSNotification notification) {
    final data = notification.additionalData;
    final type = _getNotificationType(data?['type'] as String?);
    
    final notificationItem = NotificationItem(
      id: data?['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: notification.title ?? 'Notification',
      message: notification.body ?? '',
      timestamp: DateTime.now(),
      type: type,
      isRead: false,
      data: data,
    );

    // Add to local notification list
    _notificationViewModel?.addNotification(notificationItem);
  }

  NotificationType _getNotificationType(String? type) {
    switch (type) {
      case 'appointment_reminder':
        return NotificationType.appointment_reminder;
      case 'appointment_confirmed':
        return NotificationType.appointment_confirmed;
      case 'appointment_cancelled':
        return NotificationType.appointment_cancelled;
      case 'prescription_ready':
        return NotificationType.prescription_ready;
      case 'test_result_ready':
        return NotificationType.test_result_ready;
      case 'doctor_message':
        return NotificationType.doctor_message;
      case 'system_alert':
        return NotificationType.system_alert;
      case 'payment_reminder':
        return NotificationType.payment_reminder;
      case 'video_call_invite':
        return NotificationType.video_call_invite;
      case 'health_reminder':
        return NotificationType.health_reminder;
      case 'general':
      default:
        return NotificationType.general;
    }
  }

  // Method to send test notification
  Future<void> sendTestNotification() async {
    await OneSignalService.instance.sendLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Medico app',
      data: {
        'type': 'general',
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
  }

  // Method to set user preferences for notifications
  Future<void> setUserNotificationPreferences({
    bool appointmentReminders = true,
    bool medicineReminders = true,
    bool healthTips = true,
    bool offers = true,
  }) async {
    final tags = <String, String>{};
    
    if (appointmentReminders) tags['appointment_reminders'] = 'true';
    if (medicineReminders) tags['medicine_reminders'] = 'true';
    if (healthTips) tags['health_tips'] = 'true';
    if (offers) tags['offers'] = 'true';

    await OneSignalService.instance.setUserTags(tags);
  }

  // Method to subscribe to specific notification channels
  Future<void> subscribeToChannels(List<String> channels) async {
    for (final channel in channels) {
      await OneSignalService.instance.subscribeToChannel(channel);
    }
  }

  // Method to unsubscribe from channels
  Future<void> unsubscribeFromChannels(List<String> channels) async {
    for (final channel in channels) {
      await OneSignalService.instance.unsubscribeFromChannel(channel);
    }
  }

  // Method to get current notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final isEnabled = await OneSignalService.instance.getNotificationPermissionStatus();
    
    // You can add more settings here based on your needs
    return {
      'notifications_enabled': isEnabled,
      'appointment_reminders': true, // You can store these in SharedPreferences
      'medicine_reminders': true,
      'health_tips': true,
      'offers': true,
    };
  }

  // Method to update notification settings
  Future<void> updateNotificationSettings(Map<String, bool> settings) async {
    if (settings['notifications_enabled'] == false) {
      await OneSignalService.instance.setNotificationsEnabled(false);
    } else {
      await OneSignalService.instance.setNotificationsEnabled(true);
      await setUserNotificationPreferences(
        appointmentReminders: settings['appointment_reminders'] ?? true,
        medicineReminders: settings['medicine_reminders'] ?? true,
        healthTips: settings['health_tips'] ?? true,
        offers: settings['offers'] ?? true,
      );
    }
  }
} 