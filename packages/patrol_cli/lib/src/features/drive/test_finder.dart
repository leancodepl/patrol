import 'package:file/file.dart';

class TestFinder {
  TestFinder({
    required Directory integrationTestDir,
    required FileSystem fileSystem,
  })  : _integrationTestDirectory = integrationTestDir,
        _fileSystem = fileSystem;

  final Directory _integrationTestDirectory;
  final FileSystem _fileSystem;

  /// Recursively searches the `integration_test` directory and returns files
  /// that end with `_test.dart` as absolute paths.
  List<String> findTests() {
    return _integrationTestDirectory
        .listSync(recursive: true, followLinks: false)
        .where(
          (fileSystemEntity) {
            final hasSuffix = fileSystemEntity.path.endsWith('_test.dart');
            final isFile = _fileSystem.isFileSync(fileSystemEntity.path);
            return hasSuffix && isFile;
          },
        )
        .map((entity) => entity.absolute.path)
        .toList();
  }
}
