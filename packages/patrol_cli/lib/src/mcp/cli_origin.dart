import 'package:path/path.dart' as p;

/// Where the `patrol_cli` serving this MCP server comes from.
enum CliSource {
  /// `dart pub global activate patrol_cli`.
  global,

  /// A project's dev dependency, launched with `dart run patrol_cli:main`.
  project,

  /// A checkout or a compiled executable.
  path,
}

/// The `patrol_cli` that serves this MCP server.
final class CliOrigin {
  const CliOrigin({
    required this.version,
    required this.source,
    this.projectRoot,
  });

  /// Reads the origin from the running [script]. A global activation runs from
  /// pub's `global_packages`, and `dart run` runs a dependency's snapshot from
  /// its project's `.dart_tool/pub/bin`; a project named `patrol_cli` is this
  /// repository's own checkout.
  factory CliOrigin.fromScript(Uri script, {required String version}) {
    final parts = p.split(p.normalize(script.toFilePath()));
    if (parts.contains('global_packages')) {
      return CliOrigin(version: version, source: CliSource.global);
    }
    final dartTool = parts.indexOf('.dart_tool');
    if (dartTool > 0 &&
        parts.length > dartTool + 2 &&
        parts[dartTool + 1] == 'pub' &&
        parts[dartTool + 2] == 'bin') {
      final root = p.joinAll(parts.take(dartTool));
      if (p.basename(root) != 'patrol_cli') {
        return CliOrigin(
          version: version,
          source: CliSource.project,
          projectRoot: root,
        );
      }
    }
    return CliOrigin(version: version, source: CliSource.path);
  }

  final String version;
  final CliSource source;

  /// The project whose dev dependency this is, for [CliSource.project].
  final String? projectRoot;

  Map<String, Object> toMap() => {
    'version': version,
    'source': source.name,
    'projectRoot': ?projectRoot,
  };
}
