import 'dart:async';
import 'dart:convert';

import 'package:example/handlers/permission_handler.dart';
import 'package:example/ui/style/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class NotificationHandler {
  NotificationHandler(
    this._flutterLocalNotificationsPlugin,
    this._firebaseMessaging,
  );

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final FirebaseMessaging? _firebaseMessaging;

  Future<void> init(VoidCallback onNotificationTap) async {
    await _init(onNotificationTap);
    final token = await _firebaseMessaging?.getToken();
    debugPrint('Device FCM token: $token');
    _listenForPushNotifications();
  }

  Future<void> _init(VoidCallback onNotificationTap) async {
    const darwinInitSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: darwinInitSettings,
        macOS: darwinInitSettings,
      ),
      onDidReceiveNotificationResponse: (_) => onNotificationTap(),
    );
    await _firebaseMessaging?.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<bool> _requestPermission() async {
    final permissionStatus = await PermissionHandler.requestPermissions();
    return switch (permissionStatus) {
      PermissionStatus.granted => true,
      _ => false,
    };
  }

  Future<void> triggerLocalNotification({
    required VoidCallback onPressed,
    required VoidCallback onError,
  }) async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      onError();
      return;
    }
    await _init(onPressed);
    await _showNotification(title: 'Tap me to finish the quiz!');
  }

  Future<void> triggerPushNotification({
    required VoidCallback onPressed,
  }) async {
    final hasPermission = await _requestPermission();
    if (!hasPermission) {
      return;
    }
    await _init(onPressed);
    final fcmToken = await _firebaseMessaging?.getToken();
    await http.post(
      Uri.parse(
        'https://us-central1-patrol-poc.cloudfunctions.net/sendNotification',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': fcmToken}),
    );
  }

  void _listenForPushNotifications() {
    if (_firebaseMessaging == null) {
      return;
    }

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        final notification = message.notification;
        _showNotification(
          title: notification?.title ?? '',
          body: notification?.body,
        );
      }
    });
  }

  Future<void> _showNotification({
    required String title,
    String? body,
  }) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'patrolChallengeChannelId',
        'patrolChallengeChannel',
        importance: Importance.max,
        priority: Priority.high,
        color: PTColors.lcBlack,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        interruptionLevel: InterruptionLevel.active,
      ),
    );

    return _flutterLocalNotificationsPlugin.show(0, title, body, details);
  }
}
