import 'package:patrol_cli/patrol_cli.dart';
import 'package:patrol_mcp/src/patrol_session.dart';
import 'package:test/test.dart';

void main() {
  group('buildFlagParts', () {
    test('empty additionalFlags, null device', () {
      expect(
        buildFlagParts(additionalFlags: ''),
        ['--no-check-compatibility'],
      );
    });

    test('additionalFlags only, null device', () {
      expect(
        buildFlagParts(additionalFlags: '--flavor dev'),
        ['--flavor', 'dev', '--no-check-compatibility'],
      );
    });

    test('empty additionalFlags with explicit device', () {
      expect(
        buildFlagParts(additionalFlags: '', device: 'chrome'),
        ['--no-check-compatibility', '--device', 'chrome'],
      );
    });

    test('empty-string device is treated as null', () {
      expect(
        buildFlagParts(additionalFlags: '', device: ''),
        ['--no-check-compatibility'],
      );
    });

    test('whitespace-only device is treated as null', () {
      expect(
        buildFlagParts(additionalFlags: '', device: '   '),
        ['--no-check-compatibility'],
      );
    });

    test('device value with spaces is preserved as a single entry', () {
      final result = buildFlagParts(
        additionalFlags: '',
        device: 'iPhone 15 Pro',
      );
      expect(result, [
        '--no-check-compatibility',
        '--device',
        'iPhone 15 Pro',
      ]);
    });

    test('per-call device overrides --device from additionalFlags', () {
      final overrides = <List<String>>[];
      final result = buildFlagParts(
        additionalFlags: '-d foo --flavor dev',
        device: 'chrome',
        onDeviceOverride: overrides.add,
      );
      expect(result, [
        '--flavor',
        'dev',
        '--no-check-compatibility',
        '--device',
        'chrome',
      ]);
      expect(overrides, [
        ['foo'],
      ]);
    });

    test('removes --device=value form from additionalFlags', () {
      final result = buildFlagParts(
        additionalFlags: '--device=foo --verbose',
        device: 'bar',
      );
      expect(result, [
        '--verbose',
        '--no-check-compatibility',
        '--device',
        'bar',
      ]);
    });

    test('produced flagParts parse into DevelopOptions.devices', () {
      final parts = buildFlagParts(additionalFlags: '', device: 'chrome');
      final (options, _) = DevelopOptions.parseArgs(
        parts,
        target: 'integration_test/foo.dart',
      );
      expect(options.devices, contains('chrome'));
    });
  });
}
