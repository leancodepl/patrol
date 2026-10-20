import 'dart:io';

import 'package:test/test.dart';

/// `lib/patrol_cli.dart` is consumed by published `patrol_mcp` 0.2.x and
/// 0.3.0-dev, which accept any `patrol_cli` in their range and import the
/// barrel whole — so a user's next `pub get` picks up whatever this package
/// exports today. Removing or renaming an entry breaks that package from our
/// side, with nothing in this repo failing.
///
/// The check is the exported URIs and the names they show: what those symbols
/// look like inside — a renamed parameter, a dropped field — needs that package
/// built against this one.
///
/// Update the list only by adding to it, or once `patrol_mcp` is retired.
void main() {
  test('the public barrel keeps exporting what patrol_mcp imports', () {
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
