import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
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
      final hasEntry = versionCompatibilityList.any((compat) {
        final cliRange = _parseVersionRange(compat.patrolCliVersion);
        return cliRange.min.compareTo(currentCliVersion) <= 0 &&
            (cliRange.max == null ||
                cliRange.max!.compareTo(currentCliVersion) >= 0);
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
            final cliRange = _parseVersionRange(compat.patrolCliVersion);
            return cliRange.min.compareTo(currentCliVersion) <= 0 &&
                (cliRange.max == null ||
                    cliRange.max!.compareTo(currentCliVersion) >= 0);
          })
          .expand((compat) => _expandVersionRange(compat.patrolVersion))
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

VersionRange _parseVersionRange(String versionStr) {
  final min = _getMinVersion(versionStr);
  final max = _getMaxVersion(versionStr);
  return VersionRange(min: min, max: max);
}

Version _getMinVersion(String versionStr) {
  if (versionStr.endsWith('+')) {
    return Version.parse(versionStr.substring(0, versionStr.length - 1));
  }
  return Version.parse(versionStr.split(' - ')[0]);
}

Version? _getMaxVersion(String versionStr) {
  if (versionStr.endsWith('+')) {
    return null;
  }
  final parts = versionStr.split(' - ');
  return parts.length > 1 ? Version.parse(parts[1]) : Version.parse(parts[0]);
}

List<Version> _expandVersionRange(String versionStr) {
  final min = _getMinVersion(versionStr);
  final max = _getMaxVersion(versionStr);

  if (max == null) {
    return [min];
  }

  return [min, max];
}
