import 'package:mocktail/mocktail.dart';
import 'package:patrol_cli/src/base/exceptions.dart';
import 'package:patrol_cli/src/crossplatform/test_discovery_mode.dart';
import 'package:patrol_cli/src/devices.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  late MockLogger logger;

  setUp(() {
    logger = MockLogger();
  });

  bool resolve({
    TargetPlatform targetPlatform = TargetPlatform.android,
    bool? flag,
    bool? pubspecValue,
    String testDirectory = 'patrol_test',
    bool defaultValue = true,
    String? setupProblem,
  }) => resolveEmitTestManifest(
    targetPlatform: targetPlatform,
    flag: flag,
    pubspecValue: pubspecValue,
    testDirectory: testDirectory,
    logger: logger,
    defaultValue: defaultValue,
    setupProblem: setupProblem,
  );

  group('resolveEmitTestManifest', () {
    test('is on by default', () {
      expect(resolve(), isTrue);
    });

    test('uses the given default when nothing is set', () {
      expect(resolve(defaultValue: false), isFalse);
    });

    test('pubspec overrides the default', () {
      expect(resolve(pubspecValue: false), isFalse);
      expect(resolve(pubspecValue: true, defaultValue: false), isTrue);
    });

    test('the flag overrides pubspec', () {
      expect(resolve(flag: false, pubspecValue: true), isFalse);
      expect(resolve(flag: true, pubspecValue: false), isTrue);
    });

    test('is off without a warning or error on web', () {
      expect(
        resolve(
          targetPlatform: TargetPlatform.web,
          testDirectory: 'integration_test',
          pubspecValue: true,
        ),
        isFalse,
      );
      expect(resolve(targetPlatform: TargetPlatform.web, flag: true), isFalse);
      verifyNever(() => logger.warn(any()));
    });

    test('is on by default on iOS and macOS', () {
      expect(resolve(targetPlatform: TargetPlatform.iOS), isTrue);
      expect(resolve(targetPlatform: TargetPlatform.macOS), isTrue);
    });

    test('falls back to runtime discovery under integration_test/', () {
      expect(resolve(testDirectory: 'integration_test'), isFalse);
      verify(
        () => logger.warn(any(that: contains('integration_test'))),
      ).called(1);
    });

    test('stays quiet under integration_test/ when opted out', () {
      expect(
        resolve(testDirectory: 'integration_test', pubspecValue: false),
        isFalse,
      );
      expect(
        resolve(testDirectory: 'integration_test', defaultValue: false),
        isFalse,
      );
      verifyNever(() => logger.warn(any()));
    });

    test('fails on an explicit opt-in under integration_test/', () {
      expect(
        () => resolve(testDirectory: 'integration_test/e2e', flag: true),
        throwsA(isA<ToolExit>()),
      );
      expect(
        () => resolve(testDirectory: 'integration_test', pubspecValue: true),
        throwsA(isA<ToolExit>()),
      );
    });
  });

  group('resolveEmitTestManifest with a setup problem', () {
    const problem = "RunnerUITests.m doesn't include the generated tests.";

    test('falls back to runtime discovery with the problem as a warning', () {
      expect(resolve(setupProblem: problem), isFalse);
      verify(() => logger.warn(any(that: contains(problem)))).called(1);
    });

    test('fails on an explicit opt-in', () {
      expect(
        () => resolve(setupProblem: problem, flag: true),
        throwsA(isA<ToolExit>()),
      );
      expect(
        () => resolve(setupProblem: problem, pubspecValue: true),
        throwsA(isA<ToolExit>()),
      );
    });

    test('stays quiet when discovery is off', () {
      expect(resolve(setupProblem: problem, pubspecValue: false), isFalse);
      expect(resolve(setupProblem: problem, defaultValue: false), isFalse);
      verifyNever(() => logger.warn(any()));
    });
  });

  group('isUnderIntegrationTest', () {
    test('matches integration_test and its subdirectories', () {
      expect(isUnderIntegrationTest('integration_test'), isTrue);
      expect(isUnderIntegrationTest('integration_test/'), isTrue);
      expect(isUnderIntegrationTest('./integration_test/e2e'), isTrue);
      expect(isUnderIntegrationTest(r'integration_test\e2e'), isTrue);
    });

    test('ignores other directories', () {
      expect(isUnderIntegrationTest('patrol_test'), isFalse);
      expect(isUnderIntegrationTest('test/integration_test'), isFalse);
      expect(isUnderIntegrationTest('integration_tests'), isFalse);
    });
  });
}
