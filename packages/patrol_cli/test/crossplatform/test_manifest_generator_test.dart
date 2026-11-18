import 'package:patrol_cli/src/crossplatform/test_manifest_generator.dart';
import 'package:test/test.dart';

void main() {
  group('failureExcerpt', () {
    test('starts at the first failed load', () {
      final output = [
        'Resolving dependencies...',
        'Got dependencies!',
        '00:00 +0 -1: loading test_bundle.dart [E]',
        '  Unsupported operation: Unsupported platform',
        '  patrol_test/swipe_test.dart 15:5  main',
      ];

      expect(TestManifestGenerator.failureExcerpt(output), output.sublist(2));
    });

    test('starts at the first compilation error', () {
      final output = [
        'Got dependencies!',
        "app.dart:2:8: Error: Dart library 'dart:ui_web' is not available",
        "import 'dart:ui_web';",
      ];

      expect(TestManifestGenerator.failureExcerpt(output), output.sublist(1));
    });

    test('falls back to the last lines', () {
      final output = [for (var i = 0; i < 50; i++) 'line $i'];

      expect(TestManifestGenerator.failureExcerpt(output, maxLines: 3), [
        'line 47',
        'line 48',
        'line 49',
      ]);
    });

    test('caps the excerpt', () {
      final output = ['x [E]', for (var i = 0; i < 50; i++) 'line $i'];

      expect(TestManifestGenerator.failureExcerpt(output), hasLength(40));
    });
  });
}
