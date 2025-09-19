import 'dart:convert';

import 'package:file/file.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/crossplatform/build_path_cache.dart';

/// Writes command options to a JSON file in the integration_test directory
/// for use during test execution.
class BuildPathCacheManager {
  BuildPathCacheManager({
    required Directory projectRoot,
    required Logger logger,
  }) : _projectRoot = projectRoot,
       _logger = logger;

  final Directory _projectRoot;
  final Logger _logger;

  /// Writes command options to patrol_options.json in integration_test directory.
  void updateBuildPathCache(PlatformBuildPathCache cache) {
    // TODO: KrzysztofMamak - Update to custom path
    final integrationTestDir = _projectRoot.childDirectory('integration_test');

    final optionsFile = integrationTestDir.childFile('build_path_cache.json');

    BuildPathCache? currentCache;
    if (!optionsFile.existsSync()) {
      optionsFile.createSync();
    } else {
      currentCache = getCurrentCache();
    }

    final effectiveCache =
        currentCache?.copyWith(
          android: cache is AndroidPathCache ? cache : null,
          ios: cache is IOSPathCache ? cache : null,
          macos: cache is MacOSPathCache ? cache : null,
        ) ??
        BuildPathCache(
          android: cache is AndroidPathCache ? cache : null,
          ios: cache is IOSPathCache ? cache : null,
          macos: cache is MacOSPathCache ? cache : null,
        );

    final jsonData = effectiveCache.toJson();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    try {
      optionsFile.writeAsStringSync(jsonString);
      _logger.detail('Build path cache saved to ${optionsFile.path}');
    } catch (err) {
      _logger.err('Failed to write build path cache: $err');
      rethrow;
    }
  }

  BuildPathCache? getCurrentCache() {
    // TODO: KrzysztofMamak - Update to custom path
    final integrationTestDir = _projectRoot.childDirectory('integration_test');

    final cacheFile = integrationTestDir.childFile('build_path_cache.json');

    if (cacheFile.existsSync()) {
      final currentCacheJsonString = cacheFile.readAsStringSync();
      final currentCacheJson =
          json.decode(currentCacheJsonString) as Map<String, dynamic>;

      return BuildPathCache.fromJson(currentCacheJson);
    }

    return null;
  }
}
