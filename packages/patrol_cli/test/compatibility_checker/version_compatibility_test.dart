import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('Version compatibility', () {
    test('should parse all version string variations correctly', () {
      // Single version
      final singleVersion = VersionCompatibility.fromRangeString(
        patrolVersion: '2.0.0',
        patrolCliVersion: '3.0.0',
        minFlutterVersion: '3.3.0',
      );
      expect(singleVersion.patrolBottomRangeVersion, Version.parse('2.0.0'));
      expect(singleVersion.patrolTopRangeVersion, Version.parse('2.0.0'));
      expect(singleVersion.patrolCliBottomRangeVersion, Version.parse('3.0.0'));
      expect(singleVersion.patrolCliTopRangeVersion, Version.parse('3.0.0'));

      // Version range
      final versionRange = VersionCompatibility.fromRangeString(
        patrolVersion: '2.0.1 - 2.2.5',
        patrolCliVersion: '3.1.0 - 3.1.1',
        minFlutterVersion: '3.3.0',
      );
      expect(versionRange.patrolBottomRangeVersion, Version.parse('2.0.1'));
      expect(versionRange.patrolTopRangeVersion, Version.parse('2.2.5'));
      expect(versionRange.patrolCliBottomRangeVersion, Version.parse('3.1.0'));
      expect(versionRange.patrolCliTopRangeVersion, Version.parse('3.1.1'));

      // Open-ended range
      final openEndedRange = VersionCompatibility.fromRangeString(
        patrolVersion: '3.14.0+',
        patrolCliVersion: '3.5.0+',
        minFlutterVersion: '3.24.0',
      );
      expect(openEndedRange.patrolBottomRangeVersion, Version.parse('3.14.0'));
      expect(openEndedRange.patrolTopRangeVersion, isNull);
      expect(
        openEndedRange.patrolCliBottomRangeVersion,
        Version.parse('3.5.0'),
      );
      expect(openEndedRange.patrolCliTopRangeVersion, isNull);

      // Mixed formats
      final mixedFormats = VersionCompatibility.fromRangeString(
        patrolVersion: '3.6.0 - 3.10.0', // range
        patrolCliVersion: '3.0.1+', // open-ended
        minFlutterVersion: '3.16.0', // single
      );
      expect(mixedFormats.patrolBottomRangeVersion, Version.parse('3.6.0'));
      expect(mixedFormats.patrolTopRangeVersion, Version.parse('3.10.0'));
      expect(mixedFormats.patrolCliBottomRangeVersion, Version.parse('3.0.1'));
      expect(mixedFormats.patrolCliTopRangeVersion, isNull);
      expect(mixedFormats.minFlutterVersion, Version.parse('3.16.0'));
    });
    test('areVersionsCompatible returns true for compatible versions', () {
      final cliVersion = Version.parse('3.5.0');
      final patrolVersion = Version.parse('3.14.0');
      expect(areVersionsCompatible(cliVersion, patrolVersion), isTrue);
    });

    test('areVersionsCompatible returns false for incompatible versions', () {
      final cliVersion = Version.parse('3.5.0');
      final patrolVersion = Version.parse('2.0.0');
      expect(areVersionsCompatible(cliVersion, patrolVersion), isFalse);
    });

    test('getLatestCompatiblePatrolVersion returns correct version', () {
      final cliVersion = Version.parse('3.5.0');
      final latestCompatible = getLatestCompatiblePatrolVersion(cliVersion);
      expect(latestCompatible, isNotNull);
      expect(latestCompatible.toString(), equals('3.15.2'));
    });

    test('current patrol_cli version is listed in compatibility file', () {
      final currentCliVersion = Version.parse(constants.version);

      // Check if the current CLI version has an entry in the compatibility list
      final hasEntry = versionCompatibilityList.any((compat) {
        final cliMin = compat.patrolCliBottomRangeVersion;
        final cliMax = compat.patrolCliTopRangeVersion;
        return currentCliVersion >= cliMin &&
            (cliMax == null || currentCliVersion <= cliMax);
      });

      expect(
        hasEntry,
        isTrue,
        reason:
            'Current patrol_cli version $currentCliVersion is not listed in compatibility file',
      );
    });

    test('current patrol_cli is compatible with listed patrol versions', () {
      final currentCliVersion = Version.parse(constants.version);

      // Get all patrol versions that should be compatible with current CLI
      final compatiblePatrolVersions = versionCompatibilityList
          .where((compat) {
            final cliMin = compat.patrolCliBottomRangeVersion;
            final cliMax = compat.patrolCliTopRangeVersion;
            return currentCliVersion >= cliMin &&
                (cliMax == null || currentCliVersion <= cliMax);
          })
          .expand(
            (compat) => [
              compat.patrolBottomRangeVersion,
              if (compat.patrolTopRangeVersion != null)
                compat.patrolTopRangeVersion!,
            ],
          )
          .toList();

      expect(
        compatiblePatrolVersions,
        isNotEmpty,
        reason:
            'No compatible patrol versions found for current patrol_cli $currentCliVersion',
      );

      // Verify each version is actually compatible
      for (final patrolVersion in compatiblePatrolVersions) {
        expect(
          areVersionsCompatible(currentCliVersion, patrolVersion),
          isTrue,
          reason:
              'Current patrol_cli $currentCliVersion is not compatible with patrol $patrolVersion',
        );
      }
    });
  });
}
