import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  int? _notificationId;

  static const _firstTitle = 'Someone liked your recent post';

  static const _secondTitle = "We've got a special offer for you!";

  @override
  void initState() {
    super.initState();

    unawaited(
      () async {
        await _notificationsPlugin.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(
              defaultPresentAlert: false,
            ),
          ),
          onDidReceiveNotificationResponse: (notificationResponse) {
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

  Future<void> _showNotificationNow({
    required String title,
    required int id,
  }) async {
    await _notificationsPlugin.show(
      id,
      title,
      'This notification has ID = $id',
      NotificationDetails(
        iOS: DarwinNotificationDetails(),
        android: AndroidNotificationDetails(
          'main',
          'Default notification channel',
        ),
      ),
    );
  }

  Future<void> _showNotificationLater({
    required String title,
    required int id,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      'This notification has ID = $id',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      NotificationDetails(
        iOS: DarwinNotificationDetails(
          interruptionLevel: InterruptionLevel.passive,
        ),
        android: AndroidNotificationDetails(
          'default',
          'Default notification channel',
          channelDescription: "For all the notifications, because we're lazy",
        ),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.wallClockTime,
      androidAllowWhileIdle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Spacer(),
            Center(
              child: _notificationId != null
                  ? Text(
                      'Tapped notification with ID: $_notificationId',
                      textAlign: TextAlign.center,
                    )
                  : Text('No notification tapped', textAlign: TextAlign.center),
            ),
            Spacer(),
            Text(
              'Notification one',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('"$_firstTitle"'),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async => _showNotificationNow(
                    id: 1,
                    title: _firstTitle,
                  ),
                  child: const Text('Show now'),
                ),
                ElevatedButton(
                  onPressed: () async => _showNotificationLater(
                    id: 1,
                    title: _firstTitle,
                  ),
                  child: const Text('Show in a few seconds'),
                ),
              ],
            ),
            Spacer(),
            Text(
              'Notification two',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text('"$_secondTitle"'),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () async => _showNotificationNow(
                    id: 2,
                    title: _secondTitle,
                  ),
                  child: const Text('Show now'),
                ),
                ElevatedButton(
                  onPressed: () async => _showNotificationLater(
                    id: 2,
                    title: _secondTitle,
                  ),
                  child: const Text('Show in a few seconds'),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
}
