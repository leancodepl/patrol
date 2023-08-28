import 'package:path/path.dart' as p;

String normalizePath(String path) => p.normalize(p.absolute(path));

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}
