import 'package:patrol_cli/src/compatibility_checker/version_compatibility.dart';
import 'package:test/test.dart';
import 'package:version/version.dart';

void main() {
  group('VersionCompatibility', () {
    test('constructor creates instance with valid versions', () {
      final compat = VersionCompatibility(
        patrolBottomRangeVersion: Version.parse('1.0.0'),
        patrolTopRangeVersion: Version.parse('2.0.0'),
        patrolCliBottomRangeVersion: Version.parse('3.0.0'),
        patrolCliTopRangeVersion: Version.parse('4.0.0'),
        minFlutterVersion: Version.parse('3.0.0'),
      );

      expect(compat.patrolBottomRangeVersion.toString(), equals('1.0.0'));
      expect(compat.patrolTopRangeVersion.toString(), equals('2.0.0'));
      expect(compat.patrolCliBottomRangeVersion.toString(), equals('3.0.0'));
      expect(compat.patrolCliTopRangeVersion.toString(), equals('4.0.0'));
      expect(compat.minFlutterVersion.toString(), equals('3.0.0'));
    });

    test('fromRangeString parses simple version ranges correctly', () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0 - 2.0.0',
        patrolCliVersion: '3.0.0 - 4.0.0',
        minFlutterVersion: '3.0.0',
      );

      expect(compat.patrolBottomRangeVersion.toString(), equals('1.0.0'));
      expect(compat.patrolTopRangeVersion.toString(), equals('2.0.0'));
      expect(compat.patrolCliBottomRangeVersion.toString(), equals('3.0.0'));
      expect(compat.patrolCliTopRangeVersion.toString(), equals('4.0.0'));
      expect(compat.minFlutterVersion.toString(), equals('3.0.0'));
    });

    test('fromRangeString parses pre-release versions correctly', () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0-beta.1 - 2.0.0-beta.2',
        patrolCliVersion: '3.0.0-rc.1 - 4.0.0-rc.2',
        minFlutterVersion: '3.0.0-dev.1',
      );

      expect(
          compat.patrolBottomRangeVersion.toString(), equals('1.0.0-beta.1'));
      expect(compat.patrolTopRangeVersion.toString(), equals('2.0.0-beta.2'));
      expect(
          compat.patrolCliBottomRangeVersion.toString(), equals('3.0.0-rc.1'));
      expect(compat.patrolCliTopRangeVersion.toString(), equals('4.0.0-rc.2'));
      expect(compat.minFlutterVersion.toString(), equals('3.0.0-dev.1'));
    });

    test('fromRangeString parses version ranges with build numbers correctly',
        () {
      final compat = VersionCompatibility.fromRangeString(
        patrolVersion: '1.0.0+1 - 2.0.0+2',
        patrolCliVersion: '3.0.0+1 - 4.0.0+2',
        minFlutterVersion: '3.0.0+1',
      );

      expect(compat.patrolBottomRangeVersion.toString(), equals('1.0.0+1'));
      expect(compat.patrolTopRangeVersion.toString(), equals('2.0.0+2'));
      expect(compat.patrolCliBottomRangeVersion.toString(), equals('3.0.0+1'));
      expect(compat.patrolCliTopRangeVersion.toString(), equals('4.0.0+2'));
      expect(compat.minFlutterVersion.toString(), equals('3.0.0+1'));
    });

    test('isCompatible returns true for versions within range', () {
      final compat = VersionCompatibility(
        patrolBottomRangeVersion: Version.parse('1.0.0'),
        patrolTopRangeVersion: Version.parse('2.0.0'),
        patrolCliBottomRangeVersion: Version.parse('3.0.0'),
        patrolCliTopRangeVersion: Version.parse('4.0.0'),
        minFlutterVersion: Version.parse('3.0.0'),
      );

      expect(
        compat.isCompatible(
          Version.parse('3.5.0'),
          Version.parse('1.5.0'),
        ),
        isTrue,
      );
    });

    test('isCompatible returns false for versions outside range', () {
      final compat = VersionCompatibility(
        patrolBottomRangeVersion: Version.parse('1.0.0'),
        patrolTopRangeVersion: Version.parse('2.0.0'),
        patrolCliBottomRangeVersion: Version.parse('3.0.0'),
        patrolCliTopRangeVersion: Version.parse('4.0.0'),
        minFlutterVersion: Version.parse('3.0.0'),
      );

      expect(
        compat.isCompatible(
          Version.parse('2.5.0'),
          Version.parse('1.5.0'),
        ),
        isFalse,
      );

      expect(
        compat.isCompatible(
          Version.parse('4.5.0'),
          Version.parse('1.5.0'),
        ),
        isFalse,
      );

      expect(
        compat.isCompatible(
          Version.parse('3.5.0'),
          Version.parse('0.5.0'),
        ),
        isFalse,
      );

      expect(
        compat.isCompatible(
          Version.parse('3.5.0'),
          Version.parse('2.5.0'),
        ),
        isFalse,
      );
    });

    test('getHighestCompatiblePatrolVersion returns correct version', () {
      final compat = VersionCompatibility(
        patrolBottomRangeVersion: Version.parse('1.0.0'),
        patrolTopRangeVersion: Version.parse('2.0.0'),
        patrolCliBottomRangeVersion: Version.parse('3.0.0'),
        patrolCliTopRangeVersion: Version.parse('4.0.0'),
        minFlutterVersion: Version.parse('3.0.0'),
      );

      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('3.5.0')),
        equals(Version.parse('2.0.0')),
      );

      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('2.5.0')),
        isNull,
      );

      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('4.5.0')),
        isNull,
      );
    });

    test('handles open-ended ranges correctly', () {
      final compat = VersionCompatibility(
        patrolBottomRangeVersion: Version.parse('1.0.0'),
        patrolTopRangeVersion: null,
        patrolCliBottomRangeVersion: Version.parse('3.0.0'),
        patrolCliTopRangeVersion: null,
        minFlutterVersion: Version.parse('3.0.0'),
      );

      expect(
        compat.isCompatible(
          Version.parse('3.5.0'),
          Version.parse('1.5.0'),
        ),
        isTrue,
      );

      expect(
        compat.isCompatible(
          Version.parse('4.0.0'),
          Version.parse('2.0.0'),
        ),
        isTrue,
      );

      expect(
        compat.getHighestCompatiblePatrolVersion(Version.parse('3.5.0')),
        equals(Version.parse('1.0.0')),
      );
    });
  });
}
