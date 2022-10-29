import 'package:adb/adb.dart';
import 'package:adb/src/internals.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAdbInternals extends Mock implements AdbInternals {}

void main() {
  group('devices()', () {
    late AdbInternals mockAdbInternals;
    late Adb adb;

    setUp(() {
      mockAdbInternals = MockAdbInternals();
      adb = Adb(adbInternals: mockAdbInternals);
    });

    test('returns correct result when no devices are attached', () async {
      const output = '''
List of devices attached

''';
      when(mockAdbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>[]);
    });

    test('returns correct result when 1 device are attached', () async {
      const output = '''
List of devices attached
emulator-5554	device


''';
      when(mockAdbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>['emulator-5554']);
    });

    test('returns correct result when  devices are attached', () async {
      const output = '''
List of devices attached
emulator-5554	device
emulator-5556	device
emulator-5557	device


''';
      when(mockAdbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>[
        'emulator-5554',
        'emulator-5556',
        'emulator-5557',
      ]);
    });
  });
}
