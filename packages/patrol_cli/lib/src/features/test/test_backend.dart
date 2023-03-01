import 'package:patrol_cli/src/features/devices/device.dart';

abstract class AppOptions {
  const AppOptions({
    required this.target,
    required this.flavor,
    required this.dartDefines,
  });

  final String target;
  final String? flavor;
  final Map<String, String> dartDefines;

  String get description;
}

abstract class TestBackend {
  Future<void> build(covariant AppOptions options);
  Future<void> execute(covariant AppOptions options, Device device);
  Future<void> uninstall(String appId, Device device);
}
