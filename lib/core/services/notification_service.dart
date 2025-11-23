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
      return await _firebaseMessaging.getToken();
    } catch (e) {
      return null;
    }
  }

  /// Schedule daily reminder at 1:00 PM
  Future<void> scheduleDailyReminder() async {
    if (!_initialized) {
      await initialize();
    }

    try {
      // Cancel any existing daily reminder
      await _localNotifications.cancel(1);

      // Schedule for 1:00 PM (13:00) every day in device's local timezone
      // Use DateTime.now() to get device's local time, then convert to TZDateTime
      final now = DateTime.now();
      final localTz = tz.getLocation(await _getLocalTimezoneName());
      
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        localTz,
        now.year,
        now.month,
        now.day,
        13, // 1:00 PM
        0,
      );

      // If the time has already passed today, schedule for tomorrow
      final nowTz = tz.TZDateTime.from(now, localTz);
      if (scheduledDate.isBefore(nowTz)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Try exact alarm first, fallback to inexact if it fails
      try {
        await _localNotifications.zonedSchedule(
          1,
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
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      } catch (e) {
        // Fallback to inexact alarm if exact alarm fails
        await _localNotifications.zonedSchedule(
          1,
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
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    } catch (e) {
      // Silently fail - notification scheduling is not critical
    }
  }

  /// Handle foreground FCM messages
  void _handleForegroundMessage(RemoteMessage message) {
    _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
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
    );
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
    try {
      // Use DateTime to get timezone offset and infer timezone
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      final offsetHours = offset.inHours;
      
      // Common timezone mappings based on offset
      // This is a simplified approach - for production, consider using a package
      // like flutter_native_timezone for more accurate timezone detection
      if (offsetHours == 0) return 'UTC';
      if (offsetHours == 7) return 'Asia/Ho_Chi_Minh'; // Vietnam
      if (offsetHours == 8) return 'Asia/Hong_Kong';
      if (offsetHours == 9) return 'Asia/Tokyo';
      if (offsetHours == -5) return 'America/New_York';
      if (offsetHours == -8) return 'America/Los_Angeles';
      if (offsetHours == 1) return 'Europe/Paris';
      if (offsetHours == 2) return 'Europe/Berlin';
      
      // Default to UTC if no match
      return 'UTC';
    } catch (e) {
      return 'UTC';
    }
  }
}

