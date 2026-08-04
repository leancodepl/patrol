import 'package:patrol_cli/patrol_cli.dart' show TargetPlatform;
import 'package:patrol_mcp/src/device_lister.dart';
import 'package:test/test.dart';

void main() {
  group('parseFlutterDevices', () {
    test('maps platforms and the emulator flag, skips unsupported', () {
      const json = '''
[
  {"name":"sdk gphone64 arm64","id":"emulator-5554","targetPlatform":"android-arm64","emulator":true},
  {"name":"Pixel 7","id":"PX7","targetPlatform":"android-arm64","emulator":false},
  {"name":"iPhone 17 Pro","id":"ABC-123","targetPlatform":"ios","emulator":true},
  {"name":"macOS","id":"macos","targetPlatform":"darwin","emulator":false},
  {"name":"Chrome","id":"chrome","targetPlatform":"web-javascript","emulator":false},
  {"name":"Fuchsia","id":"fx","targetPlatform":"fuchsia-x64","emulator":false}
]''';

      final devices = parseFlutterDevices(json);

      // Fuchsia is dropped; the other five are kept.
      expect(devices.map((d) => d.id), [
        'emulator-5554',
        'PX7',
        'ABC-123',
        'macos',
        'chrome',
      ]);

      final android = devices.firstWhere((d) => d.id == 'emulator-5554');
      expect(android.name, 'sdk gphone64 arm64');
      expect(android.targetPlatform, TargetPlatform.android);
      expect(android.real, isFalse); // emulator -> not real

      expect(
        devices.firstWhere((d) => d.id == 'PX7').real,
        isTrue, // physical device
      );
      expect(
        devices.firstWhere((d) => d.id == 'ABC-123').targetPlatform,
        TargetPlatform.iOS,
      );
      expect(
        devices.firstWhere((d) => d.id == 'macos').targetPlatform,
        TargetPlatform.macOS,
      );
      expect(
        devices.firstWhere((d) => d.id == 'chrome').targetPlatform,
        TargetPlatform.web,
      );
    });

    test('empty list in, empty list out', () {
      expect(parseFlutterDevices('[]'), isEmpty);
    });
  });
}
