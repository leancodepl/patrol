import 'package:patrol_cli/src/commands/develop_service.dart';
import 'package:test/test.dart';

void main() {
  group('supportsWebHotRestart', () {
    test('rejects stable releases below 3.47.0', () {
      expect(supportsWebHotRestart('3.32.0'), isFalse);
      expect(supportsWebHotRestart('3.38.5'), isFalse);
      expect(supportsWebHotRestart('3.46.9'), isFalse);
    });

    test('rejects prereleases of the release before 3.47.0', () {
      expect(supportsWebHotRestart('3.46.0-1.2.pre'), isFalse);
    });

    test('accepts 3.47.0 and newer stable releases', () {
      expect(supportsWebHotRestart('3.47.0'), isTrue);
      expect(supportsWebHotRestart('3.48.1'), isTrue);
      expect(supportsWebHotRestart('4.0.0'), isTrue);
    });

    test('accepts 3.47 prereleases, which already carry the fix', () {
      expect(supportsWebHotRestart('3.47.0-0.1.pre'), isTrue);
      expect(supportsWebHotRestart('3.47.0-1.2.pre'), isTrue);
    });

    test('accepts a version it cannot parse', () {
      expect(supportsWebHotRestart('unknown'), isTrue);
      expect(supportsWebHotRestart(''), isTrue);
    });
  });
}
