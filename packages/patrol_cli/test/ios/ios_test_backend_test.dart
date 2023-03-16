import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
  group('IOSTestBackend', () {
    group('BuildMode', () {
      test('infers build options in debug mode when flavor is null', () {
        const buildMode = BuildMode.debug;
        String? flavor;

        expect(buildMode.createConfiguration(flavor), 'Debug');
        expect(buildMode.createScheme(flavor), 'Runner');
      });

      test('infers build options in debug mode when flavor is not null', () {
        const buildMode = BuildMode.debug;
        const flavor = 'dev';

        expect(buildMode.createConfiguration(flavor), 'Debug-dev');
        expect(buildMode.createScheme(flavor), 'dev');
      });

      test('infers build options in release mode when flavor is null', () {
        const buildMode = BuildMode.release;
        String? flavor;

        expect(buildMode.createConfiguration(flavor), 'Release');
        expect(buildMode.createScheme(flavor), 'Runner');
      });

      test('infers build options in release mode when flavor is not null', () {
        const buildMode = BuildMode.release;
        const flavor = 'prod';

        expect(buildMode.createConfiguration(flavor), 'Release-prod');
        expect(buildMode.createScheme(flavor), 'prod');
      });
    });
  });
}
