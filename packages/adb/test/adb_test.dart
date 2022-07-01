import 'package:adb/adb.dart' as adb_pkg;
import 'package:adb/src/process.dart' as process;
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockAdb extends Mock implements process.Adb {}

void main() {
  group('adb devices', () {
    late process.Adb adb;

    setUp(() {
      adb = MockAdb();
    });

    test('First Test', () {
      expect(2 + 2, 4);
    });

    test('empty list when no devices attaced', () async {
      const output = '''
List of devices attached

''';
      when(adb.devices).thenAnswer((_) async => output);

      final devices = await adb_pkg.devices();
      expect(devices, <String>[]);
    });

    test('1 device attached', () async {
      const output = '''
List of devices attached
emulator-5554	device


''';
      when(adb.devices).thenAnswer((_) async => output);

      final devices = await adb_pkg.devices();
      expect(devices, <String>['emulator-5554']);
    });
  });
}
