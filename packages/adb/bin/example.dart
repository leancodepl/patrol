import 'package:adb/adb.dart';

void main() async {
  final adb = Adb();
  await adb.init();
  const apk = '/Users/bartek/.config/maestro/server.apk';
  await adb.install(apk);
}
