import 'package:file/memory.dart';
import 'package:patrol_cli/src/web/web_artifact.dart';
import 'package:test/test.dart';

void main() {
  late MemoryFileSystem fs;

  setUp(() => fs = MemoryFileSystem());

  group('problem', () {
    test('names the missing app', () {
      fs.directory('out').createSync(recursive: true);

      expect(WebArtifact.at('out', fs: fs).problem, contains('index.html'));
    });

    test('names the missing runner', () {
      fs.file('out/app/index.html').createSync(recursive: true);

      expect(WebArtifact.at('out', fs: fs).problem, contains('package.json'));
    });

    test('is null for a complete artifact', () {
      fs.file('out/app/index.html').createSync(recursive: true);
      fs.file('out/runner/package.json').createSync(recursive: true);

      expect(WebArtifact.at('out', fs: fs).problem, isNull);
    });
  });

  test('a directory with unrelated files is not ours to overwrite', () {
    fs.file('out/notes.txt').createSync(recursive: true);

    expect(WebArtifact.at('out', fs: fs).holdsForeignEntries, isTrue);
  });

  test('copies the runner without what npm install regenerates', () {
    final source = fs.directory('web_runner')..createSync(recursive: true);
    source.childFile('package.json').writeAsStringSync('{}');
    source.childFile('package-lock.json').writeAsStringSync('{}');
    fs.file('web_runner/tests/test.spec.ts').createSync(recursive: true);
    fs
        .file('web_runner/node_modules/playwright/index.js')
        .createSync(recursive: true);

    final artifact = WebArtifact.at('out', fs: fs)..copyRunnerFrom(source);

    expect(artifact.runnerDir.childFile('package.json').existsSync(), isTrue);
    expect(
      artifact.runnerDir.childFile('package-lock.json').existsSync(),
      isTrue,
    );
    expect(
      artifact.runnerDir.childFile('tests/test.spec.ts').existsSync(),
      isTrue,
    );
    expect(
      artifact.runnerDir.childDirectory('node_modules').existsSync(),
      isFalse,
    );
  });

  test('a second build replaces the runner instead of merging into it', () {
    final source = fs.directory('web_runner')..createSync(recursive: true);
    source.childFile('package.json').writeAsStringSync('{}');

    final artifact = WebArtifact.at('out', fs: fs)..copyRunnerFrom(source);
    artifact.runnerDir.childFile('stale.ts').writeAsStringSync('old');

    artifact.copyRunnerFrom(source);

    expect(artifact.runnerDir.childFile('stale.ts').existsSync(), isFalse);
  });
}
