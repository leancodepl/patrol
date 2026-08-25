import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/common.dart'
    show
        createDartTestGroup,
        deduplicateGroupEntryName,
        namesWithPathSeparator,
        pathSeparatorNameError;
import 'package:patrol/src/platform/contracts/contracts.dart';
import 'package:test_api/backend.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart' show LocalTest;
import 'package:test_api/src/backend/metadata.dart';

void main() {
  group('createDartTestGroup()', () {
    test('fails if a test is defined at top-level', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        LocalTest('some_test', Metadata.empty, () {}),
        Group('example_test', [
          LocalTest('example_test some example test', Metadata.empty, () {}),
        ]),
      ]);

      // when
      DartGroupEntry callback() => createDartTestGroup(topLevelGroup);

      // then
      expect(callback, throwsA(isA<StateError>()));
    });

    test('smoke test 1', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          Group('example_test alpha', [
            _localTest('example_test alpha first'),
            _localTest('example_test alpha second'),
          ]),
          Group('example_test bravo', [
            _localTest('example_test bravo first'),
            _localTest('example_test bravo second'),
          ]),
        ]),
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
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  DartGroupEntry(
                    name: 'alpha',
                    type: GroupEntryType.group,
                    skip: false,
                    tags: const [],
                    entries: [_testEntry('first'), _testEntry('second')],
                  ),
                  DartGroupEntry(
                    name: 'bravo',
                    type: GroupEntryType.group,
                    skip: false,
                    tags: const [],
                    entries: [_testEntry('first'), _testEntry('second')],
                  ),
                ],
              ),
              DartGroupEntry(
                name: 'open_app_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [_testEntry('open maps'), _testEntry('open browser')],
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
        Group('example_test', [
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
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  _testEntry('alpha'),
                  DartGroupEntry(
                    name: 'bravo',
                    type: GroupEntryType.group,
                    skip: false,
                    tags: const [],
                    entries: [_testEntry('first'), _testEntry('second')],
                  ),
                  _testEntry('charlie'),
                  DartGroupEntry(
                    name: 'delta',
                    type: GroupEntryType.group,
                    skip: false,
                    tags: const [],
                    entries: [_testEntry('first'), _testEntry('second')],
                  ),
                  _testEntry('echo'),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('smoke test 3 (long test names)', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          _localTest('example_test alpha'), // 18 chars
          _localTest('example_test zielony kocyk'), // 26 chars, 6 too many
        ]),
      ]);

      // when
      final dartTestGroup = createDartTestGroup(
        topLevelGroup,
        maxTestCaseLength: 20,
      );

      // then
      expect(
        dartTestGroup,
        equals(
          DartGroupEntry(
            name: '',
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [_testEntry('alpha'), _testEntry('zielony')],
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

  group('skip group of tests', () {
    test('skip test param should be passed in DartGroupEntry', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          _localTest('example_test alpha'),
        ], metadata: Metadata(skip: true)),
        Group('example2_test', [
          _localTest('example2_test alpha'),
          _localTest('example2_test bravo first'),
          _localTest('example2_test bravo second'),
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
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: true,
                tags: const [],
                entries: [_testEntry('alpha')],
              ),
              DartGroupEntry(
                name: 'example2_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  _testEntry('alpha'),
                  _testEntry('bravo first'),
                  _testEntry('bravo second'),
                ],
              ),
            ],
          ),
        ),
      );
    });
  });

  group('test with tags', () {
    test('filter test, when tags are null', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          _localTest('example_test alpha', metadata: Metadata(tags: ['tag1'])),
          _localTest(
            'example_test bravo first',
            metadata: Metadata(tags: ['tag2']),
          ),
          _localTest(
            'example_test bravo second',
            metadata: Metadata(tags: ['tag3']),
          ),
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
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  _testEntry('alpha', tags: ['tag1']),
                  _testEntry('bravo first', tags: ['tag2']),
                  _testEntry('bravo second', tags: ['tag3']),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('filter included tags', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          _localTest('example_test alpha', metadata: Metadata(tags: ['tag1'])),
          _localTest(
            'example_test bravo first',
            metadata: Metadata(tags: ['tag2']),
          ),
          _localTest(
            'example_test bravo second',
            metadata: Metadata(tags: ['tag3']),
          ),
        ]),
      ]);

      // when
      final dartTestGroup = createDartTestGroup(topLevelGroup, tags: 'tag1');

      // then
      expect(
        dartTestGroup,
        equals(
          DartGroupEntry(
            name: '',
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  _testEntry('alpha', tags: ['tag1']),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('filter excluded tags', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          _localTest('example_test alpha', metadata: Metadata(tags: ['tag1'])),
          _localTest(
            'example_test bravo first',
            metadata: Metadata(tags: ['tag2']),
          ),
          _localTest(
            'example_test bravo second',
            metadata: Metadata(tags: ['tag3']),
          ),
        ]),
      ]);

      // when
      final dartTestGroup = createDartTestGroup(
        topLevelGroup,
        excludeTags: 'tag1',
      );

      // then
      expect(
        dartTestGroup,
        equals(
          DartGroupEntry(
            name: '',
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  _testEntry('bravo first', tags: ['tag2']),
                  _testEntry('bravo second', tags: ['tag3']),
                ],
              ),
            ],
          ),
        ),
      );
    });

    test('filter included and excluded tags', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('example_test', [
          _localTest('example_test alpha', metadata: Metadata(tags: ['tag1'])),
          _localTest(
            'example_test bravo first',
            metadata: Metadata(tags: ['tag1', 'tag2']),
          ),
          _localTest(
            'example_test bravo second',
            metadata: Metadata(tags: ['tag3']),
          ),
        ]),
      ]);

      // when
      final dartTestGroup = createDartTestGroup(
        topLevelGroup,
        tags: 'tag1 || tag3',
        excludeTags: 'tag2',
      );

      // then
      expect(
        dartTestGroup,
        equals(
          DartGroupEntry(
            name: '',
            type: GroupEntryType.group,
            skip: false,
            tags: const [],
            entries: [
              DartGroupEntry(
                name: 'example_test',
                type: GroupEntryType.group,
                skip: false,
                tags: const [],
                entries: [
                  _testEntry('alpha', tags: ['tag1']),
                  _testEntry('bravo second', tags: ['tag3']),
                ],
              ),
            ],
          ),
        ),
      );
    });
  });

  group('namesWithPathSeparator()', () {
    test('accepts a hierarchy without a path separator', () {
      // given
      final group = _group('', [
        _group('example_test', [_testEntry('alpha'), _testEntry('bravo')]),
      ]);

      // when
      final invalid = namesWithPathSeparator(group);

      // then
      expect(invalid, isEmpty);
    });

    test('catches a slash in a test description, reporting the full name', () {
      // given
      final group = _group('', [
        _group('example_test', [
          _testEntry('alpha'),
          _testEntry('testing forward slash / breaking execution'),
        ]),
      ]);

      // when
      final invalid = namesWithPathSeparator(group);

      // then
      expect(
        invalid,
        equals(['example_test testing forward slash / breaking execution']),
      );
    });

    test('catches a slash in a group name, which every test inherits', () {
      // given
      final group = _group('', [
        _group('example_test', [
          _group('group with / slash', [
            _testEntry('first'),
            _testEntry('second'),
          ]),
          _testEntry('outside the group'),
        ]),
      ]);

      // when
      final invalid = namesWithPathSeparator(group);

      // then
      expect(
        invalid,
        equals([
          'example_test group with / slash first',
          'example_test group with / slash second',
        ]),
      );
    });

    test('catches every offending test, not just the first', () {
      // given
      final group = _group('', [
        _group('example_test', [
          _testEntry('a / b'),
          _testEntry('fine'),
          _testEntry('c / d'),
        ]),
      ]);

      // when
      final invalid = namesWithPathSeparator(group);

      // then
      expect(invalid, equals(['example_test a / b', 'example_test c / d']));
    });
  });
}

LocalTest _localTest(String name, {Metadata? metadata}) =>
    LocalTest(name, metadata ?? Metadata.empty, () {});

DartGroupEntry _testEntry(
  String name, {
  bool skip = false,
  List<String> tags = const [],
}) {
  return DartGroupEntry(
    name: name,
    type: GroupEntryType.test,
    entries: const [],
    skip: skip,
    tags: tags,
  );
}

DartGroupEntry _group(String name, List<DartGroupEntry> entries) =>
    DartGroupEntry(
      name: name,
      type: GroupEntryType.group,
      entries: entries,
      skip: false,
      tags: const [],
    );
