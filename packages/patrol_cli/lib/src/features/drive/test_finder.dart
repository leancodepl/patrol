import 'dart:io';

class TestFinder {
  Directory get _integrationTestDir => Directory('integration_test');

  /// Recursively searches the `integration_test` directory and returns files
  /// that end with `_test.dart` as absolute paths.
  List<String> findTests() {
    return _integrationTestDir
        .listSync(recursive: true, followLinks: false)
        .where(
          (fileSystemEntity) {
            final hasSuffix = fileSystemEntity.path.endsWith('_test.dart');
            final isFile = FileSystemEntity.isFileSync(fileSystemEntity.path);
            return hasSuffix && isFile;
          },
        )
        .map((entity) => entity.absolute.path)
        .toList();
  }
}
