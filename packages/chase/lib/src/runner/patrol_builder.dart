import '../utils/process_runner.dart';

/// Result of running `patrol build`.
class BuildResult {
  const BuildResult({
    required this.success,
    this.applicationPath,
    this.testApplicationPath,
    this.error,
  });

  final bool success;
  final String? applicationPath;
  final String? testApplicationPath;
  final String? error;
}

/// Builds Patrol test artifacts using `patrol build`.
class PatrolBuilder {
  const PatrolBuilder({required ProcessRunner processRunner})
      : _processRunner = processRunner;

  final ProcessRunner _processRunner;

  /// Builds test APK/IPA using `patrol build`.
  Future<BuildResult> build({
    required String platform,
    String? workingDirectory,
  }) async {
    final result = await _processRunner.run(
      'patrol',
      ['build', platform],
      workingDirectory: workingDirectory,
      timeout: const Duration(minutes: 15),
    );

    if (!result.success) {
      return BuildResult(
        success: false,
        error: result.stderr.isNotEmpty ? result.stderr : result.stdout,
      );
    }

    // Parse output to find artifact paths
    final paths = _parseArtifactPaths(result.stdout, platform);

    return BuildResult(
      success: true,
      applicationPath: paths['application'],
      testApplicationPath: paths['testApplication'],
    );
  }

  Map<String, String?> _parseArtifactPaths(String output, String platform) {
    String? applicationPath;
    String? testApplicationPath;

    if (platform == 'android') {
      // Default Android paths
      applicationPath = 'build/app/outputs/apk/debug/app-debug.apk';
      testApplicationPath =
          'build/app/outputs/apk/androidTest/debug/app-debug-androidTest.apk';
    } else if (platform == 'ios') {
      // Default iOS paths — actual paths depend on project configuration
      applicationPath = 'build/ios_integ/Build/Products/Debug-iphonesimulator/Runner.app';
      testApplicationPath =
          'build/ios_integ/Build/Products/Debug-iphonesimulator/RunnerUITests-Runner.app';
    }

    // Try to parse from output if available
    for (final line in output.split('\n')) {
      if (line.contains('application:') || line.contains('APK:')) {
        final match = RegExp(r':\s*(.+\.(?:apk|app|ipa))').firstMatch(line);
        if (match != null) applicationPath = match.group(1);
      }
      if (line.contains('test application:') ||
          line.contains('test APK:')) {
        final match = RegExp(r':\s*(.+\.(?:apk|app|ipa))').firstMatch(line);
        if (match != null) testApplicationPath = match.group(1);
      }
    }

    return {
      'application': applicationPath,
      'testApplication': testApplicationPath,
    };
  }
}
