import 'package:patrol_cli/src/features/test/android_test_runner.dart';
import 'package:patrol_cli/src/features/test/test_runner.dart';
import 'package:test/test.dart';

void main() {
  group('AndroidTestRunner', () {
    group('translate()', () {
      test('correctly encodes simple test invocation', () {
        final options = AppOptions(
          target: '/home/john/flutterapp/integration_test/app_test.dart',
          flavor: null,
          dartDefines: {},
          platform: Platform.android,
        );

        final invocation = AndroidTestRunner.translate(options);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:connectedDebugAndroidTest',
            '-Ptarget=/home/john/flutterapp/integration_test/app_test.dart',
            '-Pdart-defines=""'
          ]),
        );
      });

      test('correctly encodes complex test invocation', () {
        final options = AppOptions(
          target: '/home/john/flutterapp/integration_test/app_test.dart',
          flavor: 'dev',
          dartDefines: {
            'EMAIL': 'user@example.com',
            'PASSWORD': 'ny4ncat',
            'foo': 'bar',
          },
          platform: Platform.android,
        );

        final invocation = AndroidTestRunner.translate(options);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:connectedDevDebugAndroidTest',
            '-Ptarget=/home/john/flutterapp/integration_test/app_test.dart',
            '-Pdart-defines="RU1BSUw9dXNlckBleGFtcGxlLmNvbSxQQVNTV09SRD1ueTRuY2F0LGZvbz1iYXI="'
          ]),
        );
      });
    });
  });
}
