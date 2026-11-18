import 'package:patrol_cli/src/coverage/bs_build_check.dart';
import 'package:test/test.dart';

void main() {
  group('buildUsedClearPackageData', () {
    test('reads the string form BrowserStack echoes back', () {
      expect(
        buildUsedClearPackageData({
          'input_capabilities': <String, dynamic>{'clearPackageData': 'true'},
        }),
        isTrue,
      );
      expect(
        buildUsedClearPackageData({
          'input_capabilities': <String, dynamic>{'clearPackageData': 'false'},
        }),
        isFalse,
      );
    });

    test('reads a boolean', () {
      expect(
        buildUsedClearPackageData({
          'input_capabilities': <String, dynamic>{'clearPackageData': true},
        }),
        isTrue,
      );
    });

    test('returns null when the build does not echo it', () {
      expect(
        buildUsedClearPackageData({
          'input_capabilities': <String, dynamic>{'useOrchestrator': 'true'},
        }),
        isNull,
      );
      expect(buildUsedClearPackageData({'status': 'passed'}), isNull);
    });
  });
}
