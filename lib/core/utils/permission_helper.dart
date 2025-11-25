import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Helper class for checking and requesting notification permissions
class PermissionHelper {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  /// Check if notification permission is granted
  static Future<bool> hasNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final granted = await androidImpl.areNotificationsEnabled();
        return granted ?? false;
      }
      return true; // Assume granted if can't check
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    print('🔐 [PermissionHelper] Requesting notification permission');
    
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        final granted = await androidImpl.requestNotificationsPermission();
        print('🔐 [PermissionHelper] Android notification permission granted: $granted');
        return granted ?? false;
      }
      return true;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      
      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
      
      print('🔐 [PermissionHelper] iOS notification permission granted: $granted');
      return granted;
    }
    return true;
  }

  /// Check if exact alarm permission is granted (Android 12+)
  static Future<bool> hasExactAlarmPermission() async {
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImpl != null) {
        // Note: This requires Android SDK 31+ (Android 12+)
        // The package doesn't provide a direct method to check this yet
        // We'll assume it's granted and rely on the error handling in scheduleDailyReminder
        return true;
      }
    }
    return true;
  }

  /// Show dialog to guide user to settings if permission is denied
  static Future<void> showPermissionDeniedDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Permission Required'),
        content: const Text(
          'To receive daily reminders and group notifications, please enable notifications in Settings.\n\n'
          'Settings > Apps > Monie > Notifications',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open app settings
              // Use url_launcher or app_settings package
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to guide user to enable exact alarms (Android 12+)
  static Future<void> showExactAlarmDialog(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exact Alarm Permission'),
        content: const Text(
          'For precise daily reminders at 22:10, please enable "Alarms & Reminders" permission.\n\n'
          'Settings > Apps > Monie > Alarms & Reminders > Allow\n\n'
          'Without this, notifications may be delayed by up to 15 minutes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Open app settings for alarms
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check all required permissions and return a summary
  static Future<Map<String, bool>> checkAllPermissions() async {
    final notificationPermission = await hasNotificationPermission();
    final exactAlarmPermission = await hasExactAlarmPermission();

    print('🔐 [PermissionHelper] Permission Summary:');
    print('   - Notifications: ${notificationPermission ? '✅' : '❌'}');
    print('   - Exact Alarms: ${exactAlarmPermission ? '✅' : '⚠️'}');

    return {
      'notifications': notificationPermission,
      'exactAlarms': exactAlarmPermission,
    };
  }

  /// Request all required permissions
  static Future<bool> requestAllPermissions() async {
    print('🔐 [PermissionHelper] Requesting all permissions...');
    
    final notificationGranted = await requestNotificationPermission();
    
    if (!notificationGranted) {
      print('❌ [PermissionHelper] Notification permission denied');
      return false;
    }
    
    // Exact alarm permission is automatically checked when scheduling
    // No need to explicitly request it here
    
    print('✅ [PermissionHelper] All permissions granted');
    return true;
  }
}

