import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//* Channel PUSH notifications
const channelId = 'test_notifid';
const channelKey = 'test_notifkey';
const channelName = 'test_notif';
const channelDescription = 'sound notifications';

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
  description: channelDescription,
//  importance: Importance.max,
//  sound: RawResourceAndroidNotificationSound('mysound'),
  enableLights: true,
  playSound: true,
  ledColor: Colors.red,
);

const pushNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    color: Colors.red,
    ledColor: Colors.red,
    visibility: NotificationVisibility.public,
    // importance: Importance.max,
    ledOnMs: 100,
    ledOffMs: 1000,
    category: AndroidNotificationCategory.alarm,
  ),
  iOS: DarwinNotificationDetails(
    presentSound: true,
    presentAlert: true,
    presentBadge: true,
  ),
);
