import 'package:flutter/widgets.dart';
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
      enableNotifications(habitsList);

    // Update variable
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', value);

    notifyListeners();
  }

  void enableNotifications(List<Habit> habitsList) async {
    NotiService().scheduleNotification(
      title: "Time to reflect",
      body: "Dont't forget to log your habits!",
      hour: 20,
      minute: 00,
      id: 1,
    );

    /* NotiService().scheduleNotification(
      title: "Your stats for today",
      body: "Today, you've completed ${amountOfHabitsCompleted(DateTime.now(), habitsList)} out of ${habitsList.length} habits.",
      hour: 21,
      minute: 00,
      id: 2
    );

    final index = Random().nextInt(2); // 0 or 1

    if(index == 0) {
      NotiService().scheduleNotification(
        title: "Ready to Go?",
        body: "Small habits lead to big results. Let's keep moving!",
        hour: 6,
        minute: 30,
        id: 3
      );
    } else {
      NotiService().scheduleNotification(
        title: "Today is Yours",
        body: "Each choice shapes your path. Choose well today.",
        hour: 6,
        minute: 30,
        id: 3
      );
    } */

    NotiService().showNotification(
      title: "",
      body: "You will now receive notifications",
    );
  }

  void disableNotifications() => NotiService().cancelAllNotifications();
}
