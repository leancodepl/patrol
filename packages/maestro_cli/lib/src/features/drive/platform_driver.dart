import 'package:freezed_annotation/freezed_annotation.dart';

part 'platform_driver.freezed.dart';

abstract class PlatformDriver {
  Future<void> run({
    required String driver,
    required String target,
    required String host,
    required int port,
    required String device,
    required String? flavor,
    Map<String, String> dartDefines = const {},
    required bool verbose,
    required bool debug,
  });

  Future<List<Device>> devices();
}

@freezed
class Device with _$Device {
  const factory Device.android({
    required String name,
  }) = _AndroidDevice;

  const factory Device.iOS({
    required String name,
  }) = _IOSDevice;
}
