import 'dart:io';

import 'package:chase/src/analyzer/diff_analyzer.dart';
import 'package:chase/src/analyzer/diff_models.dart';
import 'package:test/test.dart';

void main() {
  group('DiffAnalyzer', () {
    late DiffAnalyzer analyzer;

    setUp(() {
      analyzer = DiffAnalyzer(
        excludePatterns: ['**/*.g.dart', '**/*.freezed.dart'],
      );
    });

    test('parses new file diff correctly', () {
      const diff = '''
diff --git a/lib/src/screens/home_screen.dart b/lib/src/screens/home_screen.dart
new file mode 100644
--- /dev/null
+++ b/lib/src/screens/home_screen.dart
@@ -0,0 +1,10 @@
+import 'package:flutter/material.dart';
+
+class HomeScreen extends StatefulWidget {
+  const HomeScreen({super.key});
+
+  @override
+  State<HomeScreen> createState() => _HomeScreenState();
+}
''';

      final result = analyzer.analyze(diff);

      expect(result.files, hasLength(1));
      expect(result.files.first.path, 'lib/src/screens/home_screen.dart');
      expect(result.files.first.changeType, ChangeType.added);
      expect(result.files.first.isDartFile, isTrue);
    });

    test('parses modified file diff correctly', () {
      const diff = '''
diff --git a/lib/src/widgets/button.dart b/lib/src/widgets/button.dart
--- a/lib/src/widgets/button.dart
+++ b/lib/src/widgets/button.dart
@@ -10,6 +10,7 @@
   final String label;
   final VoidCallback onPressed;
+  final Color? color;
''';

      final result = analyzer.analyze(diff);

      expect(result.files, hasLength(1));
      expect(result.files.first.changeType, ChangeType.modified);
      expect(result.files.first.additions, 1);
    });

    test('parses deleted file diff correctly', () {
      const diff = '''
diff --git a/lib/old_file.dart b/lib/old_file.dart
deleted file mode 100644
--- a/lib/old_file.dart
+++ /dev/null
@@ -1,5 +0,0 @@
-import 'package:flutter/material.dart';
-
-class OldFile {}
''';

      final result = analyzer.analyze(diff);

      expect(result.files, hasLength(1));
      expect(result.files.first.changeType, ChangeType.deleted);
    });

    test('excludes generated files', () {
      const diff = '''
diff --git a/lib/src/models/user.g.dart b/lib/src/models/user.g.dart
--- a/lib/src/models/user.g.dart
+++ b/lib/src/models/user.g.dart
@@ -1,5 +1,6 @@
 // GENERATED CODE
+// change
''';

      final result = analyzer.analyze(diff);

      expect(result.files, isEmpty);
    });

    test('handles multiple files in one diff', () {
      const diff = '''
diff --git a/lib/a.dart b/lib/a.dart
new file mode 100644
--- /dev/null
+++ b/lib/a.dart
@@ -0,0 +1,3 @@
+class A {}
diff --git a/lib/b.dart b/lib/b.dart
new file mode 100644
--- /dev/null
+++ b/lib/b.dart
@@ -0,0 +1,3 @@
+class B {}
''';

      final result = analyzer.analyze(diff);

      expect(result.files, hasLength(2));
      expect(result.files[0].path, 'lib/a.dart');
      expect(result.files[1].path, 'lib/b.dart');
    });

    test('parses hunk line numbers correctly', () {
      const diff = '''
diff --git a/lib/file.dart b/lib/file.dart
--- a/lib/file.dart
+++ b/lib/file.dart
@@ -5,3 +5,4 @@
   final String name;
+  final int age;
   final String email;
''';

      final result = analyzer.analyze(diff);
      final hunk = result.files.first.hunks.first;

      expect(hunk.oldStart, 5);
      expect(hunk.newStart, 5);
      expect(hunk.additions, 1);
    });

    test('parses sample fixture diff', () {
      final fixtureFile = File('test/fixtures/sample_diff.txt');
      if (!fixtureFile.existsSync()) {
        // Skip if fixture not available
        return;
      }

      final rawDiff = fixtureFile.readAsStringSync();
      final result = analyzer.analyze(rawDiff);

      // Should have 2 files (home_screen and custom_button),
      // user.g.dart should be excluded
      expect(result.files, hasLength(2));
      expect(
        result.files.any((f) => f.path.contains('home_screen')),
        isTrue,
      );
      expect(
        result.files.any((f) => f.path.contains('custom_button')),
        isTrue,
      );
      expect(
        result.files.any((f) => f.path.contains('.g.dart')),
        isFalse,
      );
    });
  });
}
