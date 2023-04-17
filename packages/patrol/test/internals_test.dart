// ignore_for_file: invalid_use_of_internal_member, depend_on_referenced_packages, implementation_imports
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/common.dart' show createDartTestGroup;
import 'package:patrol/src/native/contracts/contracts.pbgrpc.dart';
import 'package:test_api/src/backend/group.dart';
import 'package:test_api/src/backend/invoker.dart';
import 'package:test_api/src/backend/metadata.dart';

void main() {
  group('createDartTestGroup()', () {
    test('smoke test 1', () {
      // given
      final topLevelGroup = Group.root([
        LocalTest('patrol_test_explorer', Metadata.empty, () {}),
        Group('permissions', [
          Group(
            'permissions permissions_location_test',
            [
              LocalTest(
                'permissions permissions_location_test accepts location permission',
                Metadata.empty,
                () {},
              )
            ],
          ),
          Group('permissions permissions_many_test', [
            LocalTest(
              'permissions permissions_many_test grants various permissions',
              Metadata.empty,
              () {},
            ),
          ]),
        ]),
        Group('sign_in', [
          Group('sign_in sign_in_email_test', [
            LocalTest(
              'sign_in sign_in_email_test signs in with email',
              Metadata.empty,
              () {},
            ),
          ]),
          Group('sign_in sign_in_facebook_test', [
            LocalTest(
              'sign_in sign_in_facebook_test signs in with Facebook',
              Metadata.empty,
              () {},
            ),
          ]),
          Group('sign_in sign_in_google_test', [
            LocalTest(
              'sign_in sign_in_google_test signs in with Google',
              Metadata.empty,
              () {},
            ),
          ]),
        ]),
        Group('example_test', [
          LocalTest(
            'example_test counter state is the same after going to Home and switching apps',
            Metadata.empty,
            () {},
          ),
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
            DartTestGroup(
              name: 'permissions',
              groups: [
                DartTestGroup(
                  name: 'permissions_location_test',
                  tests: [
                    DartTestCase(name: 'accepts location permission'),
                  ],
                ),
                DartTestGroup(
                  name: 'permissions_many_test',
                  tests: [
                    DartTestCase(name: 'grants various permissions'),
                  ],
                ),
              ],
            ),
            DartTestGroup(
              name: 'sign_in',
              groups: [
                DartTestGroup(
                  name: 'sign_in_email_test',
                  tests: [
                    DartTestCase(name: 'signs in with email'),
                  ],
                ),
                DartTestGroup(
                  name: 'sign_in_facebook_test',
                  tests: [
                    DartTestCase(name: 'signs in with Facebook'),
                  ],
                ),
                DartTestGroup(
                  name: 'sign_in_google_test',
                  tests: [
                    DartTestCase(name: 'signs in with Google'),
                  ],
                ),
              ],
            ),
            DartTestGroup(
              name: 'example_test',
              tests: [
                DartTestCase(
                  name:
                      'counter state is the same after going to Home and switching apps',
                ),
              ],
            ),
          ],
        ),
      );
    });
  });
}
