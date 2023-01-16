class Device {
  const Device({
    required this.name,
    required this.id,
    required this.targetPlatform,
    required this.real,
  });

  final String name;
  final String id;
  final TargetPlatform targetPlatform;
  final bool real;

  /// Returns the name that Patrol is usually interested with.
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
    if (platform == 'ios') {
      return TargetPlatform.iOS;
    } else if (platform.startsWith('android-')) {
      return TargetPlatform.android;
    } else {
      throw Exception('Unsupported platform $platform');
    }
  }
}
