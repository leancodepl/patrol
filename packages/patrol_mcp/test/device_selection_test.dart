import 'package:patrol_cli/patrol_cli.dart' show Device, TargetPlatform;
import 'package:patrol_mcp/src/device_selection.dart';
import 'package:test/test.dart';

Device _device(String id, TargetPlatform platform, {required bool emulator}) =>
    Device(name: id, id: id, targetPlatform: platform, real: !emulator);

void main() {
  final androidEmu = _device(
    'android-emu',
    TargetPlatform.android,
    emulator: true,
  );
  final androidReal = _device(
    'android-real',
    TargetPlatform.android,
    emulator: false,
  );
  final iosSim = _device('ios-sim', TargetPlatform.iOS, emulator: true);
  final iosReal = _device('ios-real', TargetPlatform.iOS, emulator: false);
  final web = _device('chrome', TargetPlatform.web, emulator: false);
  final macos = _device('macos', TargetPlatform.macOS, emulator: false);

  group('supportedDevices', () {
    test('keeps Android and iOS, drops web and macOS', () {
      final result = supportedDevices([androidEmu, iosSim, web, macos]);
      expect(result, [androidEmu, iosSim]);
    });

    test('empty in, empty out', () {
      expect(supportedDevices([]), isEmpty);
    });
  });

  group('autoSelectDevice', () {
    test('ranks Android device > Android emu > iOS device > iOS sim', () {
      // Shuffled input; expect the ranking order regardless.
      expect(
        autoSelectDevice([iosSim, iosReal, androidEmu, androidReal]),
        androidReal,
      );
      expect(autoSelectDevice([iosSim, iosReal, androidEmu]), androidEmu);
      expect(autoSelectDevice([iosSim, iosReal]), iosReal);
      expect(autoSelectDevice([iosSim]), iosSim);
    });

    test('picks the only attached device', () {
      expect(autoSelectDevice([iosSim]), iosSim);
    });

    test('never auto-selects web or macOS', () {
      expect(autoSelectDevice([web, macos]), isNull);
      // With a mobile device present, web/macOS are ignored.
      expect(autoSelectDevice([web, iosSim, macos]), iosSim);
    });

    test('returns null when nothing is attached', () {
      expect(autoSelectDevice([]), isNull);
    });
  });
}
