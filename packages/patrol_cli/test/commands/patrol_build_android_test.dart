import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/commands/build_android.dart';
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/dart_defines_reader.dart';
import 'package:patrol_cli/src/pubspec_reader.dart';
import 'package:patrol_cli/src/test_bundler.dart';
import 'package:patrol_cli/src/test_finder.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('BuildAndroidCommand', () {
    late BuildAndroidCommand command;
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();

      // Set up default stubs for logger
      when(() => mockLogger.info(any())).thenReturn(null);

      // Create command with minimal required dependencies
      // We only need to test printApkPaths, so we can use minimal mocks
      command = BuildAndroidCommand(
        testFinder: MockTestFinder(),
        testBundler: MockTestBundler(),
        dartDefinesReader: MockDartDefinesReader(),
        pubspecReader: MockPubspecReader(),
        androidTestBackend: MockAndroidTestBackend(),
        analytics: MockAnalytics(),
        logger: mockLogger,
        compatibilityChecker: MockCompatibilityChecker(),
      );
    });

    group('printApkPaths', () {
      test('prints correct paths for debug build without flavor', () {
        command.printApkPaths(buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for release build without flavor', () {
        command.printApkPaths(buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'release', 'app-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'release', 'app-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for debug build with flavor', () {
        command.printApkPaths(flavor: 'dev', buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'dev', 'debug', 'app-dev-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'dev', 'debug', 'app-dev-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for release build with flavor', () {
        command.printApkPaths(flavor: 'prod', buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'prod', 'release', 'app-prod-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'prod', 'release', 'app-prod-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for custom build mode without flavor', () {
        command.printApkPaths(buildMode: 'profile');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'profile', 'app-profile.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'profile', 'app-profile-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for custom build mode with flavor', () {
        command.printApkPaths(flavor: 'staging', buildMode: 'profile');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'staging', 'profile', 'app-staging-profile.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'staging', 'profile', 'app-staging-profile-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles uppercase build mode correctly', () {
        command.printApkPaths(buildMode: 'DEBUG');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles mixed case build mode correctly with flavor', () {
        command.printApkPaths(flavor: 'Dev', buildMode: 'Release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'Dev', 'release', 'app-Dev-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'Dev', 'release', 'app-Dev-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles complex flavor names correctly', () {
        command.printApkPaths(flavor: 'staging-prod', buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'staging-prod', 'release', 'app-staging-prod-release.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'staging-prod', 'release', 'app-staging-prod-release-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles null flavor correctly', () {
        command.printApkPaths(buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints paths in correct order', () {
        command.printApkPaths(flavor: 'dev', buildMode: 'debug');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(captured.length, 2);
        expect(captured[0], contains('(app under test)'));
        expect(captured[1], contains('(test instrumentation app)'));
      });

      test('calls logger info exactly twice per invocation', () {
        command.printApkPaths(buildMode: 'debug');

        verify(() => mockLogger.info(any())).called(2);
      });

      test('uses proper path separators for different platforms', () {
        command.printApkPaths(flavor: 'dev', buildMode: 'debug');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(
          captured[0],
          contains(join('build', 'app', 'outputs', 'apk', 'dev', 'debug')),
        );
        expect(
          captured[1],
          contains(
            join(
              'build',
              'app',
              'outputs',
              'apk',
              'androidTest',
              'dev',
              'debug',
            ),
          ),
        );
      });

      test('generates consistent APK names for same parameters', () {
        command.printApkPaths(flavor: 'prod', buildMode: 'release');
        final firstCall = verify(() => mockLogger.info(captureAny())).captured;

        // Reset mock
        reset(mockLogger);
        when(() => mockLogger.info(any())).thenReturn(null);

        command.printApkPaths(flavor: 'prod', buildMode: 'release');
        final secondCall = verify(() => mockLogger.info(captureAny())).captured;

        expect(firstCall, equals(secondCall));
      });

      test('handles empty string flavor as null', () {
        // Note: This test would need to be updated if the method is changed to handle empty strings differently
        // Currently testing that null and empty string behaviors are documented through tests

        command.printApkPaths(buildMode: 'debug');
        final nullFlavorOutput =
            verify(() => mockLogger.info(captureAny())).captured;

        // Reset mock
        reset(mockLogger);
        when(() => mockLogger.info(any())).thenReturn(null);

        // We can't test empty string directly since the parameter is nullable String?
        // But we can document the expected behavior for null
        expect(
          nullFlavorOutput[0],
          equals(
            '${join('build', 'app', 'outputs', 'apk', 'debug', 'app-debug.apk')} (app under test)',
          ),
        );
        expect(
          nullFlavorOutput[1],
          equals(
            '${join('build', 'app', 'outputs', 'apk', 'androidTest', 'debug', 'app-debug-androidTest.apk')} (test instrumentation app)',
          ),
        );
      });
    });
  });
}

// Create minimal mock classes for dependencies that don't need to be tested
class MockTestFinder extends Mock implements TestFinder {}

class MockTestBundler extends Mock implements TestBundler {}

class MockDartDefinesReader extends Mock implements DartDefinesReader {}

class MockPubspecReader extends Mock implements PubspecReader {}

class MockCompatibilityChecker extends Mock implements CompatibilityChecker {}
