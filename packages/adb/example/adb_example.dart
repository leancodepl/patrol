import 'package:adb/adb.dart';

void main() {
  final adb = Adb();
  const apk = '/Users/john/Downloads/someApplication.apk';
  adb.install(apk);
}
