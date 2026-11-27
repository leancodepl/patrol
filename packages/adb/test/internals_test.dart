import 'package:adb/adb.dart';
import 'package:adb/src/internals.dart';
import 'package:test/test.dart';

void main() {
  group('waitUntilReady', () {
    test('returns once the check passes', () async {
      var checks = 0;

      await waitUntilReady(
        'The service',
        () async => ++checks == 3,
        timeout: const Duration(seconds: 5),
        interval: Duration.zero,
      );

      expect(checks, 3);
    });

    test('gives up with AdbTimeout when the check never passes', () async {
      await expectLater(
        waitUntilReady(
          'The package service on emulator-5554',
          () async => false,
          timeout: const Duration(milliseconds: 50),
          interval: const Duration(milliseconds: 10),
        ),
        throwsA(
          isA<AdbTimeout>().having(
            (e) => e.message,
            'message',
            contains('The package service on emulator-5554'),
          ),
        ),
      );
    });
  });
}
