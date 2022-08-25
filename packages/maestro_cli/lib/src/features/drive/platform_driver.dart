import 'package:maestro_cli/src/features/drive/device.dart';

abstract class PlatformDriver {
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required String? flavor,
    required Device device,
    required int port,
    required Map<String, String> dartDefines,
    required bool verbose,
    required bool debug,
  });
}
