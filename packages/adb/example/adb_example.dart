import 'package:adb/adb.dart' as adb;

void main() {
  const apk = '/Users/john/Downloads/someApplication.apk';
  adb.install(apk);
}
