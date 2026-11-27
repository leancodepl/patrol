import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:file/file.dart';
import 'package:path/path.dart' as p;
import 'package:platform/platform.dart';
import 'package:yaml/yaml.dart';

/// The platform a build is reused for.
enum ReusePlatform {
  android('android'),
  iosSimulator('ios-simulator'),
  iosDevice('ios-device');

  const ReusePlatform(this.id);

  final String id;

  /// The value passed to `flutter build bundle --target-platform`.
  String get bundleTargetPlatform => switch (this) {
    ReusePlatform.android => 'android-arm64',
    ReusePlatform.iosSimulator || ReusePlatform.iosDevice => 'ios',
  };

  bool get isIOS => this != ReusePlatform.android;
}

/// Everything besides the project files that shapes the native part of a
/// debug build: if any of it differs, the native build can't be reused.
///
/// Dart-only inputs (test targets, tags, dart-defines) are left out on
/// purpose: they live in the kernel, which --reuse-build compiles anew.
class NativeBuildInputs {
  const NativeBuildInputs({
    required this.platform,
    required this.flavor,
    required this.buildName,
    required this.buildNumber,
    required this.appServerPort,
    required this.testServerPort,
    this.fullIsolation = false,
    this.clearPermissions = false,
    this.screenshotOnFailure = false,
    this.emitTestManifest = false,
    this.noTreeShakeIcons = false,
  });

  final ReusePlatform platform;
  final String? flavor;
  final String? buildName;
  final String? buildNumber;
  final int appServerPort;
  final int testServerPort;

  // iOS only: these are compiled into the UI test runner.
  final bool fullIsolation;
  final bool clearPermissions;
  final bool screenshotOnFailure;

  /// Build-time discovery bakes the test list into the native test runner.
  final bool emitTestManifest;
  final bool noTreeShakeIcons;

  /// Identifies a build's slot in the build reuse cache: builds for another
  /// platform or flavor live next to each other and don't replace each other.
  String get cacheKey => '${platform.id}-${flavor ?? 'default'}';

  Map<String, Object?> toJson() => {
    'platform': platform.id,
    'flavor': flavor,
    'buildName': buildName,
    'buildNumber': buildNumber,
    'appServerPort': appServerPort,
    'testServerPort': testServerPort,
    if (platform.isIOS) ...{
      'fullIsolation': fullIsolation,
      'clearPermissions': clearPermissions,
      'screenshotOnFailure': screenshotOnFailure,
    },
    'emitTestManifest': emitTestManifest,
    'noTreeShakeIcons': noTreeShakeIcons,
  };
}

/// Hashes the inputs of a native build so a later run can tell whether the
/// native part of the last build is still current.
///
/// Covered: the `android/` or `ios/` directory (with the native tests that
/// build-time test discovery generates there), `pubspec.yaml`,
/// `pubspec.lock`, the native plugin list, the native code of plugins that
/// live outside the pub cache (path dependencies), the app's own assets
/// declared in `pubspec.yaml`, the Flutter revision and [NativeBuildInputs].
///
/// Not covered: assets of path dependencies and native build scripts that
/// read dart-defines. Changing those needs a full build.
class NativeFingerprinter {
  NativeFingerprinter({
    required Directory rootDirectory,
    required this._platform,
  }) : _root = rootDirectory,
       _fs = rootDirectory.fileSystem;

  final Directory _root;
  final FileSystem _fs;
  final NativePlatform _platform;

  /// Directory and file names skipped anywhere in a hashed tree: build
  /// outputs, caches, IDE state and files `flutter` regenerates on each build.
  static const _skippedNames = {
    '.DS_Store',
    '.gradle',
    '.idea',
    '.kotlin',
    '.cxx',
    '.externalNativeBuild',
    'build',
    'Pods',
    '.symlinks',
    'ephemeral',
    'xcuserdata',
    'local.properties',
    'Generated.xcconfig',
    'flutter_export_environment.sh',
    'GeneratedPluginRegistrant.java',
    'GeneratedPluginRegistrant.m',
    'GeneratedPluginRegistrant.h',
    'GeneratedPluginRegistrant.swift',
  };

  NativeFingerprint compute(
    NativeBuildInputs inputs, {
    required String flutterRevision,
  }) {
    final entries = <String, String>{};

    void addString(String key, String value) {
      entries[key] = sha256.convert(utf8.encode(value)).toString();
    }

    void addFile(String key, File file) {
      entries[key] = file.existsSync()
          ? sha256.convert(file.readAsBytesSync()).toString()
          : 'absent';
    }

    addString('build options', jsonEncode(inputs.toJson()));
    addString('Flutter version', flutterRevision);

    for (final dir in _nativeDirectories(inputs.platform, _root)) {
      _addTree(dir, _relative(dir.path), addFile);
    }

    addFile('pubspec.yaml', _root.childFile('pubspec.yaml'));
    addFile('pubspec.lock', _root.childFile('pubspec.lock'));
    addString('.flutter-plugins-dependencies', _pluginList());

    for (final pluginDir in _pathPluginDirectories(inputs.platform)) {
      for (final dir in _nativeDirectories(inputs.platform, pluginDir)) {
        _addTree(dir, dir.path, addFile);
      }
    }

    for (final asset in _assetFiles()) {
      addFile(_relative(asset.path), asset);
    }

    return NativeFingerprint(entries);
  }

  List<Directory> _nativeDirectories(ReusePlatform platform, Directory root) {
    final names = switch (platform) {
      ReusePlatform.android => const ['android'],
      ReusePlatform.iosSimulator ||
      ReusePlatform.iosDevice => const ['ios', 'darwin'],
    };
    return [
      for (final name in names)
        if (root.childDirectory(name).existsSync()) root.childDirectory(name),
    ];
  }

  void _addTree(
    Directory dir,
    String prefix,
    void Function(String key, File file) addFile,
  ) {
    final files = <File>[];
    void walk(Directory current) {
      for (final entity in current.listSync(followLinks: false)) {
        final name = p.basename(entity.path);
        if (_skippedNames.contains(name)) {
          continue;
        }
        if (entity is Directory) {
          walk(entity);
        } else if (entity is File) {
          files.add(entity);
        }
      }
    }

    walk(dir);
    files.sort((a, b) => a.path.compareTo(b.path));
    for (final file in files) {
      final relative = p.relative(file.path, from: dir.path);
      addFile('$prefix/${p.posix.joinAll(p.split(relative))}', file);
    }
  }

  /// The native plugin list without the timestamp `flutter pub get` writes.
  String _pluginList() {
    final file = _root.childFile('.flutter-plugins-dependencies');
    if (!file.existsSync()) {
      return 'absent';
    }
    try {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>
        ..remove('date_created');
      return jsonEncode(json);
    } on FormatException {
      return file.readAsStringSync();
    }
  }

  /// Plugins that aren't in the pub cache, whose native code can change
  /// without `pubspec.lock` changing.
  List<Directory> _pathPluginDirectories(ReusePlatform platform) {
    final file = _root.childFile('.flutter-plugins-dependencies');
    if (!file.existsSync()) {
      return const [];
    }
    final Map<String, dynamic> json;
    try {
      json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    } on FormatException {
      return const [];
    }
    final plugins = json['plugins'];
    if (plugins is! Map<String, dynamic>) {
      return const [];
    }
    final entries = plugins[platform.isIOS ? 'ios' : 'android'];
    if (entries is! List) {
      return const [];
    }

    final pubCache = _pubCacheDirectory();
    final dirs = <Directory>[];
    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }
      final path = entry['path'];
      if (path is! String) {
        continue;
      }
      final normalized = p.normalize(path);
      if (pubCache != null && p.isWithin(pubCache, normalized)) {
        continue;
      }
      dirs.add(_fs.directory(normalized));
    }
    dirs.sort((a, b) => a.path.compareTo(b.path));
    return dirs;
  }

  String? _pubCacheDirectory() {
    final env = _platform.environment;
    if (env['PUB_CACHE'] case final pubCache? when pubCache.isNotEmpty) {
      return p.normalize(pubCache);
    }
    if (_platform.isWindows) {
      final localAppData = env['LOCALAPPDATA'];
      return localAppData == null ? null : p.join(localAppData, 'Pub', 'Cache');
    }
    final home = env['HOME'];
    return home == null ? null : p.join(home, '.pub-cache');
  }

  /// Files of the assets and fonts the app declares in `pubspec.yaml`. A
  /// directory entry covers the files directly in it, as in Flutter.
  List<File> _assetFiles() {
    final pubspec = _root.childFile('pubspec.yaml');
    if (!pubspec.existsSync()) {
      return const [];
    }
    final Object? yaml;
    try {
      yaml = loadYaml(pubspec.readAsStringSync());
    } on YamlException {
      return const [];
    }
    if (yaml is! YamlMap) {
      return const [];
    }
    final flutter = yaml['flutter'];
    if (flutter is! YamlMap) {
      return const [];
    }

    final paths = <String>[];
    final assets = flutter['assets'];
    if (assets is YamlList) {
      for (final asset in assets) {
        if (asset is String) {
          paths.add(asset);
        } else if (asset is YamlMap && asset['path'] is String) {
          paths.add(asset['path'] as String);
        }
      }
    }
    final fonts = flutter['fonts'];
    if (fonts is YamlList) {
      for (final family in fonts) {
        if (family is! YamlMap || family['fonts'] is! YamlList) {
          continue;
        }
        for (final font in family['fonts'] as YamlList) {
          if (font is YamlMap && font['asset'] is String) {
            paths.add(font['asset'] as String);
          }
        }
      }
    }

    final files = <String, File>{};
    for (final path in paths) {
      final resolved = p.join(_root.path, path);
      if (path.endsWith('/')) {
        final dir = _fs.directory(resolved);
        if (!dir.existsSync()) {
          continue;
        }
        for (final entity in dir.listSync()) {
          if (entity is File) {
            files[entity.path] = entity;
          }
        }
      } else {
        files[resolved] = _fs.file(resolved);
      }
    }
    final sorted = files.values.toList()
      ..sort((a, b) => a.path.compareTo(b.path));
    return sorted;
  }

  String _relative(String path) =>
      p.posix.joinAll(p.split(p.relative(path, from: _root.path)));
}

/// Hashes of each input of a native build, keyed by a readable name (a
/// path, or what the input is).
class NativeFingerprint {
  NativeFingerprint(Map<String, String> entries)
    : entries = Map.unmodifiable(
        Map.fromEntries(
          entries.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
        ),
      );

  final Map<String, String> entries;

  late final String hash = sha256
      .convert(utf8.encode(jsonEncode(entries)))
      .toString();

  /// Names of the inputs that differ between this and [other].
  List<String> differences(Map<String, String> other) {
    final keys = {...entries.keys, ...other.keys}.toList()..sort();
    return [
      for (final key in keys)
        if (entries[key] != other[key]) key,
    ];
  }
}
