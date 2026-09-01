import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:patrol/src/common.dart';

void main() {
  test('safe registration name does not contain a forward slash', () {
    const description = 'Testing forward slash / breaking execution';

    expect(
      patrolTestDescriptionContainsInvalidCharacters(description),
      isTrue,
    );
    expect(
      patrolTestSafeRegistrationName(description),
      isNot(contains('/')),
    );
    expect(
      patrolTestInvalidDescriptionFailureMessage(description),
      contains('cannot contain "/"'),
    );
  });

  test('patrolTest registers without throwing when description contains slash', () {
    expect(
      () => patrolTest('Testing forward slash / breaking execution', (_) async {}),
      returnsNormally,
    );
  });
}
