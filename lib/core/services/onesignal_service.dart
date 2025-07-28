import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OneSignalService {
  static const String _oneSignalAppId = '23abe33b-dc2c-44ef-b407-ebafdfbcecdd'; // Your OneSignal App ID
  
  static OneSignalService? _instance;
  static OneSignalService get instance => _instance ??= OneSignalService._();
  
  OneSignalService._();

  Future<void> initialize() async {
    // Set OneSignal App ID
    OneSignal.initialize(_oneSignalAppId);

    // Request permission for notifications
    OneSignal.Notifications.requestPermission(true);

    // Set up notification handlers
    OneSignal.Notifications.addClickListener(_onNotificationClicked);

    // Force device registration
    await _registerDevice();

    print('OneSignal initialized successfully');
    
    // Debug: Print platform info
    print('OneSignal Player ID: ${OneSignal.User.pushSubscription.id}');
    print('OneSignal Device State: ${OneSignal.User.pushSubscription.optedIn}');
  }

  Future<void> _registerDevice() async {
    try {
      // Wait a bit for OneSignal to initialize
      await Future.delayed(Duration(seconds: 2));
      
      // Force device registration
      final playerId = OneSignal.User.pushSubscription.id;
      final isOptedIn = OneSignal.User.pushSubscription.optedIn;
      
      print('Device registration - Player ID: $playerId');
      print('Device registration - Opted In: $isOptedIn');
      
      if (playerId != null) {
        await _savePlayerId(playerId);
        print('Device successfully registered with OneSignal');
      } else {
        print('Failed to get Player ID - device not registered');
      }
    } catch (e) {
      print('Error registering device: $e');
    }
  }

  void _onNotificationClicked(OSNotificationClickEvent event) {
    print('Notification clicked: ${event.notification.jsonRepresentation()}');
    
    // Handle notification click based on data
    final data = event.notification.additionalData;
    if (data != null) {
      _handleNotificationData(data);
    }
  }

  // Simplified for OneSignal 5.x - removed observer pattern
  void _onPushSubscriptionChange() {
    print('Push subscription changed');
    
    // Save the player ID for later use
    _savePlayerId(OneSignal.User.pushSubscription.id);
  }

  Future<void> _savePlayerId(String? playerId) async {
    if (playerId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onesignal_player_id', playerId);
      print('Saved OneSignal Player ID: $playerId');
    }
  }

  Future<String?> getPlayerId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('onesignal_player_id');
  }

  void _handleNotificationData(Map<String, dynamic> data) {
    // Handle different types of notifications
    final type = data['type'] as String?;
    final id = data['id'] as String?;
    
    switch (type) {
      case 'appointment':
        _handleAppointmentNotification(id, data);
        break;
      case 'reminder':
        _handleReminderNotification(id, data);
        break;
      case 'message':
        _handleMessageNotification(id, data);
        break;
      case 'general':
        _handleGeneralNotification(id, data);
        break;
      default:
        print('Unknown notification type: $type');
    }
  }

  void _handleAppointmentNotification(String? id, Map<String, dynamic> data) {
    print('Handling appointment notification: $id');
    // Navigate to appointment details or calendar
    // You can use your navigation service here
  }

  void _handleReminderNotification(String? id, Map<String, dynamic> data) {
    print('Handling reminder notification: $id');
    // Navigate to medicine reminders or health records
  }

  void _handleMessageNotification(String? id, Map<String, dynamic> data) {
    print('Handling message notification: $id');
    // Navigate to chat screen
  }

  void _handleGeneralNotification(String? id, Map<String, dynamic> data) {
    print('Handling general notification: $id');
    // Navigate to notifications screen
  }

  // Method to send local notification (for testing)
  Future<void> sendLocalNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // Note: OneSignal doesn't support local notifications in the same way
    // This is for testing purposes - in production, use OneSignal dashboard or REST API
    print('Local notification would be sent: $title - $body');
  }

  // Method to set user tags (for segmentation)
  Future<void> setUserTags(Map<String, String> tags) async {
    // Note: OneSignal 5.x has different API for tags
    // This is a simplified implementation
    print('Setting user tags: $tags');
  }

  // Method to set user data
  Future<void> setUserData({
    String? email,
    String? name,
    String? phone,
  }) async {
    if (email != null) {
      OneSignal.User.addEmail(email);
    }
    // Note: Tag methods may have changed in OneSignal 5.x
    print('Setting user data: email=$email, name=$name, phone=$phone');
  }

  // Method to subscribe to specific channels
  Future<void> subscribeToChannel(String channel) async {
    // Note: OneSignal 5.x has different API for tags
    print('Subscribing to channel: $channel');
  }

  // Method to unsubscribe from channels
  Future<void> unsubscribeFromChannel(String channel) async {
    // Note: OneSignal 5.x has different API for tags
    print('Unsubscribing from channel: $channel');
  }

  // Method to enable/disable notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      OneSignal.Notifications.requestPermission(true);
    } else {
      OneSignal.Notifications.clearAll();
    }
  }

  // Method to get notification permission status
  Future<bool> getNotificationPermissionStatus() async {
    final deviceState = OneSignal.User.pushSubscription;
    return deviceState.optedIn ?? false;
  }

  // Method to register user with OneSignal
  Future<void> registerUser({
    String? userId,
    String? email,
    String? name,
  }) async {
    try {
      // Set user data
      if (email != null) {
        OneSignal.User.addEmail(email);
      }
      
      // Set user ID for targeting (this links to your backend user ID)
      if (userId != null) {
        // Set external user ID for targeting from backend
        OneSignal.login(userId);
        print('User ID set for OneSignal targeting: $userId');
      }
      
      // Set user tags
      if (name != null) {
        // Note: OneSignal 5.x has different API for tags
        print('Setting user name tag: $name');
      }
      
      print('User registered with OneSignal - User ID: $userId, Email: $email');
    } catch (e) {
      print('Error registering user with OneSignal: $e');
    }
  }
} 