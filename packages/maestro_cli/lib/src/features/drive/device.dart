import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';

@freezed
class Device with _$Device {
  const factory Device({
    required String name,
    required String id,
    required TargetPlatform targetPlatform,
    required bool real,
  }) = _Device;
}

enum TargetPlatform { iOS, android }

extension TargetPlatformX on TargetPlatform {
  static TargetPlatform fromString(String platform) {
    switch (platform) {
      case 'ios':
        return TargetPlatform.iOS;
      case 'android':
        return TargetPlatform.android;
      default:
        throw Exception('Unsupported platform $platform');
    }
  }
}
