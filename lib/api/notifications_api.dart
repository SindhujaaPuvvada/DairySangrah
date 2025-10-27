import 'dart:convert';
import 'package:farm_expense_mangement_app/main.dart';
import 'package:farm_expense_mangement_app/screens/authenticate/authUtils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/authenticate/language.dart';
import '../screens/milk/milkavgpage.dart';

class NotificationsApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _androidChannel = const AndroidNotificationChannel(
    'high_importance_channel',
    'High_importance_notifications',
    description: 'This channel is used for important notifications',
    importance: Importance.defaultImportance,
  );
  final _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    NotificationSettings notificationsSettings =
        await _firebaseMessaging.requestPermission();

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (notificationsSettings.authorizationStatus ==
        AuthorizationStatus.denied) {
      await prefs.setString('fcm_token', '');
      await prefs.setBool('fcm_to_update', true);
    } else {
      final fCMToken = await _firebaseMessaging.getToken();
      await prefs.setString('fcm_token', fCMToken ?? '');
      await prefs.setBool('fcm_to_update', true);
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    FirebaseMessaging.onMessage.listen((message) {
      final context = navigatorKey.currentContext;

      if (context != null && context.mounted && message.notification != null) {
        showDialog(
            context: context,
            builder: (_) => AuthUtils.buildAlertDialog(
                title: message.notification?.title ?? 'Notification',
                content: message.notification?.body ?? '',
                opt1: 'Proceed',
                onPressedOpt1: () {
                  Navigator.pop(context);
                  _handleNotificationTap(message);
                },
                opt2: 'Not Now',
                onPressedOpt2: () => Navigator.pop(context)));
      }
    });

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      if (notificationsSettings.authorizationStatus ==
          AuthorizationStatus.authorized) {
        await prefs.setString('fcm_token', newToken);
        await prefs.setBool('fcm_to_update', true);
      }
    });

    _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
      _handleNotificationTap(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
      _handleNotificationTap(message);
    });
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    showNotification(message);
  }

  void showNotification(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
          android: AndroidNotificationDetails(
        _androidChannel.id,
        _androidChannel.name,
        channelDescription: _androidChannel.description,
        icon: 'asset/bgscreen.png',
      )),
      payload: jsonEncode(message.toMap()),
    );
  }

  void _handleNotificationTap(RemoteMessage? message) {
    if (message != null) {
      String? uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        navigatorKey.currentState?.push(MaterialPageRoute(
            builder: (_) => AvgMilkPage(
                  fromNotification: true,
                )));
      } else {
        navigatorKey.currentState
            ?.push(MaterialPageRoute(builder: (_) => SignUpPage()));
      }
    }
  }
}
