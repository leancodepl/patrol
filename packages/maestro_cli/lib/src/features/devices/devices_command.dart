import 'package:adb/adb.dart';
import 'package:args/command_runner.dart';
import 'package:maestro_cli/src/common/logging.dart';
import 'package:maestro_cli/src/features/drive/ios/ios_driver.dart';

class DevicesCommand extends Command<int> {
  @override
  String get name => 'devices';

  @override
  String get description => 'List available devices, simulators and emulators.';

  @override
  Future<int> run() async {
    final adb = Adb();
    await adb.init();

    (await adb.devices()).forEach(log.info);
    (await IOSDriver().devices()).forEach(log.info);

    return 0;
  }
}
