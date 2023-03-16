import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
  group('IOSTestBackend', () {
    group('BuildMode', () {
      test('infers build options when flavor is null', () {
        String? flavor;
        const buildMode = BuildMode.debug;

        expect(buildMode.createConfiguration(flavor), 'Debug');
        expect(buildMode.createScheme(flavor), 'Runner');
      });

      test('infers build options when flavor is not null', () {
        const flavor = 'dev';
        const buildMode = BuildMode.debug;

        expect(buildMode.createConfiguration(flavor), 'Debug-dev');
        expect(buildMode.createScheme(flavor), 'dev');
      });
    });
  });
}
