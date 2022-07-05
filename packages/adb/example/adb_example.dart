import 'package:adb/adb.dart';

void main() {
  const adb = Adb();
  const apk = '/Users/john/Downloads/someApplication.apk';
  adb.install(apk);
}
