import 'package:version/version.dart';

/// Represents a mapping between patrol and patrol_cli compatible versions
class VersionCompatibility {
  const VersionCompatibility({
    required this.patrolBottomRangeVersion,
    this.patrolTopRangeVersion,
    required this.patrolCliBottomRangeVersion,
    this.patrolCliTopRangeVersion,
    required this.minFlutterVersion,
  });

  /// Creates a VersionCompatibility from a version range string format
  factory VersionCompatibility.fromRangeString({
    required String patrolVersion,
    required String patrolCliVersion,
    required String minFlutterVersion,
  }) {
    Version parseBottom(String version) {
      if (version.endsWith('+')) {
        return Version.parse(version.substring(0, version.length - 1));
      }
      return Version.parse(version.split(' - ')[0]);
    }

    Version? parseTop(String version) {
      if (version.endsWith('+')) {
        return null;
      }
      return Version.parse(version.split(' - ').last);
    }

    return VersionCompatibility(
      patrolBottomRangeVersion: parseBottom(patrolVersion),
      patrolTopRangeVersion: parseTop(patrolVersion),
      patrolCliBottomRangeVersion: parseBottom(patrolCliVersion),
      patrolCliTopRangeVersion: parseTop(patrolCliVersion),
      minFlutterVersion: Version.parse(minFlutterVersion),
    );
  }

  /// The minimum version of patrol that is compatible
  final Version patrolBottomRangeVersion;

  /// The maximum version of patrol that is compatible (null means no upper bound)
  final Version? patrolTopRangeVersion;

  /// The minimum version of patrol_cli that is compatible
  final Version patrolCliBottomRangeVersion;

  /// The maximum version of patrol_cli that is compatible (null means no upper bound)
  final Version? patrolCliTopRangeVersion;

  /// The minimum Flutter version required
  final Version minFlutterVersion;

  /// Checks if the given versions are compatible with this entry
  bool isCompatible(Version cliVersion, Version patrolVersion) {
    // Check if CLI version is in range
    if (cliVersion < patrolCliBottomRangeVersion ||
        (patrolCliTopRangeVersion != null &&
            cliVersion > patrolCliTopRangeVersion)) {
      return false;
    }

    // Check if patrol version is in range
    return patrolVersion >= patrolBottomRangeVersion &&
        (patrolTopRangeVersion == null ||
            patrolVersion <= patrolTopRangeVersion);
  }

  /// Gets the highest patrol version that is compatible with this entry
  Version? getHighestCompatiblePatrolVersion(Version cliVersion) {
    // Check if CLI version is in range
    if (cliVersion < patrolCliBottomRangeVersion ||
        (patrolCliTopRangeVersion != null &&
            cliVersion > patrolCliTopRangeVersion)) {
      return null;
    }

    // Return the highest compatible patrol version
    return patrolTopRangeVersion ?? patrolBottomRangeVersion;
  }
}

/// List of compatible version combinations between
/// patrol_cli, patrol, and min Flutter version
/// This is the single source of truth for version compatibility
final List<VersionCompatibility> versionCompatibilityList = [
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.6.0-dev.1+',
    patrolVersion: '3.16.0-dev.1+',
    minFlutterVersion: '3.24.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.5.0 - 3.5.1',
    patrolVersion: '3.14.0 - 3.15.1',
    minFlutterVersion: '3.24.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.4.1',
    patrolVersion: '3.13.1 - 3.13.2',
    minFlutterVersion: '3.24.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.4.0',
    patrolVersion: '3.13.0',
    minFlutterVersion: '3.24.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.3.0',
    patrolVersion: '3.12.0',
    minFlutterVersion: '3.24.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.2.1',
    patrolVersion: '3.11.2',
    minFlutterVersion: '3.24.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.2.0',
    patrolVersion: '3.11.0 - 3.11.1',
    minFlutterVersion: '3.22.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '3.1.0 - 3.1.1',
    patrolVersion: '3.10.0',
    minFlutterVersion: '3.22.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '2.6.5 - 3.0.1',
    patrolVersion: '3.6.0 - 3.10.0',
    minFlutterVersion: '3.16.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '2.6.0 - 2.6.4',
    patrolVersion: '3.4.0 - 3.5.2',
    minFlutterVersion: '3.16.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '2.3.0 - 2.5.0',
    patrolVersion: '3.0.0 - 3.3.0',
    minFlutterVersion: '3.16.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '2.2.0 - 2.2.2',
    patrolVersion: '2.3.0 - 2.3.2',
    minFlutterVersion: '3.3.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '2.0.1 - 2.1.5',
    patrolVersion: '2.0.1 - 2.2.5',
    minFlutterVersion: '3.3.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '2.0.0',
    patrolVersion: '2.0.0',
    minFlutterVersion: '3.3.0',
  ),
  VersionCompatibility.fromRangeString(
    patrolCliVersion: '1.1.4 - 1.1.11',
    patrolVersion: '1.0.9 - 1.1.11',
    minFlutterVersion: '3.3.0',
  ),
]..sort((a, b) {
    final aVersion = a.patrolTopRangeVersion ?? a.patrolBottomRangeVersion;
    final bVersion = b.patrolTopRangeVersion ?? b.patrolBottomRangeVersion;
    return bVersion.compareTo(aVersion);
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

/// Helper function to get the maximum compatible CLI version for a given patrol version
Version? getMaxCompatibleCliVersion(Version patrolVersion) {
  Version? maxCli;
  for (final compatibility in versionCompatibilityList) {
    // Check if patrol version is in range
    if (patrolVersion >= compatibility.patrolBottomRangeVersion &&
        (compatibility.patrolTopRangeVersion == null ||
            patrolVersion <= compatibility.patrolTopRangeVersion)) {
      // If patrol version is compatible, consider this CLI version
      final cliMax = compatibility.patrolCliTopRangeVersion ??
          compatibility.patrolCliBottomRangeVersion;
      if (maxCli == null || cliMax > maxCli) {
        maxCli = cliMax;
      }
    }
  }
  return maxCli;
}
