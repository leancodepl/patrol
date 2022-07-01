import 'package:adb/adb.dart';
import 'package:adb/src/internals.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAdbInternals extends Mock implements AdbInternals {}

void main() {
  group('adb devices', () {
    late MockAdbInternals mockAdbInternals;
    late Adb adb;

    setUp(() {
      mockAdbInternals = MockAdbInternals();
      adb = Adb(adbInternals: mockAdbInternals);
    });

    test('First Test', () {
      expect(2 + 2, 4);
    });

    test('empty list when no devices attaced', () async {
      const output = '''
List of devices attached

''';
      when(mockAdbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>[]);
    });

    test('1 device attached', () async {
      const output = '''
List of devices attached
emulator-5554	device


''';
      when(mockAdbInternals.devices).thenAnswer((_) async => output);

      final devices = await adb.devices();
      expect(devices, <String>['emulator-5554']);
    });

    test('3 device attached', () async {
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
