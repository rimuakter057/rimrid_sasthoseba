import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/medicine_reminder.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  static const String channelId = 'rimrid_medicine_reminders';
  static const String channelName = 'ওষুধের রিমাইন্ডার (Medicine Reminders)';
  static const String channelDesc = 'সময়মতো ওষুধ খাওয়ার প্রয়োজনীয় নোটিফিকেশন ও অ্যালার্ম';

  /// Initialize Local Notifications with timezone and permission handling
  Future<void> init() async {
    if (_isInitialized) return;

    // Guard for desktop platforms (Windows / Linux) where mobile native plugins are not supported
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugPrint('[NotificationService] Desktop environment detected: Mobile notification native plugins bypassed safely.');
      _isInitialized = true;
      return;
    }

    try {
      // 1. Initialize Timezone database and set local location to match device offset
      tz.initializeTimeZones();
      _setupLocalTimeZone();

      // 2. Initialize Local Notifications Plugin
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('[NotificationService] Notification tapped: ${response.payload}');
        },
      );

      // 3. Android High-Importance Channel & Request Permissions
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        // Request notification permission for Android 13+ (API 33+)
        await androidImplementation.requestNotificationsPermission();
        // Request exact alarm permission for Android 12+ (API 31+)
        await androidImplementation.requestExactAlarmsPermission();

        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDesc,
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
            showBadge: true,
          ),
        );
      }

      _isInitialized = true;
      debugPrint('[NotificationService] Initialized successfully with timezone & exact alarm support.');
    } catch (e) {
      debugPrint('[NotificationService] Initialization error (safe fallback): $e');
      _isInitialized = true;
    }
  }

  /// Sets tz.local based on device's current UTC offset (e.g., Asia/Dhaka for UTC+6)
  void _setupLocalTimeZone() {
    try {
      final now = DateTime.now();
      final offsetMs = now.timeZoneOffset.inMilliseconds;
      tz.Location? matchedLocation;

      // 1. Try matching location by timeZoneName
      try {
        matchedLocation = tz.getLocation(now.timeZoneName);
      } catch (_) {}

      // 2. If not found, match by current UTC offset in milliseconds
      if (matchedLocation == null) {
        for (final loc in tz.timeZoneDatabase.locations.values) {
          if (loc.currentTimeZone.offset == offsetMs) {
            matchedLocation = loc;
            break;
          }
        }
      }

      // 3. Bangladesh default fallback if offset is +6 hours
      if (matchedLocation == null && now.timeZoneOffset.inHours == 6) {
        try {
          matchedLocation = tz.getLocation('Asia/Dhaka');
        } catch (_) {}
      }

      if (matchedLocation != null) {
        tz.setLocalLocation(matchedLocation);
        debugPrint('[NotificationService] Active TimeZone set to: ${matchedLocation.name} (Offset: ${now.timeZoneOffset})');
      } else {
        debugPrint('[NotificationService] TimeZone fallback to tz.local: ${tz.local.name}');
      }
    } catch (e) {
      debugPrint('[NotificationService] _setupLocalTimeZone error: $e');
    }
  }

  /// Explicitly request permissions (can be called from UI if user denied initially)
  Future<bool> requestPermissions() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) return true;
    try {
      final androidImplementation = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidImplementation != null) {
        final granted = await androidImplementation.requestNotificationsPermission();
        await androidImplementation.requestExactAlarmsPermission();
        return granted ?? false;
      }
    } catch (e) {
      debugPrint('[NotificationService] requestPermissions error: $e');
    }
    return true;
  }

  /// Show an instant local notification (useful for testing on device immediately)
  Future<void> showInstantNotification({
    required String title,
    required String body,
    int id = 0,
    String? payload,
  }) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugPrint('[NotificationService Test (Desktop)]: Title: $title | Body: $body');
      return;
    }

    try {
      // Ensure permission is granted
      await requestPermissions();

      const androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await _localNotifications.show(id, title, body, details, payload: payload);
      debugPrint('[NotificationService] Instant notification shown: $title');
    } catch (e) {
      debugPrint('[NotificationService] showInstantNotification error: $e');
    }
  }

  /// Schedule daily repeating notification for a medicine reminder at exact time
  Future<void> scheduleMedicineReminder(MedicineReminder reminder) async {
    if (reminder.id == null || !reminder.isActive) return;

    final id = reminder.id!;
    final title = '🔔 ${reminder.medicineName} খাওয়ার সময় হয়েছে!';
    final body = '${reminder.slotBangla} — ${reminder.dosage.isNotEmpty ? reminder.dosage : '১ মাত্রা'} (${reminder.mealTiming.isNotEmpty ? reminder.mealTiming : 'সময়মতো'})';

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) {
      debugPrint('[NotificationService Scheduled (Desktop)]: ID: $id at ${reminder.formattedTime} - $title - $body');
      return;
    }

    try {
      // Ensure permissions
      await requestPermissions();
      _setupLocalTimeZone();

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminder.timeHour,
        reminder.timeMinute,
      );

      // If the scheduled time for today has already passed:
      if (scheduledDate.isBefore(now)) {
        // If the user selected the CURRENT minute (common during testing),
        // schedule it 5 seconds from now so they don't have to wait 24 hours!
        if (reminder.timeHour == now.hour && reminder.timeMinute == now.minute) {
          scheduledDate = now.add(const Duration(seconds: 5));
          debugPrint('[NotificationService] Selected current minute: scheduling 5s ahead at $scheduledDate');
        } else {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }
      }

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDesc,
        importance: Importance.max,
        priority: Priority.max,
        playSound: true,
        enableVibration: true,
        icon: '@mipmap/ic_launcher',
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        fullScreenIntent: true,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(android: androidDetails, iOS: iosDetails);

      // Cancel any existing schedule for this reminder ID first
      await _localNotifications.cancel(id);

      // Schedule alarm - try exact first, fallback to inexact if restricted by OS
      try {
        await _localNotifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'reminder_${reminder.id}',
        );
        debugPrint('[NotificationService] Scheduled EXACT reminder ID $id at $scheduledDate (Local now: $now)');
      } catch (exactErr) {
        debugPrint('[NotificationService] Exact alarm fallback ($exactErr), scheduling with inexactAllowWhileIdle:');
        await _localNotifications.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: 'reminder_${reminder.id}',
        );
        debugPrint('[NotificationService] Scheduled INEXACT reminder ID $id at $scheduledDate');
      }
    } catch (e) {
      debugPrint('[NotificationService] Schedule reminder error: $e');
    }
  }

  /// Cancel a scheduled reminder notification
  Future<void> cancelReminder(int reminderId) async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) return;
    try {
      await _localNotifications.cancel(reminderId);
      debugPrint('[NotificationService] Cancelled reminder ID $reminderId');
    } catch (e) {
      debugPrint('[NotificationService] Cancel reminder error: $e');
    }
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux)) return;
    try {
      await _localNotifications.cancelAll();
      debugPrint('[NotificationService] Cancelled all reminders');
    } catch (e) {
      debugPrint('[NotificationService] Cancel all error: $e');
    }
  }
}
