import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Keys intentionally left out of a locale, see IOS_OMITTED_KEYS in
// tool/native_localization/generate.py.
const _iosOmittedKeys = {
  'lt': {'precise_off'},
};

final _iosResources = Directory('darwin/patrol/Sources/PatrolImpl/Resources');
final _androidResources = Directory('android/src/main/res');

Set<String> _iosKeys(File file) => RegExp(
  r'^"(\w+)" = ',
  multiLine: true,
).allMatches(file.readAsStringSync()).map((match) => match.group(1)!).toSet();

Set<String> _androidKeys(File file) => RegExp(
  r'<string name="(\w+)"',
).allMatches(file.readAsStringSync()).map((match) => match.group(1)!).toSet();

String _name(FileSystemEntity entity) =>
    entity.uri.pathSegments.lastWhere((segment) => segment.isNotEmpty);

void main() {
  group('native localization resources', () {
    test('every iOS locale has all keys of en.lproj', () {
      final english = _iosKeys(
        File('${_iosResources.path}/en.lproj/Localizable.strings'),
      );
      final locales = _iosResources.listSync().whereType<Directory>().where(
        (dir) => dir.path.endsWith('.lproj'),
      );
      expect(locales.length, greaterThan(1));

      for (final locale in locales) {
        final name = _name(locale).replaceAll('.lproj', '');
        final keys = _iosKeys(File('${locale.path}/Localizable.strings'));
        expect(
          english.difference(keys),
          _iosOmittedKeys[name] ?? isEmpty,
          reason: '$name.lproj is missing keys',
        );
        expect(
          keys.difference(english),
          isEmpty,
          reason: '$name.lproj has keys that en.lproj does not have',
        );
      }
    });

    test('every Android locale has all keys of values/', () {
      final english = _androidKeys(
        File('${_androidResources.path}/values/strings.xml'),
      );
      final locales = _androidResources.listSync().whereType<Directory>().where(
        (dir) => _name(dir).startsWith('values-'),
      );
      expect(locales.length, greaterThan(1));

      for (final locale in locales) {
        final keys = _androidKeys(File('${locale.path}/strings.xml'));
        expect(keys, english, reason: '${_name(locale)} has different keys');
      }
    });
  });
}
