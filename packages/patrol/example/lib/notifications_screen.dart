import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  int? _notificationId;

  @override
  void initState() {
    super.initState();

    unawaited(
      () async {
        await _notificationsPlugin.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(),
          ),
          onDidReceiveNotificationResponse: (notificationResponse) {
            print(
              'NotificationScreen: tapped notification with ID ${notificationResponse.id}',
            );
            setState(() {
              _notificationId = notificationResponse.id;
            });
          },
        );

        await _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestPermission();
      }(),
    );
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    required int id,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      '$body ID: $id',
      NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'main',
          'Default notification channel',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextButton(
            onPressed: () async => _showNotification(
              id: 1,
              title: 'Someone liked your recent post',
              body: 'Tap to see who!',
            ),
            child: const Text('Show "someone liked" notification'),
          ),
          TextButton(
            onPressed: () async => _showNotification(
              id: 2,
              title: 'Special offer',
              body: 'We have something special for you!',
            ),
            child: const Text('Show "special offer" notification'),
          ),
          if (_notificationId != null)
            Text(
              'Tapped notification with ID: $_notificationId',
              textAlign: TextAlign.center,
            )
          else
            Text('No notification tapped', textAlign: TextAlign.center)
        ],
      ),
    );
  }
}
