import 'package:file/file.dart';

import '../../common/tool_exit.dart';

class TestFinder {
  TestFinder({
    required Directory integrationTestDir,
    required FileSystem fs,
  })  : _integrationTestDirectory = integrationTestDir,
        _fs = fs;

  final Directory _integrationTestDirectory;
  final FileSystem _fs;

  /// Checks that every element of [targets] points to a valid file
  List<String> findTests(List<String> targets) {
    for (final target in targets) {
      final hasSuffix = target.endsWith('_test.dart');
      if (hasSuffix) {
        throwToolExit('target file $target has invalid suffix');
      }

      final isFile = _fs.isFileSync(target);
      if (!isFile) {
        throwToolExit('target file $target does not exist');
      }
    }

    return targets;
  }

  /// Recursively searches the `integration_test` directory and returns files
  /// that end with `_test.dart` as absolute paths.
  List<String> findAllTests() {
    return _integrationTestDirectory
        .listSync(recursive: true, followLinks: false)
        .where(
          (fileSystemEntity) {
            final hasSuffix = fileSystemEntity.path.endsWith('_test.dart');
            final isFile = _fs.isFileSync(fileSystemEntity.path);
            return hasSuffix && isFile;
          },
        )
        .map((entity) => entity.absolute.path)
        .toList();
  }
}
