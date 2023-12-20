import 'dart:async';
import 'dart:io' as io;

import 'package:dispose_scope/dispose_scope.dart';
import 'package:file/file.dart';
import 'package:path/path.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/base/logger.dart';
import 'package:patrol_cli/src/base/process.dart';
import 'package:process/process.dart';
import 'package:version/version.dart';

const _defaultPackageName = 'com.example.myapp';

class SetupValidator {
  SetupValidator({
    required Directory projectRoot,
    required ProcessManager processManager,
    required Logger logger,
  })  : _projectRoot = projectRoot,
        _processManager = processManager,
        _disposeScope = DisposeScope(),
        _logger = logger;

  final Directory _projectRoot;
  final ProcessManager _processManager;
  final DisposeScope _disposeScope;
  final Logger _logger;

  Future<void> validateMainActivity() async {
    final androidBasePath = join(_projectRoot.path, 'android', 'app', 'src');

    // check if MainActivityTest.java exists
    final testDirectoryFiles = io.Directory(
      join(androidBasePath, 'androidTest', 'java'),
    ).listSync(recursive: true);
    for (final element in testDirectoryFiles) {
      if (element.path.endsWith('MainActivityTest.java')) {
        return;
      }
    }

    String? packageName;

    final mainDirectoryFiles = io.Directory(
      join(androidBasePath, 'main'),
    ).listSync(recursive: true);
    for (final element in mainDirectoryFiles) {
      if (element.path.endsWith('MainActivity.java') ||
          element.path.endsWith('MainActivity.kt')) {
        final mainActivity = io.File(element.path).readAsLinesSync();
        packageName = mainActivity
            .firstWhere((line) => line.startsWith('package'))
            .split(' ')
            .last
            .split(';')
            .first;
      }
    }

    if (packageName == null) {
      final path = _createMainActivityTest(androidBasePath);
      throwToolExit(
        'Could not find your android app package name.\n'
        'Created MainActivityTest.java under default path:\n'
        '$path\n'
        'Please replace com.example.myapp with your package name in MainActivityTest.java '
        'and change the path to match your package name.',
      );
    } else {
      final path = _createMainActivityTest(androidBasePath, packageName);
      _logger.info('Created MainActivityTest.java under $path');
    }
  }

  String _createMainActivityTest(
    String androidBasePath, [
    String? packageName,
  ]) {
    final path = joinAll([
      androidBasePath,
      'androidTest',
      'java',
      ...(packageName ?? _defaultPackageName).split('.'),
      'MainActivityTest.java',
    ]);

    io.File(path)
      ..createSync(recursive: true)
      ..writeAsStringSync(generateMainActivityTestContent(packageName));

    return path;
  }

  Future<void> checkVersionsCompatibility() async {
    Version? javaVersion;
    final javaCompleter = Completer<Version?>();

    await _disposeScope.run((scope) async {
      final process = await _processManager.start(
        ['javac', '--version'],
        workingDirectory: _projectRoot.path,
        runInShell: true,
      )
        ..disposedBy(scope);

      process.listenStdOut((line) async {
        if (line.startsWith('javac')) {
          javaCompleter.complete(Version.parse(line.split(' ').last));
        }
      }).disposedBy(scope);
    });

    javaVersion = await javaCompleter.future;
    if (javaVersion == null) {
      throwToolExit(
        'Failed to read Java version. Make sure you have Java installed and added to PATH',
      );
    } else if (javaVersion.major != 17) {
      _logger.warn(
        'You are using Java $javaVersion which can cause issues on Android.\n'
        'If you encounter any issues, try changing your Java version to 17.',
      );
    }

    String? packageVersion;
    final packageCompleter = Completer<String?>();

    await _disposeScope.run((scope) async {
      final process = await _processManager.start(
        [
          'flutter',
          '--suppress-analytics',
          '--no-version-check',
          'pub',
          'deps',
          '--style=list',
        ],
        workingDirectory: _projectRoot.path,
        runInShell: true,
      )
        ..disposedBy(scope);

      process.listenStdOut((line) async {
        if (line.startsWith('- patrol ')) {
          packageCompleter.complete(line.split(' ').last);
        }
      }).disposedBy(scope);
    });

    packageVersion = await packageCompleter.future;

    if (packageVersion == null) {
      throwToolExit(
        'Failed to read patrol version. Make sure you have patrol '
        'dependency in your pubspec.yaml file',
      );
    }

    final cliVersion = Version.parse(constants.version);
    final patrolVersion = Version.parse(packageVersion);

    final isCompatible = cliVersion.isCompatibleWith(patrolVersion);

    if (!isCompatible) {
      throwToolExit(
        'Patrol version $patrolVersion defined in the project is not compatible with patrol_cli version $cliVersion\n'
        'Please upgrade both "patrol_cli" and "patrol" dependency in project to the latest versions.',
      );
    }
  }
}

extension _VersionComparator on Version {
  /// Checks if the current Patrol CLI version is compatible with the given Patrol package version.
  bool isCompatibleWith(Version patrolVersion) {
    final cliVersionRange = toRange(_cliVersionRange);
    final versionRange = patrolVersion.toRange(_patrolVersionRange);

    if (versionRange == null || cliVersionRange == null) {
      return false;
    }

    if (cliToPatrolMap[cliVersionRange] == versionRange) {
      return true;
    } else {
      return false;
    }
  }

  _VersionRange? toRange(List<_VersionRange> versionRangeList) {
    for (final versionRange in versionRangeList) {
      if (isInRange(versionRange)) {
        return versionRange;
      }
    }
    return null;
  }

  bool isInRange(_VersionRange versionRange) {
    return this >= versionRange.min &&
        (hasNoUpperBound(versionRange) || this <= versionRange.max);
  }

  bool hasNoUpperBound(_VersionRange versionRange) {
    return versionRange.max == null;
  }
}

final _cliVersionRange = [
  _VersionRange(
    min: Version.parse('2.3.0'),
  ),
];

final _patrolVersionRange = [
  _VersionRange(
    min: Version.parse('3.0.0'),
  ),
];

final cliToPatrolMap = Map.fromIterables(
  _cliVersionRange,
  _patrolVersionRange,
);

class _VersionRange {
  _VersionRange({
    required this.min,
    // ignore: unused_element
    this.max,
  });

  final Version min;
  final Version? max;
}

String generateMainActivityTestContent([String? packageName]) {
  return '''
package ${packageName != null ? '$packageName;' : '$_defaultPackageName; // replace "com.example.myapp" with your app\'s package'}

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}

''';
}
