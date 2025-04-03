import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('VersionCompatibility', () {
    test('should parse version ranges correctly', () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0 - 2.0.0',
        patrolCliVersion: '3.0.0 - 4.0.0',
        minFlutterVersion: '3.0.0',
      );

      expect(compat.patrolBottomRangeVersion, Version.parse('1.0.0'));
      expect(compat.patrolTopRangeVersion, Version.parse('2.0.0'));
      expect(compat.patrolCliBottomRangeVersion, Version.parse('3.0.0'));
      expect(compat.patrolCliTopRangeVersion, Version.parse('4.0.0'));
      expect(compat.minFlutterVersion, Version.parse('3.0.0'));
    });

    test('should handle open-ended ranges', () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0+',
        patrolCliVersion: '3.0.0+',
        minFlutterVersion: '3.0.0',
      );

      expect(compat.patrolBottomRangeVersion, Version.parse('1.0.0'));
      expect(compat.patrolTopRangeVersion, isNull);
      expect(compat.patrolCliBottomRangeVersion, Version.parse('3.0.0'));
      expect(compat.patrolCliTopRangeVersion, isNull);
      expect(compat.minFlutterVersion, Version.parse('3.0.0'));
    });

    test('should check compatibility correctly', () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0 - 2.0.0',
        patrolCliVersion: '3.0.0 - 4.0.0',
        minFlutterVersion: '3.0.0',
      );

      // Test within range
      expect(
        compat.isCompatible(
          Version.parse('3.5.0'),
          Version.parse('1.5.0'),
        ),
        isTrue,
      );

      // Test below range
      expect(
        compat.isCompatible(
          Version.parse('2.0.0'),
          Version.parse('0.5.0'),
        ),
        isFalse,
      );

      // Test above range
      expect(
        compat.isCompatible(
          Version.parse('5.0.0'),
          Version.parse('2.5.0'),
        ),
        isFalse,
      );
    });

    test('should get highest compatible patrol version correctly', () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0 - 2.0.0',
        patrolCliVersion: '3.0.0 - 4.0.0',
        minFlutterVersion: '3.0.0',
      );

      // Test within range
      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('3.5.0')),
        Version.parse('2.0.0'),
      );

      // Test below range
      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('2.0.0')),
        isNull,
      );

      // Test above range
      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('5.0.0')),
        isNull,
      );
    });
  });

  group('Version compatibility', () {
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
      expect(latestCompatible.toString(), equals('3.14.0'));
    });

    test('current patrol_cli version is listed in compatibility file', () {
      final currentCliVersion = Version.parse(constants.version);

      // Check if the current CLI version has an entry in the compatibility list
      final hasEntry = versionCompatibilityList.any((compat) =>
          currentCliVersion >= compat.patrolCliBottomRangeVersion &&
          (compat.patrolCliTopRangeVersion == null ||
              currentCliVersion <= compat.patrolCliTopRangeVersion!));

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
          .where((compat) =>
              currentCliVersion >= compat.patrolCliBottomRangeVersion &&
              (compat.patrolCliTopRangeVersion == null ||
                  currentCliVersion <= compat.patrolCliTopRangeVersion!))
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

class VersionRange {
  VersionRange({
    required this.min,
    this.max,
  });

  final Version min;
  final Version? max;
}
