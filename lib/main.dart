import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification/home.dart';

import 'utils/notification_service.dart';

/// start new code
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage remoteMessage) async {
  await displayPushNotification(remoteMessage);

  return Future<void>.value();
}

Future<void> displayPushNotification(
  RemoteMessage notification,
) async {
  localNotif('${notification.notification!.title}',
      '${notification.notification!.body}');
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.input?.isNotEmpty ?? false) {}
}

void _onDidReceiveNotificationResponse(
  NotificationResponse details,
) {
  selectNotificationStream.add(details);
}

/// end new code

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// start new code
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.initializeNotificationService(
      _onDidReceiveNotificationResponse);

  /// end new code

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notification',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

/// start new code
final StreamController<NotificationResponse?> selectNotificationStream =
    StreamController<NotificationResponse?>.broadcast();
/// end new code