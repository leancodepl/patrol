import 'package:adb/adb.dart';
import 'package:test/test.dart';

void main() {
  group(
    'AdbForwardList',
    () {
      test('returns an empty map if adb forward --list output is empty', () {
        const output = '''

''';
        expect(AdbForwardList.parse(output), <String, Map<int, int>>{});
      });

      test('parses adb forward --list output correctly', () {
        const output = '''
emulator-5554 tcp:60000 tcp:60001
emulator-5554 tcp:61234 tcp:61235
emulator-5556 tcp:61341 tcp:62562

''';

        final result = AdbForwardList.parse(output);
        expect(
          result,
          {
            'emulator-5554': {
              60000: 60001,
              61234: 61235,
            },
            'emulator-5556': {
              61341: 62562,
            },
          },
        );
      });
    },
  );
}
