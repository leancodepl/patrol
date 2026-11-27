import 'dart:io';

import 'package:test/test.dart';

/// `lib/patrol_cli.dart` is public API, so this pins the URIs it exports and the
/// names they show. Update the list only by adding to it.
void main() {
  test('the public barrel keeps exporting what it exported', () {
    const expected = <String, Set<String>?>{
      'package:patrol_log/patrol_log.dart': {
        'ConfigEntry',
        'Entry',
        'ErrorEntry',
        'TestEntry',
        'TestEntryStatus',
      },
      'src/commands/develop_options.dart': null,
      'src/commands/develop_service.dart': null,
      'src/commands/develop_session_factory.dart': null,
      'src/devices.dart': {'Device', 'DeviceFinder', 'TargetPlatform'},
      'src/ios/ios_test_backend.dart': {'BuildMode'},
      'src/runner/flutter_command.dart': {'FlutterCommand'},
    };

    final source = File('lib/patrol_cli.dart').readAsStringSync();
    final exports = <String, Set<String>?>{
      for (final match in RegExp(
        r"^export '([^']+)'(?:\s+show\s+([^;]+))?;",
        multiLine: true,
      ).allMatches(source))
        match.group(1)!: match
            .group(2)
            ?.split(',')
            .map((name) => name.trim())
            .toSet(),
    };

    for (final MapEntry(key: uri, value: names) in expected.entries) {
      expect(exports, contains(uri), reason: 'no longer exported: $uri');
      final shown = exports[uri];
      if (names != null && shown != null) {
        expect(shown, containsAll(names), reason: 'narrowed: $uri');
      } else if (names == null) {
        expect(shown, isNull, reason: 'narrowed to a show list: $uri');
      }
    }
  });
}
