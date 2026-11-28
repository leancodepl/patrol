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
      expect(
        parsePatrolTargetPlatform('windows'),
        PatrolTargetPlatform.windows,
      );
    });

    test('rejects a name patrol_cli does not pass', () {
      for (final name in ['', 'linux']) {
        expect(
          () => parsePatrolTargetPlatform(name),
          throwsA(
            isA<StateError>().having(
              (e) => e.message,
              'message',
              contains('unknown target platform "$name"'),
            ),
          ),
        );
      }
    });
  });
}
