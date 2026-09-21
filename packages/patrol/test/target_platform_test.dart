import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/src/platform/target_platform.dart';

void main() {
  group('parsePatrolTargetPlatform()', () {
    test('maps the names patrol_cli passes', () {
      expect(
        parsePatrolTargetPlatform('android'),
        PatrolTargetPlatform.android,
      );
      expect(parsePatrolTargetPlatform('ios'), PatrolTargetPlatform.iOS);
      expect(parsePatrolTargetPlatform('macos'), PatrolTargetPlatform.macOS);
      expect(parsePatrolTargetPlatform('web'), PatrolTargetPlatform.web);
    });

    test('explains an old patrol_cli that reports no platform', () {
      expect(
        () => parsePatrolTargetPlatform(''),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Update patrol_cli'),
          ),
        ),
      );
    });
  });
}
