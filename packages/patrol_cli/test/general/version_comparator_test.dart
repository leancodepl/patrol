import 'package:patrol_cli/src/compatibility_checker/version_comparator.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('VersionComparator', () {
    late VersionComparator versionComparator;

    bool compatibility(String cli, String package) {
      return versionComparator.isCompatible(
        Version.parse(cli),
        Version.parse(package),
      );
    }

    test(
        'properly determines compatibility and incompatibility in a basic case',
        () {
      final cliVersions = [
        VersionRange(
          min: Version.parse('1.0.0'),
          max: Version.parse('1.1.0'),
        ),
        VersionRange(
          min: Version.parse('1.2.0'),
          max: Version.parse('2.0.0'),
        ),
      ];
      final packageVersions = [
        VersionRange(
          min: Version.parse('1.0.0'),
          max: Version.parse('1.5.0'),
        ),
        VersionRange(
          min: Version.parse('1.5.0'),
          max: Version.parse('2.0.1'),
        ),
      ];
      versionComparator = VersionComparator(
        cliVersionRange: cliVersions,
        packageVersionRange: packageVersions,
      );

      expect(
        compatibility('1.0.0', '1.0.0'),
        true,
      );
      expect(
        compatibility('1.1.0', '1.0.0'),
        true,
      );
      expect(
        compatibility('1.3.0', '1.0.0'),
        false,
      );
      expect(
        compatibility('1.3.0', '2.0.0'),
        true,
      );
    });

    test(
        'properly determines compatibility and incompatibility in a case where new package versions are backwards compatible with old cli',
        () {
      final cliVersions = [
        VersionRange(
          min: Version.parse('1.0.0'),
          max: Version.parse('1.1.0'),
        ),
        VersionRange(
          min: Version.parse('1.2.0'),
          max: Version.parse('2.0.0'),
        ),
      ];
      final packageVersions = [
        VersionRange(
          min: Version.parse('1.0.0'),
        ),
        VersionRange(
          min: Version.parse('1.5.0'),
          max: Version.parse('2.0.1'),
        ),
      ];
      versionComparator = VersionComparator(
        cliVersionRange: cliVersions,
        packageVersionRange: packageVersions,
      );

      expect(
        compatibility('1.0.0', '1.0.0'),
        true,
      );
      expect(
        compatibility('1.1.0', '2.0.1'),
        true,
      );
      expect(
        compatibility('1.2.1', '2.0.1'),
        true,
      );
    });

    test(
        'properly determines compatibility and incompatibility in a case where new cli versions are backwards compatible with old package',
        () {
      final cliVersions = [
        VersionRange(
          min: Version.parse('1.0.0'),
        ),
        VersionRange(
          min: Version.parse('1.2.0'),
          max: Version.parse('2.0.0'),
        ),
      ];
      final packageVersions = [
        VersionRange(
          min: Version.parse('1.0.0'),
          max: Version.parse('1.4.0'),
        ),
        VersionRange(
          min: Version.parse('1.5.0'),
          max: Version.parse('2.0.1'),
        ),
      ];
      versionComparator = VersionComparator(
        cliVersionRange: cliVersions,
        packageVersionRange: packageVersions,
      );

      expect(
        compatibility('1.0.0', '1.0.0'),
        true,
      );
      expect(
        compatibility('1.3.0', '1.2.0'),
        true,
      );
      expect(
        compatibility('1.1.0', '1.5.0'),
        false,
      );
      expect(
        compatibility('1.3.0', '1.5.0'),
        true,
      );
    });
  });
}
