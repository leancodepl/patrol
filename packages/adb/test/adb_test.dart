import 'package:adb/adb.dart';
import 'package:adb/src/internals.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAdbInternals extends Mock implements AdbInternals {}

void main() {
  group('devices()', () {
    late AdbInternals adbInternals;
    late Adb adb;

    setUp(() {
      adbInternals = MockAdbInternals();
      when(() => adbInternals.ensureServerRunning()).thenAnswer((_) async {});

      adb = Adb(adbInternals: adbInternals);
    });

    test('returns correct result when no devices are attached', () async {
      const output = '''
List of devices attached

''';
      when(adbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>[]);
    });

    test('returns correct result when 1 device is attached', () async {
      const output = '''
List of devices attached
emulator-5554	device


''';
      when(adbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>['emulator-5554']);
    });

    test('returns correct result when devices are attached', () async {
      const output = '''
List of devices attached
emulator-5554	device
emulator-5556	device
emulator-5557	device


''';
      when(adbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>[
        'emulator-5554',
        'emulator-5556',
        'emulator-5557',
      ]);
    });
  });
}
