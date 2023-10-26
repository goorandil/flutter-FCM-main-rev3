import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notification/home.dart';

import 'utils/firebase_options.dart';
import 'utils/notification_service.dart';

/*
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

void notificationTapBackground(NotificationResponse notificationResponse) {
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    print(
        'notification action tapped with input: ${notificationResponse.input}');
  }
}
*/
/*
final Future<FirebaseApp> _initialization = Firebase.initializeApp(
  name: 'test_notif',
  options: DefaultFirebaseOptions.currentPlatform,
);
*/
/// start local notif
///

final Future<FirebaseApp> _initialization = Firebase.initializeApp(
  name: "test_notif",
  options: DefaultFirebaseOptions.currentPlatform,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  RemoteNotification? notification = message.notification;

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails('test_notif', 'test_notif',
          channelDescription: 'test_notif sound',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
          ongoing: true,
          ledColor: Colors.red,
          color: Colors.red,
          ledOnMs: 100,
          ledOffMs: 1000,
          timeoutAfter: 3000
          // largeIcon: const DrawableResourceAndroidBitmap("logo1024"),
          //   sound: const RawResourceAndroidNotificationSound('mysound'),
          // category: AndroidNotificationCategory.alarm,
          //  styleInformation: bigPictureStyleInformation,
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
/*
Future<String> _downloadAndSaveFile(String url, String fileName) async {
  final Directory directory = await getApplicationDocumentsDirectory();
  final String filePath = '${directory.path}/$fileName';
  final http.Response response = await http.get(Uri.parse(url));
  final File file = File(filePath);
  await file.writeAsBytes(response.bodyBytes);
  return filePath;
}*/

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint(' notificationTapBackground');

  debugPrint(' notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
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

/// end notf
///

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'test_notif',
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final fcmToken = await FirebaseMessaging.instance.getToken();
  print('fcmToken $fcmToken');

  print('fcmToken $fcmToken');
  final firestore = FirebaseFirestore.instance;

  firestore.collection("testing").doc('testuser').set({'fcmToken': fcmToken});
  /* messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
*/
  //If subscribe based sent notification then use this token
/*  final fcmToken = await messaging.getToken();
  print(fcmToken);

  //If subscribe based on topic then use this
  await messaging.subscribeToTopic('flutter_notification');

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
        'flutter_notification', // id
        'flutter_notification_title', // title
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        showBadge: true,
        playSound: true);

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    final android =
        AndroidInitializationSettings('@drawable/ic_notifications_icon');
    final iOS = DarwinInitializationSettings();
    final initSettings = InitializationSettings(android: android, iOS: iOS);

    await flutterLocalNotificationsPlugin!.initialize(initSettings,
        onDidReceiveNotificationResponse: notificationTapBackground,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground);

    await messaging
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
*/

////////////////////// start local notif
/////////////////////
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await NotificationService.initializeNotificationService(
      _onDidReceiveNotificationResponse);

  ////////////////////// end local notif
/////////////////////

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
      //    navigatorKey: navigatorKey,
      home: HomePage(),
    );
  }
}

final StreamController<NotificationResponse?> selectNotificationStream =
    StreamController<NotificationResponse?>.broadcast();
