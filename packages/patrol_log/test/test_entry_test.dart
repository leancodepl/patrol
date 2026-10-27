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

    test(
      'does not strip a first word containing a dot (class name, version)',
      () {
        final classNameEntry = TestEntry(
          name: 'MyClass.myMethod should work',
          status: TestEntryStatus.failure,
        );
        expect(
          classNameEntry.pretty(),
          '${Emojis.failure} MyClass.myMethod should work',
        );

        final versionEntry = TestEntry(
          name: '1.0 should do something',
          status: TestEntryStatus.failure,
        );
        expect(
          versionEntry.pretty(),
          '${Emojis.failure} 1.0 should do something',
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

  group('TestEntry.nameWithPath', () {
    // Covers the failed-tests summary, which renders entries via
    // nameWithPath rather than pretty().
    test('returns the raw name when there is no file prefix', () {
      final entry = TestEntry(
        name: 'Sign up full onboarding flow',
        status: TestEntryStatus.failure,
      );

      expect(entry.nameWithPath, 'Sign up full onboarding flow');
    });

    test('renders the file path when the name has a file prefix', () {
      final entry = TestEntry(
        name: 'example_test signs up successfully',
        status: TestEntryStatus.failure,
      );

      expect(entry.nameWithPath, startsWith('signs up successfully'));
      expect(entry.nameWithPath, contains('/example_test.dart'));
    });
  });

  group('custom test file suffix', () {
    test('strips a top-level file prefix ending with the suffix', () {
      final entry = TestEntry(
        name: 'example_spec grants permission',
        status: TestEntryStatus.success,
      );

      final pretty = entry.pretty(testFileSuffix: '_spec.dart');
      expect(pretty, startsWith('${Emojis.success} grants permission'));
      expect(pretty, contains('/example_spec.dart'));
    });

    test('strips a nested file prefix ending with the suffix', () {
      final entry = TestEntry(
        name: 'flows.example_spec grants permission',
        status: TestEntryStatus.failure,
      );

      final nameWithPath = entry.nameWithPathFor(testFileSuffix: '_spec.dart');
      expect(nameWithPath, startsWith('grants permission'));
      expect(nameWithPath, contains('/flows/example_spec.dart'));
    });

    test('sanitizes non-identifier characters in the suffix', () {
      final entry = TestEntry(
        name: 'example_spec grants permission',
        status: TestEntryStatus.success,
      );

      final nameWithPath = entry.nameWithPathFor(testFileSuffix: '.spec.dart');
      expect(nameWithPath, startsWith('grants permission'));
      expect(nameWithPath, contains('/example.spec.dart'));
    });

    test('keeps the name intact when the suffix is only .dart', () {
      final entry = TestEntry(
        name: 'Sign up full onboarding flow',
        status: TestEntryStatus.success,
      );

      expect(
        entry.nameWithPathFor(testFileSuffix: '.dart'),
        'Sign up full onboarding flow',
      );
    });

    test('keeps a default-suffix-like first word intact', () {
      final entry = TestEntry(
        name: 'unit_test grants permission',
        status: TestEntryStatus.success,
      );

      expect(
        entry.nameWithPathFor(testFileSuffix: '_spec.dart'),
        'unit_test grants permission',
      );
    });
  });

  group('TestEntry.fileNameSuffix', () {
    test('drops the .dart extension', () {
      expect(TestEntry.fileNameSuffix('_test.dart'), '_test');
      expect(TestEntry.fileNameSuffix('_spec.dart'), '_spec');
    });

    test('replaces non-identifier characters with underscores', () {
      expect(TestEntry.fileNameSuffix('.spec.dart'), '_spec');
      expect(TestEntry.fileNameSuffix('-e2e.dart'), '_e2e');
    });
  });
}
