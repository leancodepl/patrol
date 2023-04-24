// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, implementation_imports
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/common.dart' show createDartTestGroup;
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/metadata.dart';

void main() {
  group('createDartTestGroup()', () {
    test('fails if a test is defined', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        LocalTest('some_test', Metadata.empty, () => null),
        Group('example_test', [
          LocalTest('example_test some example test', Metadata.empty, () {}),
        ])
      ]);

      // when
      DartTestGroup callback() => createDartTestGroup(topLevelGroup);

      // then
      expect(
        callback,
        throwsA(isA<StateError>()),
      );
    });
    test('takes only groups into account', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group(
          'permissions.permissions_location_test',
          [
            LocalTest(
              'permissions.permissions_location_test accepts location permission',
              Metadata.empty,
              () {},
            )
          ],
        ),
        Group('permissions.permissions_many_test', [
          LocalTest(
            'permissions.permissions_many_test grants various permissions',
            Metadata.empty,
            () {},
          ),
        ]),
        Group('example_test', [
          LocalTest('example_test some example test', Metadata.empty, () {}),
        ])
      ]);

      // when
      final dartTestGroup = createDartTestGroup(topLevelGroup);

      // then
      expect(
        dartTestGroup,
        DartTestGroup(
          name: '',
          groups: [
            DartTestGroup(name: 'permissions.permissions_location_test'),
            DartTestGroup(name: 'permissions.permissions_many_test'),
            DartTestGroup(name: 'example_test'),
          ],
        ),
      );
    });
  });
}
