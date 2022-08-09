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

  const Device._();

  /// Returns the name that Maestro is usually interested with.
  ///
  /// On Android, this is the ID of the device, e.g "emulator-5554".
  ///
  /// On iOS, this is the name of the device, e.g "iPhone 13" or
  /// "Barteks-iPhone".
  String get resolvedName {
    switch (targetPlatform) {
      case TargetPlatform.android:
        return id;
      case TargetPlatform.iOS:
        return name;
    }
  }
}

enum TargetPlatform { iOS, android }

extension TargetPlatformX on TargetPlatform {
  static TargetPlatform fromString(String platform) {
    switch (platform) {
      case 'ios':
        return TargetPlatform.iOS;
      case 'android-arm64':
        return TargetPlatform.android;
      default:
        throw Exception('Unsupported platform $platform');
    }
  }
}
