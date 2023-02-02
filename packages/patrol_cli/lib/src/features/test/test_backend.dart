import 'package:patrol_cli/src/features/run_commons/device.dart';

abstract class AppOptions {
  const AppOptions({
    required this.target,
    required this.flavor,
    required this.dartDefines,
  });

  final String target;
  final String? flavor;
  final Map<String, String> dartDefines;

  String get desc;
}

abstract class TestBackend {
  Future<void> build(covariant AppOptions options, Device device);
  Future<void> execute(covariant AppOptions options, Device device);
}
