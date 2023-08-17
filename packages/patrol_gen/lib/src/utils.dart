import 'package:path/path.dart' as p;

String normalizePath(String path) => p.normalize(p.absolute(path));
