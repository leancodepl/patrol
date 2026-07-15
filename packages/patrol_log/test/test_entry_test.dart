import 'package:patrol_log/patrol_log.dart';
import 'package:patrol_log/src/emojis.dart';
import 'package:test/test.dart';

void main() {
  group('TestEntry.pretty()', () {
    test('prints full name for a started test', () {
      final entry = TestEntry(
        name: 'example_test signs up successfully',
        status: TestEntryStatus.start,
      );

      expect(
        entry.pretty(),
        '${Emojis.testStart} example_test signs up successfully',
      );
    });

    test('strips top-level file prefix from a finished test name', () {
      final entry = TestEntry(
        name: 'example_test signs up successfully',
        status: TestEntryStatus.success,
      );

      expect(
        entry.pretty(),
        startsWith('${Emojis.success} signs up successfully'),
      );
      expect(entry.pretty(), contains('/example_test.dart'));
    });

    test('strips nested file prefix from a finished test name', () {
      final entry = TestEntry(
        name: 'permissions.permissions_location_test grants permission',
        status: TestEntryStatus.failure,
      );

      expect(entry.pretty(), startsWith('${Emojis.failure} grants permission'));
      expect(
        entry.pretty(),
        contains('/permissions/permissions_location_test.dart'),
      );
    });

    test(
      'does not eat the first word of a finished test name without file prefix',
      () {
        // Regression test for https://github.com/leancodepl/patrol/issues/3048
        final entry = TestEntry(
          name: 'Sign up full onboarding flow',
          status: TestEntryStatus.failure,
        );

        expect(
          entry.pretty(),
          '${Emojis.failure} Sign up full onboarding flow',
        );
      },
    );

    test('appends error to a failed test without file prefix', () {
      final entry = TestEntry(
        name: 'Sign up full onboarding flow',
        status: TestEntryStatus.failure,
        error: 'some error',
      );

      expect(
        entry.pretty(),
        '${Emojis.failure} Sign up full onboarding flow\nsome error',
      );
    });

    test('appends error to a failed test with file prefix', () {
      final entry = TestEntry(
        name: 'example_test signs up successfully',
        status: TestEntryStatus.failure,
        error: 'some error',
      );

      expect(
        entry.pretty(),
        startsWith('${Emojis.failure} signs up successfully'),
      );
      expect(entry.pretty(), endsWith('\nsome error'));
    });
  });
}
