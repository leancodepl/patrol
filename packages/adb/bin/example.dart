import 'package:adb/adb.dart';

void main() {
  final adb = Adb();
  const apk = '/Users/bartek/.config/maestro/server.apk';
  adb.install(apk);
}
