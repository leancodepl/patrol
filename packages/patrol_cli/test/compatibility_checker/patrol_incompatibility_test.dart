import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/compatibility_checker/compatibility_checker.dart';
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('patrolIncompatibility', () {
    final cliVersion = Version.parse(constants.version);

    /// A representative `patrol` version that this CLI can (or cannot) drive,
    /// decided by the same table the function under test consults — so the test
    /// keeps meaning what it says after a compatibility entry changes.
    String versionThatIs({required bool compatible}) =>
        const [
          '4.9.0',
          '4.8.0',
          '4.7.0',
          '4.6.1',
          '4.6.0',
          '4.5.0',
          '4.4.0',
          '4.2.0',
        ].firstWhere(
          (v) =>
              areVersionsCompatible(cliVersion, Version.parse(v)) == compatible,
          orElse: () => throw StateError(
            'No sample patrol version is '
            '${compatible ? "compatible" : "incompatible"} with CLI $cliVersion',
          ),
        );

    test('says nothing about a version this CLI can drive', () {
      expect(patrolIncompatibility(versionThatIs(compatible: true)), isNull);
    });

    test('names both versions and how to get out of it', () {
      final patrol = versionThatIs(compatible: false);

      final message = patrolIncompatibility(patrol);

      expect(message, isNotNull);
      expect(message, contains(patrol));
      expect(message, contains(constants.version));
      expect(message, contains('compatibility-table'));
    });

    test('offers the newest CLI that would work, when there is one', () {
      final patrol = versionThatIs(compatible: false);
      final maxCli = getMaxCompatibleCliVersion(Version.parse(patrol));

      final message = patrolIncompatibility(patrol);

      if (maxCli != null) {
        expect(message, contains('$maxCli'));
      }
    });

    test('stays quiet when the version is unknown or unparseable', () {
      // A project without a resolved pubspec.lock, and a value that is not a
      // version: neither is a reason to warn about compatibility.
      expect(patrolIncompatibility(null), isNull);
      expect(patrolIncompatibility('not-a-version'), isNull);
      expect(patrolIncompatibility(''), isNull);
    });
  });
}
