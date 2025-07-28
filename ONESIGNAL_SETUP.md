# OneSignal Push Notifications Setup Guide

## Overview
This guide will help you set up OneSignal push notifications for your Medico Flutter app.

## Prerequisites
1. OneSignal account (sign up at https://onesignal.com)
2. Flutter development environment
3. Android Studio / Xcode for platform-specific setup

## Step 1: OneSignal Dashboard Setup

### 1.1 Create OneSignal App
1. Log in to your OneSignal dashboard
2. Click "New App/Website"
3. Choose **"Google Android FCM"** for Android only
4. **Skip Apple iOS (APNs)** for now (requires Apple Developer account)
5. Enter your app name (e.g., "Medico")

### 1.2 Get Your OneSignal App ID
1. In your OneSignal dashboard, go to Settings > Keys & IDs
2. Copy your OneSignal App ID
3. Replace `YOUR_ONESIGNAL_APP_ID` in `lib/core/services/onesignal_service.dart`

## Step 2: Android Setup

### 2.1 Firebase Console Setup
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Add your Android app to Firebase project
4. Download `google-services.json` file
5. Place it in `android/app/` directory

### 2.2 Update Android Build Files

#### Update `android/app/build.gradle.kts`:
```kotlin
android {
    defaultConfig {
        applicationId "com.yourcompany.medico"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
}

dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

#### Update `android/build.gradle.kts`:
```kotlin
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 2.3 Configure Firebase with OneSignal (Updated for 2024)
1. In Firebase Console, go to Project Settings
2. Go to "General" tab
3. Download the `google-services.json` file
4. In OneSignal dashboard, go to Settings > Keys & IDs
5. Look for "Firebase Configuration" section
6. Upload your `google-services.json` file
7. OneSignal will automatically configure the new Firebase Cloud Messaging API (V1)

**Note**: The old FCM Server Key method is deprecated as of June 2024. OneSignal now uses the new Firebase API.

## Step 3: iOS Setup (Optional - Skip if no Apple Developer Account)

> **Note**: This step requires an Apple Developer account ($99/year). Skip this if you don't have one and focus on Android testing first.

### 3.1 Apple Developer Account
1. Ensure you have an Apple Developer account
2. Create an App ID in Apple Developer Console
3. Enable Push Notifications capability

### 3.2 Generate APNs Certificate
1. In Apple Developer Console, go to Certificates
2. Create a new APNs certificate
3. Download and convert to .p12 format
4. Upload to OneSignal dashboard under Settings > Keys & IDs > APNs Configuration

### 3.3 Update iOS Configuration
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to Signing & Capabilities
4. Add "Push Notifications" capability
5. Add "Background Modes" capability and check "Remote notifications"

## Step 4: Update Your App Configuration

### 4.1 Replace OneSignal App ID
In `lib/core/services/onesignal_service.dart`, replace:
```dart
static const String _oneSignalAppId = 'YOUR_ONESIGNAL_APP_ID';
```
with your actual OneSignal App ID.

### 4.2 Test the Setup
1. Run your app on a physical device
2. Go to the Notifications screen
3. Tap "Send Test Notification"
4. You should receive a test notification

## Step 5: Sending Notifications

### 5.1 From OneSignal Dashboard
1. Go to OneSignal dashboard
2. Click "New Push"
3. Compose your message
4. Select target audience
5. Send notification

### 5.2 From Your Backend
Use OneSignal REST API to send notifications programmatically:

```bash
curl --request POST \
  --url https://onesignal.com/api/v1/notifications \
  --header 'Authorization: Basic YOUR_REST_API_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "app_id": "YOUR_ONESIGNAL_APP_ID",
    "included_segments": ["All"],
    "contents": {"en": "Your notification message"},
    "headings": {"en": "Notification Title"}
  }'
```

## Step 6: Advanced Features

### 6.1 User Segmentation
```dart
// Set user tags for segmentation
await OneSignalService.instance.setUserTags({
  'user_type': 'patient',
  'location': 'New York',
  'premium_user': 'true',
});
```

### 6.2 Custom Notification Handling
```dart
// Handle specific notification types
void _handleAppointmentNotification(String? id, Map<String, dynamic> data) {
  // Navigate to appointment details
  Navigator.pushNamed(context, '/appointment-details', arguments: id);
}
```

### 6.3 Notification Settings
```dart
// Update user notification preferences
await NotificationManager.instance.updateNotificationSettings({
  'notifications_enabled': true,
  'appointment_reminders': true,
  'medicine_reminders': true,
  'health_tips': false,
  'offers': true,
});
```

## Troubleshooting

### Common Issues

1. **Notifications not showing on Android**
   - Check if `google-services.json` is in the correct location
   - Verify FCM server key is added to OneSignal
   - Ensure app has notification permissions

2. **Notifications not showing on iOS**
   - Verify APNs certificate is uploaded to OneSignal
   - Check if Push Notifications capability is added in Xcode
   - Ensure app has notification permissions

3. **Test notifications not working**
   - Check OneSignal App ID is correct
   - Verify device is registered with OneSignal
   - Check console logs for errors

### Debug Tips

1. Enable OneSignal debug logging:
```dart
OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
```

2. Check device registration:
```dart
final playerId = await OneSignalService.instance.getPlayerId();
print('OneSignal Player ID: $playerId');
```

3. Verify notification permissions:
```dart
final isEnabled = await OneSignalService.instance.getNotificationPermissionStatus();
print('Notifications enabled: $isEnabled');
```

## Next Steps

1. **Customize Notification UI**: Update notification cards to match your app's design
2. **Add Rich Notifications**: Include images and action buttons in notifications
3. **Implement Deep Linking**: Navigate to specific screens when notifications are tapped
4. **Add Analytics**: Track notification engagement and user behavior
5. **A/B Testing**: Test different notification content and timing

## Support

- OneSignal Documentation: https://documentation.onesignal.com/
- OneSignal Support: https://onesignal.com/support
- Flutter OneSignal Plugin: https://pub.dev/packages/onesignal_flutter

## Files Modified

1. `pubspec.yaml` - Added OneSignal dependency
2. `lib/core/services/onesignal_service.dart` - OneSignal service implementation
3. `lib/core/services/notification_manager.dart` - Notification manager
4. `lib/viewmodels/notification_view_model.dart` - Updated to work with OneSignal
5. `lib/main.dart` - Initialize OneSignal
6. `android/app/src/main/AndroidManifest.xml` - Added notification permissions
7. `ios/Runner/Info.plist` - Added background modes
8. `lib/views/notifications/notification_screen.dart` - Added test button
9. `lib/views/profile/settings_screen.dart` - Integrated notification settings
10. `lib/views/notifications/widgets/test_notification_button.dart` - Test notification widget 