import 'package:patrol_cli/src/commands/develop_options.dart';
import 'package:test/test.dart';

void main() {
  group('DevelopOptions.parseArgs', () {
    test('parses --use-prebuilt-apks alongside develop and global flags', () {
      final (options, results) = DevelopOptions.parseArgs([
        '--use-prebuilt-apks=/tmp/apks',
        '--device',
        'emulator-5554',
        '--verbose',
      ], target: 'patrol_test/app_test.dart');

      expect(options.prebuiltApksDir, '/tmp/apks');
      expect(options.devices, ['emulator-5554']);
      expect(results['verbose'], isTrue);
    });

    test('prebuiltApksDir is null when the flag is absent', () {
      final (options, _) = DevelopOptions.parseArgs(
        const [],
        target: 'patrol_test/app_test.dart',
      );

      expect(options.prebuiltApksDir, isNull);
    });
  });
}
