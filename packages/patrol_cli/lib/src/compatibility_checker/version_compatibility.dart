import 'package:version/version.dart';
import 'package:patrol_cli/src/compatibility_checker/version_comparator.dart'
    as vc;

/// Represents a mapping between patrol and patrol_cli compatible versions
class VersionCompatibility {
  const VersionCompatibility({
    required this.patrolVersion,
    required this.patrolCliVersion,
    required this.minFlutterVersion,
  });

  final String patrolVersion;
  final String patrolCliVersion;
  final String minFlutterVersion;

  /// Creates a VersionComparator for this compatibility entry
  vc.VersionComparator _createComparator() {
    return vc.VersionComparator(
      cliVersionRange: _parseVersionRange(patrolCliVersion),
      packageVersionRange: _parseVersionRange(patrolVersion),
    );
  }

  /// Checks if the given versions are compatible with this entry
  bool isCompatible(Version cliVersion, Version patrolVersion) {
    final cliRanges = _parseVersionRange(patrolCliVersion);
    final patrolRanges = _parseVersionRange(this.patrolVersion);

    // Check if CLI version matches any of its ranges
    bool cliMatches = false;
    for (final range in cliRanges) {
      if (range.min <= cliVersion &&
          (range.max == null || cliVersion <= range.max)) {
        cliMatches = true;
        break;
      }
    }

    if (!cliMatches) return false;

    // Check if patrol version matches any of its ranges
    for (final range in patrolRanges) {
      if (range.min <= patrolVersion &&
          (range.max == null || patrolVersion <= range.max)) {
        return true;
      }
    }

    return false;
  }

  /// Gets the highest patrol version that is compatible with this entry
  Version? getHighestCompatiblePatrolVersion(Version cliVersion) {
    // Check if CLI version is in the compatible range
    final cliRanges = _parseVersionRange(patrolCliVersion);
    bool isCliCompatible = false;
    for (final range in cliRanges) {
      if (range.min <= cliVersion &&
          (range.max == null || cliVersion <= range.max)) {
        isCliCompatible = true;
        break;
      }
    }

    if (!isCliCompatible) {
      return null;
    }

    final ranges = _parseVersionRange(patrolVersion);
    Version? highest;
    for (final range in ranges) {
      final maxVersion = range.max ?? range.min;
      if (highest == null || maxVersion > highest) {
        highest = maxVersion;
      }
    }
    return highest;
  }

  /// Gets the maximum version from a version range string
  static Version _getMaxVersion(String versionStr) {
    if (versionStr.endsWith('+')) {
      // For open-ended ranges, use a very high version number
      return Version(99, 99, 99);
    }
    final parts = versionStr.split(' - ');
    return parts.length > 1 ? Version.parse(parts[1]) : Version.parse(parts[0]);
  }

  /// Parses a version range string into a list of [vc.VersionRange] objects
  static List<vc.VersionRange> _parseVersionRange(String rangeStr) {
    if (rangeStr.endsWith('+')) {
      final minVersion =
          Version.parse(rangeStr.substring(0, rangeStr.length - 1));
      return [vc.VersionRange(min: minVersion)];
    }

    final parts = rangeStr.split(' - ');
    if (parts.length == 1) {
      final version = Version.parse(parts[0]);
      return [vc.VersionRange(min: version, max: version)];
    }

    return [
      vc.VersionRange(
        min: Version.parse(parts[0]),
        max: Version.parse(parts[1]),
      ),
    ];
  }
}

/// List of compatible version combinations between patrol_cli and patrol
/// This is the single source of truth for version compatibility
final List<VersionCompatibility> versionCompatibilityList = [
  const VersionCompatibility(
    patrolCliVersion: '3.5.0+',
    patrolVersion: '3.14.0+',
    minFlutterVersion: '3.24.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '3.4.1',
    patrolVersion: '3.13.1 - 3.13.2',
    minFlutterVersion: '3.24.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '3.4.0',
    patrolVersion: '3.13.0',
    minFlutterVersion: '3.24.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '3.3.0',
    patrolVersion: '3.12.0',
    minFlutterVersion: '3.24.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '3.2.1',
    patrolVersion: '3.11.2',
    minFlutterVersion: '3.24.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '3.2.0',
    patrolVersion: '3.11.0 - 3.11.1',
    minFlutterVersion: '3.22.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '3.1.0 - 3.1.1',
    patrolVersion: '3.10.0',
    minFlutterVersion: '3.22.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '2.6.5 - 3.0.1',
    patrolVersion: '3.6.0 - 3.10.0',
    minFlutterVersion: '3.16.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '2.6.0 - 2.6.4',
    patrolVersion: '3.4.0 - 3.5.2',
    minFlutterVersion: '3.16.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '2.3.0 - 2.5.0',
    patrolVersion: '3.0.0 - 3.3.0',
    minFlutterVersion: '3.16.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '2.2.0 - 2.2.2',
    patrolVersion: '2.3.0 - 2.3.2',
    minFlutterVersion: '3.3.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '2.0.1 - 2.1.5',
    patrolVersion: '2.0.1 - 2.2.5',
    minFlutterVersion: '3.3.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '2.0.0',
    patrolVersion: '2.0.0',
    minFlutterVersion: '3.3.0',
  ),
  const VersionCompatibility(
    patrolCliVersion: '1.1.4 - 1.1.11',
    patrolVersion: '1.0.9 - 1.1.11',
    minFlutterVersion: '3.3.0',
  ),
]..sort((a, b) {
    final aVersion = VersionCompatibility._getMaxVersion(a.patrolVersion);
    final bVersion = VersionCompatibility._getMaxVersion(b.patrolVersion);
    return bVersion
        .compareTo(aVersion); // Sort in descending order by max version
  });

/// Helper function to check if versions are compatible
bool areVersionsCompatible(Version cliVersion, Version patrolVersion) {
  for (final compatibility in versionCompatibilityList) {
    if (compatibility.isCompatible(cliVersion, patrolVersion)) {
      return true;
    }
  }
  return false;
}

/// Helper function to get the latest compatible patrol version for a given CLI version
Version? getLatestCompatiblePatrolVersion(Version cliVersion) {
  Version? latest;
  for (final compatibility in versionCompatibilityList) {
    final maxVersion =
        compatibility.getHighestCompatiblePatrolVersion(cliVersion);
    if (maxVersion != null && (latest == null || maxVersion > latest)) {
      latest = maxVersion;
    }
  }
  return latest;
}
