import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:test/test.dart';

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
            r'.\gradlew.bat',
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
            r'.\gradlew.bat',
            ':app:assembleDevDebugAndroidTest',
            r'-Ptarget=C:\Users\john\app\integration_test\app_test.dart',
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg=='
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
            '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbQ==,UEFTU1dPUkQ9bnk0bmNhdA==,Zm9vPWJhcg=='
          ]),
        );
      });
    });
  });
}
