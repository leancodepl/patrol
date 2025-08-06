import 'package:mocktail/mocktail.dart';
import 'package:path/path.dart' show join;
import 'package:patrol_cli/src/commands/build_ios.dart';
import 'package:test/test.dart';

import '../src/mocks.dart';

void main() {
  group('BuildIOSCommand', () {
    late BuildIOSCommand command;
    late MockLogger mockLogger;

    setUp(() {
      mockLogger = MockLogger();
      when(() => mockLogger.info(any())).thenReturn(null);

      command = BuildIOSCommand(
        testFinder: MockTestFinder(),
        testBundler: MockTestBundler(),
        dartDefinesReader: MockDartDefinesReader(),
        pubspecReader: MockPubspecReader(),
        iosTestBackend: MockIOSTestBackend(),
        analytics: MockAnalytics(),
        logger: mockLogger,
        compatibilityChecker: MockCompatibilityChecker(),
      );
    });

    group('printBinaryPaths', () {
      test('prints correct paths for simulator build', () {
        command.printBinaryPaths(simulator: true, buildMode: 'debug');

        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'debug-iphonesimulator', 'Runner.app')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'debug-iphonesimulator', 'RunnerUITests-Runner.app')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('prints correct paths for device build', () {
        command.printBinaryPaths(simulator: false, buildMode: 'release');

        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'release-iphoneos', 'Runner.app')} (app under test)',
          ),
        ).called(1);
        verify(
          () => mockLogger.info(
            '${join('build', 'ios_integ', 'Build', 'Products', 'release-iphoneos', 'RunnerUITests-Runner.app')} (test instrumentation app)',
          ),
        ).called(1);
      });

      test('handles different build modes correctly', () {
        command.printBinaryPaths(simulator: true, buildMode: 'profile');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(captured[0], contains('profile-iphonesimulator'));
        expect(captured[1], contains('profile-iphonesimulator'));
      });

      test('calls logger info exactly twice', () {
        command.printBinaryPaths(simulator: false, buildMode: 'debug');

        verify(() => mockLogger.info(any())).called(2);
      });

      test('prints paths in correct order', () {
        command.printBinaryPaths(simulator: true, buildMode: 'debug');

        final captured = verify(() => mockLogger.info(captureAny())).captured;
        expect(captured[0], contains('Runner.app (app under test)'));
        expect(
          captured[1],
          contains('RunnerUITests-Runner.app (test instrumentation app)'),
        );
      });
    });
  });
}
