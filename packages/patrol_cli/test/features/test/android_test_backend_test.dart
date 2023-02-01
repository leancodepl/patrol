import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:platform/platform.dart';
import 'package:test/test.dart';

final _windows = FakePlatform(operatingSystem: 'windows');
final _macos = FakePlatform(operatingSystem: 'macos');

void main() {
  group('AndroidAppOptions', () {
    late AndroidAppOptions options;

    group('correctly encodes default invocation', () {
      test('on Windows', () {
        options = AndroidAppOptions(
          target: r'C:\Users\john\app\integration_test\app_test.dart',
          flavor: null,
          dartDefines: {},
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: true);
        expect(
          invocation,
          equals([
            'gradlew.bat',
            ':app:assembleDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
          ]),
        );
      });

      test('on macOS', () {
        options = AndroidAppOptions(
          target: '/Users/john/app/integration_test/app_test.dart',
          flavor: null,
          dartDefines: {},
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: false);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleDebugAndroidTest',
            '-Ptarget=/Users/john/app/integration_test/app_test.dart',
          ]),
        );
      });
    });

    group('correctly encodes customized invocation', () {
      const dartDefines = {
        'EMAIL': 'user@example.com',
        'PASSWORD': 'ny4ncat',
        'foo': 'bar',
      };

      test('on Windows', () {
        options = AndroidAppOptions(
          target: r'C:\Users\john\app\integration_test\app_test.dart',
          flavor: 'dev',
          dartDefines: dartDefines,
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: true);
        expect(
          invocation,
          equals([
            'gradlew.bat',
            ':app:assembleDevDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbSxQQVNTV09SRD1ueTRuY2F0LGZvbz1iYXI='
          ]),
        );
      });

      test('on macOS', () {
        options = AndroidAppOptions(
          target: '/Users/john/app/integration_test/app_test.dart',
          flavor: 'dev',
          dartDefines: dartDefines,
        );

        final invocation =
            options.toGradleAssembleTestInvocation(isWindows: false);
        expect(
          invocation,
          equals([
            './gradlew',
            ':app:assembleDevDebugAndroidTest',
            '-Ptarget=/Users/john/app/integration_test/app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbSxQQVNTV09SRD1ueTRuY2F0LGZvbz1iYXI='
          ]),
        );
      });
    });
  });
}
