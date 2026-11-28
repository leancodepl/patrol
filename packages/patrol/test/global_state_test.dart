import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/global_state.dart'
    show isRunnable, lastRunnableEntryName;
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart' show LocalTest;
import 'package:test_api/src/backend/metadata.dart';

void main() {
  LocalTest localTest(String name, {bool skip = false}) =>
      LocalTest(name, Metadata(skip: skip), () {});

  group('lastRunnableEntryName()', () {
    test('passes over skipped tests at the end', () {
      final group = Group('example_test', [
        localTest('example_test first'),
        localTest('example_test second'),
        localTest('example_test third', skip: true),
      ]);

      expect(lastRunnableEntryName(group), 'second');
    });

    test('passes over a skipped group at the end', () {
      final group = Group('example_test', [
        localTest('example_test first'),
        Group('example_test skipped', [
          localTest('example_test skipped only'),
        ], metadata: Metadata(skip: true)),
      ]);

      expect(lastRunnableEntryName(group), 'first');
    });

    test('passes over a group whose tests are all skipped', () {
      final group = Group('example_test', [
        Group('example_test alpha', [localTest('example_test alpha one')]),
        Group('example_test bravo', [
          localTest('example_test bravo one', skip: true),
        ]),
      ]);

      expect(lastRunnableEntryName(group), 'alpha');
    });

    test('is null when every test is skipped', () {
      final group = Group('example_test', [
        localTest('example_test first', skip: true),
      ]);

      expect(lastRunnableEntryName(group), isNull);
    });
  });

  test('isRunnable() leaves the test explorer out', () {
    expect(isRunnable(localTest('patrol_test_explorer')), isFalse);
  });
}
