import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/src/duration_extension.dart';
import 'package:test/test.dart';

void main() {
  group('DurationExtension', () {
    test('toFormattedString formats duration correctly', () {
      expect(const Duration(seconds: 5).toFormattedString(), '5s');
      expect(
        const Duration(minutes: 1, seconds: 5).toFormattedString(),
        '1m 5s',
      );
      expect(
        const Duration(hours: 1, minutes: 1, seconds: 5).toFormattedString(),
        '1h 1m 5s',
      );
      expect(const Duration(hours: 2).toFormattedString(), '2h 0m 0s');
      expect(Duration.zero.toFormattedString(), '0s');
      expect(const Duration(seconds: 60).toFormattedString(), '1m 0s');
    });
  });

  group('TestEntry', () {
    test(
      'nameWithPath uses default patrol_test directory when no environment variable is set',
      () {
        final testEntry = TestEntry(
          name: 'example.login_test test name',
          status: TestEntryStatus.success,
        );

        expect(
          testEntry.nameWithPath,
          contains('(patrol_test/example/login_test.dart)'),
        );
      },
    );
  });
}
