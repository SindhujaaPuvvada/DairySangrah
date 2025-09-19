import 'dart:convert';

import 'package:farm_expense_mangement_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  //print('Title: ${message.notification?.title}');
  //print('Body: ${message.notification?.body}');
  //print('payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
      'high_importance_channel', 'High_importance_notifications',
      description: 'This channel is used for important notifications',
      importance: Importance.defaultImportance);
  final _localnotifications = FlutterLocalNotificationsPlugin();
  Future initLocalNotifications() async {
    const android = AndroidInitializationSettings('@drawable/ic_launcher');
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();
    //print('token : $fCMToken');
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      if (notification == null) return;
      _localnotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: '@drawble/ic_launcher',
            )),
        payload: jsonEncode(message.toMap()),
      );
    });
  }
}