import 'dart:io' as io;

import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:platform/platform.dart';

/// Machine-level tooling checks, reusing what `patrol doctor` verifies but
/// expressed as [Finding]s and scoped to the platforms the project declares.
///
/// Missing tooling for a declared platform is an Error; everything else is
/// a Notice.
class EnvironmentChecks {
  EnvironmentChecks({
    required Platform platform,
    bool Function(String tool)? isToolInstalled,
  }) : _platform = platform,
       _isToolInstalled = isToolInstalled ?? _whichTool;

  final Platform _platform;
  final bool Function(String tool) _isToolInstalled;

  static bool _whichTool(String tool) {
    final result = io.Platform.isWindows
        ? io.Process.runSync('where.exe', [tool])
        : io.Process.runSync('which', [tool]);
    return result.exitCode == 0;
  }

  List<Finding> check({
    required Set<String> declaredPlatforms,
    required bool webPresent,
    String flutterExecutable = 'flutter',
  }) {
    return [
      if (!_isToolInstalled(flutterExecutable))
        Finding(
          id: 'E0',
          severity: Severity.error,
          summary: 'Program `$flutterExecutable` not found on PATH.',
          fix:
              'Install Flutter, or point Patrol at it with '
              '--flutter-command / the PATROL_FLUTTER_COMMAND environment '
              'variable.',
        ),
      if (declaredPlatforms.contains('android')) ..._android(),
      if (declaredPlatforms.contains('ios') ||
          declaredPlatforms.contains('macos'))
        ..._apple(declaredPlatforms),
      if (webPresent) ..._web(),
    ];
  }

  List<Finding> _android() {
    return [
      if (!_isToolInstalled('adb'))
        const Finding(
          id: 'E1',
          severity: Severity.error,
          summary: 'Program `adb` not found on PATH.',
          fix: r'export PATH="$ANDROID_HOME/platform-tools:$PATH"',
        ),
      if (_platform.environment['ANDROID_HOME']?.isNotEmpty != true)
        const Finding(
          id: 'E2',
          severity: Severity.error,
          summary: r'Env var $ANDROID_HOME is not set.',
          fix: 'https://developer.android.com/tools/variables#set',
        ),
    ];
  }

  List<Finding> _apple(Set<String> declaredPlatforms) {
    final platforms = [
      'ios',
      'macos',
    ].where(declaredPlatforms.contains).join('/');

    if (!_platform.isMacOS) {
      return [
        Finding(
          id: 'E3',
          severity: Severity.notice,
          summary:
              'Building for $platforms requires a macOS host. Project-file '
              'checks still run on this machine.',
        ),
      ];
    }

    return [
      if (!_isToolInstalled('xcodebuild'))
        const Finding(
          id: 'E4',
          severity: Severity.error,
          summary: 'Program `xcodebuild` not found.',
          fix: 'Install Xcode on your Mac.',
        ),
      if (declaredPlatforms.contains('ios') &&
          !_isToolInstalled('ideviceinstaller'))
        const Finding(
          id: 'E5',
          severity: Severity.notice,
          summary:
              'Program `ideviceinstaller` not found — needed only for '
              'physical iOS devices.',
          fix: 'brew install ideviceinstaller',
        ),
    ];
  }

  List<Finding> _web() {
    return [
      for (final tool in ['node', 'npm'])
        if (!_isToolInstalled(tool))
          Finding(
            id: 'E6',
            severity: Severity.notice,
            summary:
                'Program `$tool` not found — needed to run Patrol tests '
                'on web.',
            fix: 'Install Node.js.',
          ),
    ];
  }
}
