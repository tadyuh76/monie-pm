import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service to handle push notifications and local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  bool _initialized = false;

  // Notification ID constants
  static const int dailyReminderId = 1;
  static const int groupExpenseIdStart = 1000;
  static const int groupExpenseIdEnd = 9999;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Initialize timezone data
    tz.initializeTimeZones();
    
    // Set local timezone - use device's local timezone
    // The timezone package will use the system's default timezone
    // For scheduling, we'll use tz.local which represents the device's timezone

    // Request permissions for iOS
    final NotificationSettings settings =
        await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Create notification channel for Android
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'monie_notifications',
        'Monie Notifications',
        description: 'Notifications for group transactions and reminders',
        importance: Importance.high,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // Setup FCM message handlers
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

      // Handle notification when app is opened from terminated state
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleBackgroundMessage(initialMessage);
      }

      _initialized = true;
    }
  }

  /// Get FCM token for the device
  Future<String?> getToken() async {
    try {
      print('🔑 [NotificationService] Requesting FCM token...');
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        print('✅ [NotificationService] FCM token obtained: ${token.substring(0, 20)}...');
      } else {
        print('⚠️ [NotificationService] FCM token is null');
      }
      return token;
    } catch (e) {
      print('❌ [NotificationService] Failed to get FCM token: $e');
      return null;
    }
  }

  /// Schedule daily reminder at 22:10 (10:10 PM)
  Future<void> scheduleDailyReminder() async {
    print('🔔 [NotificationService] scheduleDailyReminder() called');
    
    if (!_initialized) {
      print('🔔 [NotificationService] Not initialized, initializing now...');
      await initialize();
    }

    try {
      // Check permission status first
      final hasPermission = await _checkNotificationPermission();
      if (!hasPermission) {
        print('⚠️ [NotificationService] Notification permission not granted!');
        print('⚠️ Please enable notifications in Settings > Apps > Monie > Notifications');
        return;
      }

      // Cancel ALL pending notifications to clear any corrupted ones
      await _localNotifications.cancelAll();
      print('🔔 [NotificationService] Cancelled all pending notifications');

      // Get accurate timezone using flutter_native_timezone
      final String timezoneName = await _getLocalTimezoneName();
      print('🔔 [NotificationService] Detected timezone: $timezoneName');
      
      final localTz = tz.getLocation(timezoneName);
      final now = DateTime.now();
      final nowTz = tz.TZDateTime.from(now, localTz);
      
      print('🔔 [NotificationService] Current time: $nowTz');
      
      // Schedule for 22:10 (10:10 PM) every day in device's local timezone
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        localTz,
        now.year,
        now.month,
        now.day,
        01, // 10:10 PM
        35,
      );

      // If the time has already passed today, schedule for tomorrow
      if (scheduledDate.isBefore(nowTz)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        print('🔔 [NotificationService] Time already passed, scheduling for tomorrow');
      }
      
      print('🔔 [NotificationService] Scheduled time: $scheduledDate');
      print('🔔 [NotificationService] Time until notification: ${scheduledDate.difference(nowTz)}');

      // Try exact alarm first, fallback to inexact if it fails
      bool exactAlarmScheduled = false;
      
      try {
        await _localNotifications.zonedSchedule(
          dailyReminderId,
          'Daily Transaction Reminder',
          'Don\'t forget to add your transactions for today!',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'monie_notifications',
              'Monie Notifications',
              channelDescription: 'Notifications for group transactions and reminders',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'daily_reminder',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
        exactAlarmScheduled = true;
        print('✅ [NotificationService] Daily reminder scheduled successfully (exact alarm)');
      } catch (e) {
        print('⚠️ [NotificationService] Exact alarm failed: $e');
        print('⚠️ [NotificationService] Attempting fallback to inexact alarm...');
        
        // Fallback to inexact alarm if exact alarm fails
        try {
          await _localNotifications.zonedSchedule(
            dailyReminderId,
            'Daily Transaction Reminder',
            'Don\'t forget to add your transactions for today!',
            scheduledDate,
            const NotificationDetails(
              android: AndroidNotificationDetails(
                'monie_notifications',
                'Monie Notifications',
                channelDescription: 'Notifications for group transactions and reminders',
                importance: Importance.high,
                priority: Priority.high,
                icon: '@mipmap/ic_launcher',
              ),
              iOS: DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            payload: 'daily_reminder',
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );
          print('✅ [NotificationService] Daily reminder scheduled successfully (inexact alarm)');
        } catch (e2) {
          print('❌ [NotificationService] Failed to schedule notification: $e2');
          rethrow;
        }
      }
      
      // Log final status
      if (exactAlarmScheduled) {
        print('✅ [NotificationService] EXACT alarm set for 22:10 daily');
      } else {
        print('⚠️ [NotificationService] INEXACT alarm set for 22:10 daily');
        print('⚠️ Exact alarms may require SCHEDULE_EXACT_ALARM permission on Android 12+');
      }
      
    } catch (e, stackTrace) {
      print('❌ [NotificationService] ERROR scheduling daily reminder: $e');
      print('❌ Stack trace: $stackTrace');
      // Don't rethrow - notification scheduling is not critical
    }
  }

  /// Check if notification permission is granted
  Future<bool> _checkNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImpl != null) {
        // Check if permission is granted
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

  /// Request notification permission (useful for showing user prompt)
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImpl = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidImpl != null) {
        return await androidImpl.requestNotificationsPermission() ?? false;
      }
      return true;
    } else if (Platform.isIOS) {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
             settings.authorizationStatus == AuthorizationStatus.provisional;
    }
    return true;
  }

  /// Handle foreground FCM messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('🔔 [NotificationService] Foreground message received!');
    print('   Title: ${message.notification?.title}');
    print('   Body: ${message.notification?.body}');
    print('   Data: ${message.data}');
    
    // Show local notification even when app is in foreground
    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'monie_notifications',
          'Monie Notifications',
          channelDescription: 'Notifications for group transactions and reminders',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          styleInformation: BigTextStyleInformation(
            message.notification?.body ?? '',
          ),
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
    
    print('✅ [NotificationService] Local notification shown');
  }

  /// Handle background FCM messages (when app is opened from notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    // Handle navigation or action based on notification data
    final data = message.data;
    final type = data['type'] as String?;
    
    // Navigate based on notification type
    if (type == 'group_transaction') {
      final groupId = data['group_id'] as String?;
      if (groupId != null) {
        // Navigate to group details
        // You'll need to implement navigation via GlobalKey or Navigator
        print('Navigate to group: $groupId');
      }
    } else if (type == 'budget_alert') {
      // Navigate to budgets page
      print('Navigate to budgets');
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle navigation or action based on notification
    final payload = response.payload;
    
    if (payload != null) {
      // Parse payload and navigate accordingly
      // Format: "type:data" e.g., "group_transaction:group_id_123"
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final type = parts[0];
        final data = parts[1];
        
        if (type == 'group_transaction') {
          print('Navigate to group: $data');
        } else if (type == 'budget_alert') {
          print('Navigate to budgets');
        }
      }
    }
  }

  /// Get local timezone name from device
  Future<String> _getLocalTimezoneName() async {
    // Use timezone detection based on system offset
    // This is more reliable and doesn't require additional packages
    return _getFallbackTimezoneName();
  }

  /// Fallback timezone detection based on offset
  String _getFallbackTimezoneName() {
    try {
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final offsetHours = offset.inHours;
      
      print('🔔 [NotificationService] Using fallback timezone detection (offset: UTC${offsetHours >= 0 ? '+' : ''}$offsetHours)');
      
      // Common timezone mappings based on offset
      if (offsetHours == 0) return 'UTC';
      if (offsetHours == 7) return 'Asia/Ho_Chi_Minh'; // Vietnam
      if (offsetHours == 8) return 'Asia/Hong_Kong';
      if (offsetHours == 9) return 'Asia/Tokyo';
      if (offsetHours == -5) return 'America/New_York';
      if (offsetHours == -8) return 'America/Los_Angeles';
      if (offsetHours == 1) return 'Europe/Paris';
      if (offsetHours == 2) return 'Europe/Berlin';
      
      // Default to UTC if no match
      print('⚠️ [NotificationService] No timezone match found for offset $offsetHours, defaulting to UTC');
      return 'UTC';
    } catch (e) {
      print('❌ [NotificationService] Fallback timezone detection failed: $e');
      return 'UTC';
    }
  }
}

