class BuildPathCache {
  const BuildPathCache({
    required this.android,
    required this.ios,
    required this.macos,
  });

  factory BuildPathCache.fromJson(Map<String, dynamic> json) {
    return BuildPathCache(
      android: json['android'] != null
          ? AndroidPathCache.fromJson(json['android'] as Map<String, dynamic>)
          : null,
      ios: json['ios'] != null
          ? IOSPathCache.fromJson(json['ios'] as Map<String, dynamic>)
          : null,
      macos: json['macos'] != null
          ? MacOSPathCache.fromJson(json['macos'] as Map<String, dynamic>)
          : null,
    );
  }

  final AndroidPathCache? android;
  final IOSPathCache? ios;
  final MacOSPathCache? macos;

  Map<String, dynamic> toJson() {
    return {
      'android': android?.toJson(),
      'ios': ios?.toJson(),
      'macos': macos?.toJson(),
    };
  }

  BuildPathCache copyWith({
    AndroidPathCache? android,
    IOSPathCache? ios,
    MacOSPathCache? macos,
  }) {
    return BuildPathCache(
      android: android ?? this.android,
      ios: ios ?? this.ios,
      macos: macos ?? this.macos,
    );
  }
}

sealed class PlatformBuildPathCache {
  const PlatformBuildPathCache();
}

class AndroidPathCache extends PlatformBuildPathCache {
  const AndroidPathCache({required this.apkPath, required this.testApkPath});

  factory AndroidPathCache.fromJson(Map<String, dynamic> json) {
    return AndroidPathCache(
      apkPath: json['apkPath'] as String,
      testApkPath: json['testApkPath'] as String,
    );
  }

  final String apkPath;
  final String testApkPath;

  Map<String, dynamic> toJson() {
    return {'apkPath': apkPath, 'testApkPath': testApkPath};
  }
}

class IOSPathCache extends PlatformBuildPathCache {
  const IOSPathCache({required this.xctestrunPath});

  factory IOSPathCache.fromJson(Map<String, dynamic> json) {
    return IOSPathCache(xctestrunPath: json['xctestrunPath'] as String);
  }

  final String xctestrunPath;

  Map<String, dynamic> toJson() {
    return {'xctestrunPath': xctestrunPath};
  }
}

class MacOSPathCache extends PlatformBuildPathCache {
  const MacOSPathCache({required this.xctestrunPath});

  factory MacOSPathCache.fromJson(Map<String, dynamic> json) {
    return MacOSPathCache(xctestrunPath: json['xctestrunPath'] as String);
  }

  final String xctestrunPath;

  Map<String, dynamic> toJson() {
    return {'xctestrunPath': xctestrunPath};
  }
}
