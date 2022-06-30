import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _notificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();

    _notificationsPlugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (notificationResponse) {
        print('tapped notification with ID ${notificationResponse.id}');
      },
    );
  }

  void _showNotification({required int id}) {
    _notificationsPlugin.show(
      id,
      'Maestro example',
      'Hello there! This notification has ID=$id',
      const NotificationDetails(
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
        children: <Widget>[
          TextButton(
            onPressed: () => _showNotification(id: 1),
            child: const Text('Show notification with ID=1'),
          ),
          TextButton(
            onPressed: () => _showNotification(id: 2),
            child: const Text('Show notification with ID=2'),
          ),
        ],
      ),
    );
  }
}
