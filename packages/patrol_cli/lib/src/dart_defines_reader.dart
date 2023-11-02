import 'package:file/file.dart';
import 'package:patrol_cli/src/base/extensions/core.dart';

class DartDefinesReader {
  DartDefinesReader({
    required Directory projectRoot,
  })  : _projectRoot = projectRoot,
        _fs = projectRoot.fileSystem;

  final Directory _projectRoot;
  final FileSystem _fs;

  Map<String, String> fromCli({required List<String> args}) => _parse(args);

  Map<String, String> fromFile() {
    final filePath = _fs.path.join(_projectRoot.path, '.patrol.env');
    final file = _fs.file(filePath);

    if (!file.existsSync()) {
      return {};
    }

    final lines = file.readAsLinesSync()
      ..removeWhere((line) => line.trim().isEmpty);
    return _parse(lines);
  }

  Map<String, String> _parse(List<String> args) {
    final map = <String, String>{};
    var currentKey = ' ';
    for (final arg in args) {
      if (!arg.contains('=') && currentKey != ' ') {
        map[currentKey] = '${map[currentKey]}, $arg';
        continue;
      }
      final parts = arg.splitFirst('=');
      currentKey = parts.first;
      if (currentKey.contains(' ')) {
        throw FormatException('key "$currentKey" contains whitespace');
      }

      final value = parts.elementAt(1);
      map[currentKey] = value;
    }

    return map;
  }
}
