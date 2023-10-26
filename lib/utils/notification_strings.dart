import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//* Channel PUSH notifications
const channelId = 'test_notifid';
const channelKey = 'test_notifkey';
const channelName = 'test_notif';

//* IOS Settings
final iosInitializationSettings = DarwinInitializationSettings(
  notificationCategories: [
    DarwinNotificationCategory(
      channelId,
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain(
          channelKey,
          'test_notif notificacion',
          options: {
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
    ),
  ],
  onDidReceiveLocalNotification:
      (int id, String? title, String? body, String? payload) {},
);

//* Android Settings
const androidInitializationSettings =
    AndroidInitializationSettings('ic_stat_transparan');

const androidChannel = AndroidNotificationChannel(
  channelId,
  channelName,
  description: 'string sound notifications1',
  enableLights: true,
  playSound: true,
  ledColor: Colors.red,
  importance: Importance.high,
);

/// channel 2
const pushNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: 'string sound notifications2',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    ongoing: true, color: Colors.red,
    ledColor: Colors.red,
    visibility: NotificationVisibility.public,
    ledOnMs: 100,
    ledOffMs: 1000,
    //    category: AndroidNotificationCategory.alarm,
  ),
  iOS: DarwinNotificationDetails(
    presentSound: true,
    presentAlert: true,
    presentBadge: true,
  ),
);
