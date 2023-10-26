import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification/home.dart';

import 'utils/firebase_options.dart';
import 'utils/notification_service.dart';

final Future<FirebaseApp> _initialization = Firebase.initializeApp(
  name: "test_notif",
  options: DefaultFirebaseOptions.currentPlatform,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'test_notif',
    'test_notif',
    channelDescription: 'test_notif sound',
    importance: Importance.max,
    priority: Priority.high,
    fullScreenIntent: true,
    ongoing: true,
    ledColor: Colors.red,
    color: Colors.red,
    ledOnMs: 100,
    ledOffMs: 1000,
  );

  var iOSPlatformChannelSpecifics = iOSNotificationDetails();
  var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics);

  ///yg bikin bunyi bg
  await flutterLocalNotificationsPlugin.show(
      0, notification!.title, notification.body, platformChannelSpecifics,
      payload: 'item x');

  // Schedule a timer to dismiss the notification after 3 seconds
  Timer(Duration(seconds: 5), () async {
    await flutterLocalNotificationsPlugin
        .cancel(0); // Use the correct notification ID
  });
  return Future<void>.value();
}

iOSNotificationDetails() {}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  if (notificationResponse.input?.isNotEmpty ?? false) {
    debugPrint(
        ' notification action tapped with input: ${notificationResponse.input}');
  }
}

void _onDidReceiveNotificationResponse(
  NotificationResponse details,
) {
  selectNotificationStream.add(details);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'test_notif',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('fcmToken $fcmToken');

  final firestore = FirebaseFirestore.instance;

  firestore.collection("testing").doc('testuser').set({'fcmToken': fcmToken});

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.initializeNotificationService(
      _onDidReceiveNotificationResponse);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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

final StreamController<NotificationResponse?> selectNotificationStream =
    StreamController<NotificationResponse?>.broadcast();
