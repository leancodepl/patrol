// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, implementation_imports
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/common.dart'
    show createDartTestGroup, deduplicateGroupEntryName;
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/metadata.dart';

typedef GroupEntryType = DartGroupEntry_GroupEntryType;

void main() {
  group('createDartTestGroup()', () {
    test('fails if a test is defined at top-level', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        LocalTest('some_test', Metadata.empty, () => null),
        Group('example_test', [
          LocalTest('example_test some example test', Metadata.empty, () {}),
        ])
      ]);

      // when
      DartGroupEntry callback() => createDartTestGroup(topLevelGroup);

      // then
      expect(
        callback,
        throwsA(isA<StateError>()),
      );
    });

    test('smoke test 1', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group(
          'example_test',
          [
            Group('example_test alpha', [
              _localTest('example_test alpha first'),
              _localTest('example_test alpha second'),
            ]),
            Group('example_test bravo', [
              _localTest('example_test bravo first'),
              _localTest('example_test bravo second'),
            ]),
          ],
        ),
        Group('open_app_test', [
          _localTest('open_app_test open maps'),
          _localTest('open_app_test open browser'),
        ]),
      ]);

      // when
      final dartTestGroup = createDartTestGroup(topLevelGroup);

      // then
      expect(
        dartTestGroup,
        equals(
          DartGroupEntry(
            name: '',
            type: GroupEntryType.GROUP,
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.GROUP,
                entries: [
                  DartGroupEntry(
                    name: 'alpha',
                    type: GroupEntryType.GROUP,
                    entries: [
                      DartGroupEntry(name: 'first', type: GroupEntryType.TEST),
                      DartGroupEntry(name: 'second', type: GroupEntryType.TEST),
                    ],
                  ),
                  DartGroupEntry(
                    name: 'bravo',
                    type: GroupEntryType.GROUP,
                    entries: [
                      DartGroupEntry(name: 'first', type: GroupEntryType.TEST),
                      DartGroupEntry(name: 'second', type: GroupEntryType.TEST),
                    ],
                  ),
                ],
              ),
              DartGroupEntry(
                name: 'open_app_test',
                type: GroupEntryType.GROUP,
                entries: [
                  DartGroupEntry(name: 'open maps', type: GroupEntryType.TEST),
                  DartGroupEntry(
                    name: 'open browser',
                    type: GroupEntryType.TEST,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('smoke test 2', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group(
          'example_test',
          [
            _localTest('example_test alpha'),
            Group('example_test bravo', [
              _localTest('example_test bravo first'),
              _localTest('example_test bravo second'),
            ]),
            _localTest('example_test charlie'),
            Group('example_test delta', [
              _localTest('example_test delta first'),
              _localTest('example_test delta second'),
            ]),
            _localTest('example_test echo'),
          ],
        ),
      ]);

      // when
      final dartTestGroup = createDartTestGroup(topLevelGroup);

      // then
      expect(
        dartTestGroup,
        equals(
          DartGroupEntry(
            name: '',
            type: GroupEntryType.GROUP,
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.GROUP,
                entries: [
                  DartGroupEntry(name: 'alpha', type: GroupEntryType.TEST),
                  DartGroupEntry(
                    name: 'bravo',
                    type: GroupEntryType.GROUP,
                    entries: [
                      DartGroupEntry(name: 'first', type: GroupEntryType.TEST),
                      DartGroupEntry(name: 'second', type: GroupEntryType.TEST),
                    ],
                  ),
                  DartGroupEntry(name: 'charlie', type: GroupEntryType.TEST),
                  DartGroupEntry(
                    name: 'delta',
                    type: GroupEntryType.GROUP,
                    entries: [
                      DartGroupEntry(name: 'first', type: GroupEntryType.TEST),
                      DartGroupEntry(name: 'second', type: GroupEntryType.TEST),
                    ],
                  ),
                  DartGroupEntry(name: 'echo', type: GroupEntryType.TEST),
                ],
              ),
            ],
          ),
        ),
      );
    });
  });

  group('deduplicateGroupEntryName()', () {
    test('deduplicates group entry names', () {
      // given
      const parentEntryName = 'example_test example_test.dart alpha';
      const currentEntryName = 'example_test example_test.dart alpha first';

      // when
      final result = deduplicateGroupEntryName(
        parentEntryName,
        currentEntryName,
      );

      // then
      expect(result, equals('first'));
    });
  });
}

LocalTest _localTest(String name) => LocalTest(name, Metadata.empty, () {});
