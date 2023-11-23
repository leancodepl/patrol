import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<PermissionStatus> requestPermissions() async {
    var status = await Permission.notification.status;

    if (status != PermissionStatus.granted) {
      status = await Permission.notification.request();
    }

    return status;
  }
}
