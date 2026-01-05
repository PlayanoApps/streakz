/* import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import "package:timezone/data/latest.dart" as tz;
import "package:flutter_timezone/flutter_timezone.dart";

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initNotification() async {
    if (_isInitialized) return;

    // Init timezone
    tz.initializeTimeZones();
    final TimezoneInfo currentTimeZoneInfo =
        await FlutterTimezone.getLocalTimezone();
    final String currentTimeZone = currentTimeZoneInfo.identifier;
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    // Init settings
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/launcher_icon"),
    );

    await notificationsPlugin.initialize(initSettings);

    _isInitialized = true;
  }

  // Notification detail setup
  NotificationDetails notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        "daily_channel_id",
        "Daily Notifications",
        channelDescription: "Daily Notification Channel",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    final androidImplementation =
        notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    await androidImplementation?.requestNotificationsPermission();

    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now))
      scheduledDate = scheduledDate.add(Duration(days: 1));

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Make notification repeat daily at same time
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("----------------------------------------------");
    print("NOW: ${tz.TZDateTime.now(tz.local)}");
    print("SCHEDULED FOR: $scheduledDate");
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }
}

/* For saving the boolean wether notifications are enabled */
class NotiServiceProvider extends ChangeNotifier {
  bool _notifications = true;
  bool get notificationsEnabled => _notifications;

  /* Load value */
  Future<void> loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _notifications = prefs.getBool('notifications') ?? false;

    notifyListeners();
  }

  /* Set value */
  void toggleNotificationSetting(bool value, List<Habit> habitsList) async {
    _notifications = value;

    // Disable notifications
    if (_notifications == false)
      disableNotifications();
    else
      enableNotifications();

    // Update variable
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);

    notifyListeners();
  }

  void enableNotifications() async {
    NotiService().scheduleNotification(
      title: "Time to reflect",
      body: "Dont't forget to log your habits!",
      hour: 20,
      minute: 00,
      id: 1,
    );

    NotiService().showNotification(
      title: "",
      body: "You will now receive notifications",
    );
  }

  void disableNotifications() => NotiService().cancelAllNotifications();
}
 */

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import "package:timezone/data/latest.dart" as tz;
import "package:flutter_timezone/flutter_timezone.dart";

class NotiService {
  // Singleton pattern for single instance
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;
  NotiService._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize
  Future<void> initNotification() async {
    if (_isInitialized) return;

    try {
      // Init timezone
      tz.initializeTimeZones();

      // getLocalTimezone returns TimezoneInfo, extract identifier
      final TimezoneInfo currentTimeZoneInfo =
          await FlutterTimezone.getLocalTimezone();
      final String currentTimeZone = currentTimeZoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));

      // Init settings
      const initSettings = InitializationSettings(
        android: AndroidInitializationSettings("@mipmap/launcher_icon"),
      );

      await notificationsPlugin.initialize(initSettings);

      _isInitialized = true;
    } catch (e) {
      print("Error initializing notifications: $e");
      rethrow;
    }
  }

  // Ensure initialized before operations
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initNotification();
    }
  }

  // Notification detail setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        "daily_channel_id",
        "Daily Notifications",
        channelDescription: "Daily Notification Channel",
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await _ensureInitialized();

    final androidImplementation =
        notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();

    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> scheduleNotification({
    int id = 1,
    required String title,
    required String body,
    required int hour,
    required int minute,
  }) async {
    await _ensureInitialized();

    // Get the current date/time in device's local timezone
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If the scheduled time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Schedule the notification
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      // Make notification repeat daily at same time
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("----------------------------------------------");
    print("NOW: ${tz.TZDateTime.now(tz.local)}");
    print("SCHEDULED FOR: $scheduledDate");
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _ensureInitialized();
    await notificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _ensureInitialized();
    await notificationsPlugin.cancel(id);
  }
}

/* For saving the boolean whether notifications are enabled */
class NotiServiceProvider extends ChangeNotifier {
  bool _notifications = false; // Default to false for better UX
  bool get notificationsEnabled => _notifications;

  final NotiService _notiService = NotiService();

  /* Load value */
  Future<void> loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _notifications = prefs.getBool('notifications') ?? false;

    notifyListeners();
  }

  /* Set value */
  Future<void> toggleNotificationSetting(
    bool value,
    List<Habit> habitsList,
  ) async {
    _notifications = value;

    try {
      // Enable or disable notifications
      if (_notifications) {
        await enableNotifications();
      } else {
        await disableNotifications();
      }

      // Update SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notifications', value);

      notifyListeners();
    } catch (e) {
      print("Error toggling notifications: $e");
      // Revert state on error
      _notifications = !value;
      notifyListeners();
    }
  }

  Future<void> enableNotifications() async {
    await _notiService.scheduleNotification(
      title: "Time to reflect",
      body: "Don't forget to log your habits!", // Fixed typo
      hour: 20,
      minute: 0,
      id: 1,
    );

    await _notiService.showNotification(
      title: "Notifications Enabled",
      body: "You will now receive daily reminders",
    );
  }

  Future<void> disableNotifications() async {
    await _notiService.cancelAllNotifications();
  }
}
