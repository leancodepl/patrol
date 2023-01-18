import 'package:patrol_cli/src/features/test/android_test_backend.dart';
import 'package:test/test.dart';

void main() {
  group('AndroidAppOptions', () {
    late AndroidAppOptions options;

    test('correctly encodes default invocation', () {
      options = AndroidAppOptions(
        target: '/home/john/flutterapp/integration_test/app_test.dart',
        flavor: null,
        dartDefines: {},
      );

      final invocation = options.toGradleInvocation();
      expect(
        invocation,
        equals([
          './gradlew',
          ':app:connectedDebugAndroidTest',
          '-Ptarget=/home/john/flutterapp/integration_test/app_test.dart',
        ]),
      );
    });

    test('correctly encodes customized invocation', () {
      options = AndroidAppOptions(
        target: '/home/john/flutterapp/integration_test/app_test.dart',
        flavor: 'dev',
        dartDefines: {
          'EMAIL': 'user@example.com',
          'PASSWORD': 'ny4ncat',
          'foo': 'bar',
        },
      );

      final invocation = options.toGradleInvocation();
      expect(
        invocation,
        equals([
          './gradlew',
          ':app:connectedDevDebugAndroidTest',
          '-Ptarget=/home/john/flutterapp/integration_test/app_test.dart',
          '-Pdart-defines=RU1BSUw9dXNlckBleGFtcGxlLmNvbSxQQVNTV09SRD1ueTRuY2F0LGZvbz1iYXI='
        ]),
      );
    });
  });
}
