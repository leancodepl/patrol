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

  group('exception parsing', () {
    test('INSTALL_FAILED_UPDATE_INCOMPATIBLE (1)', () {
      const output = '''
failed to install /Users/bartek/.maestro/server-0.4.1.apk: Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package pl.leancode.automatorserver signatures do not match newer version; ignoring!]
''';

      final exception = AdbInstallFailedUpdateIncompatible.fromStdErr(output);
      expect(exception.packageName, 'pl.leancode.automatorserver');
      expect(exception.message, output);
    });

    test('INSTALL_FAILED_UPDATE_INCOMPATIBLE (2)', () {
      const output = '''
failed to install /Users/bartek/.maestro/instrumentation.apk: Failure [INSTALL_FAILED_UPDATE_INCOMPATIBLE: Existing package pl.leancode.automatorserver.test signatures do not match newer version; ignoring!]
''';

      final exception = AdbInstallFailedUpdateIncompatible.fromStdErr(output);
      expect(exception.packageName, 'pl.leancode.automatorserver.test');
      expect(exception.message, output);
    });
  });
}
