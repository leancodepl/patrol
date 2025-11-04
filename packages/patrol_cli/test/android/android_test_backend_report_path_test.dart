import 'package:patrol_cli/src/android/android_test_backend.dart';
import 'package:patrol_cli/src/ios/ios_test_backend.dart';
import 'package:test/test.dart';

void main() {
  group('AndroidTestBackend.generateTestReportPath()', () {
    const rootPath = '/example/project';
    const flavor = 'dev';

    /// Helper function to build expected path
    String buildExpectedPath(String buildMode, {String? flavor}) {
      const baseUrl =
          'file://$rootPath/build/app/reports/androidTests/connected';
      if (flavor != null) {
        return '$baseUrl/$buildMode/flavors/$flavor/index.html';
      }
      return '$baseUrl/$buildMode/index.html';
    }

    /// Helper function to test path generation
    void testPathGeneration({
      required String testName,
      required BuildMode buildMode,
      String? flavor,
    }) {
      test(testName, () {
        final actualPath = AndroidTestBackend.generateTestReportPath(
          rootPath: rootPath,
          buildMode: buildMode,
          flavor: flavor,
        );

        final expectedPath = buildExpectedPath(
          buildMode.androidName.toLowerCase(),
          flavor: flavor,
        );

        expect(actualPath, equals(expectedPath));
      });
    }

    testPathGeneration(
      testName: 'build mode only (no flavor) - debug',
      buildMode: BuildMode.debug,
    );

    testPathGeneration(
      testName: 'with flavor - debug build mode',
      buildMode: BuildMode.debug,
      flavor: flavor,
    );

    testPathGeneration(
      testName: 'with flavor - release build mode',
      buildMode: BuildMode.release,
      flavor: flavor,
    );

    testPathGeneration(
      testName: 'with flavor - profile build mode',
      buildMode: BuildMode.profile,
      flavor: flavor,
    );
  });
}
