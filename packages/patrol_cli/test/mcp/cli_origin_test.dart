import 'package:patrol_cli/src/mcp/cli_origin.dart';
import 'package:test/test.dart';

void main() {
  CliOrigin from(String path) =>
      CliOrigin.fromScript(Uri.file(path), version: '4.9.0');

  test('a global activation runs from pub global_packages', () {
    final origin = from(
      '/Users/a/.pub-cache/global_packages/patrol_cli/bin/main.dart-3.12.snapshot',
    );

    expect(origin.source, CliSource.global);
    expect(origin.projectRoot, isNull);
  });

  test('a dev dependency runs from its project .dart_tool', () {
    final origin = from(
      '/work/app/.dart_tool/pub/bin/patrol_cli/main.dart-3.12.snapshot',
    );

    expect(origin.source, CliSource.project);
    expect(origin.projectRoot, '/work/app');
  });

  test("patrol_cli's own checkout is a path, not a project", () {
    expect(
      from(
        '/src/patrol/packages/patrol_cli/.dart_tool/pub/bin/patrol_cli/'
        'main.dart-3.12.snapshot',
      ).source,
      CliSource.path,
    );
    expect(
      from('/src/patrol/packages/patrol_cli/bin/main.dart').source,
      CliSource.path,
    );
  });

  test('a compiled executable is a path', () {
    expect(from('/usr/local/bin/patrol').source, CliSource.path);
  });

  test('reports its version and source', () {
    expect(
      from('/work/app/.dart_tool/pub/bin/patrol_cli/main.snapshot').toMap(),
      {'version': '4.9.0', 'source': 'project', 'projectRoot': '/work/app'},
    );
  });
}
