import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// ignore: depend_on_referenced_packages
import 'package:rxdart/rxdart.dart';

import '../main.dart';
import 'notification_strings.dart';

class NotificationService {
  factory NotificationService() => _instancia;
  NotificationService._internal();
  static final NotificationService _instancia = NotificationService._internal();
  static get _firebaseMessaging => FirebaseMessaging.instance;
  static get _flutterLocalNotificationsPlugin =>
      FlutterLocalNotificationsPlugin();

  static final BehaviorSubject<NotificationResponse?>
      _notificationActionStream =
      BehaviorSubject<NotificationResponse?>.seeded(null);
  static Stream<NotificationResponse?> get notificationActionStream =>
      _notificationActionStream.stream;
  static Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;
  static bool _isFlutterLocalNotificationsInitialized = false;

  static Future<void> initializeNotificationService(
    Function(NotificationResponse)? onDidReceiveNotificationResponse,
  ) async {
    if (_isFlutterLocalNotificationsInitialized) return;
    await _initFirebaseMessaging();
    await _flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: androidInitializationSettings,
        iOS: iosInitializationSettings,
      ),
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        _notificationActionStream.add(notificationResponse);
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    await _requestPermissions();
    //await _createNotificationChannels();
    _listenNotificationActionStream();
    _isFlutterLocalNotificationsInitialized = true;
  }

  static Future<void> displayPushNotification(
    RemoteMessage notification,
  ) async {
    localNotif('${notification.notification!.title}',
        '${notification.notification!.body}');
  }

  static Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future<void> _initFirebaseMessaging() async {
    //* Notificacion cuando la app esta en FOREGROUND
    FirebaseMessaging.onMessage.listen(_handleIncomingForegroundNotification);
    //* Notificacion al tocar la notificacion y se abre la app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleOpenedAppNotification);
  }

  static Future<void> _handleIncomingForegroundNotification(
    RemoteMessage remoteMessage,
  ) async {
    await displayPushNotification(remoteMessage);
  }

  static void _handleOpenedAppNotification(RemoteMessage remoteMessage) {}

  static Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestPermission();
    } else {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  static Future<void> _listenNotificationActionStream() async {
    selectNotificationStream.stream
        .listen((event) => event)
        .onData((data) async {
      _notificationActionStream.add(data);
      switch (data?.notificationResponseType) {
        case NotificationResponseType.selectedNotification:
          break;
        case NotificationResponseType.selectedNotificationAction:
          break;
        default:
      }
    });
  }

  static Future<void> _createNotificationChannels() async {
    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }
}

int get createUniqueId =>
    DateTime.now().millisecondsSinceEpoch.remainder(100000);
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
int id = 0;

Future<void> requestPermissions() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
}

Future<void> localNotif(title, body) async {
  await _showNotification(title, body);
}

///fg
Future<void> _showNotification(title, body) async {
  debugPrint("_showNotification $title $body");
  NotificationDetails notificationDetails = const NotificationDetails(
    android: AndroidNotificationDetails(
      'test_notif',
      'test_notif',
      channelDescription: 'notif with sound',
      color: Colors.red,
      ledColor: Colors.red,
      visibility: NotificationVisibility.public,
      importance: Importance.max,
      priority: Priority.high,
      ledOnMs: 100,
      ledOffMs: 1000,
      playSound: true,
      category: AndroidNotificationCategory.alarm,
      ticker: 'ticker',
    ),
    iOS: DarwinNotificationDetails(
      presentSound: true,
      presentAlert: true,
      presentBadge: true,
    ),
  );
  await flutterLocalNotificationsPlugin
      .show(id++, title, body, notificationDetails, payload: 'item x');

  // Schedule a timer to dismiss the notification after 3 seconds
  Timer(Duration(seconds: 5), () async {
    await flutterLocalNotificationsPlugin
        .cancel(0); // Use the correct notification ID
  });
}
