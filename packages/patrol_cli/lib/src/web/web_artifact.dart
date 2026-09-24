import 'package:file/file.dart';

/// Names of the directories that a machine running a prebuilt web artifact
/// needs: the compiled app to serve, and the Playwright runner to drive it.
const kWebArtifactAppDir = 'app';
const kWebArtifactRunnerDir = 'runner';

/// Directories and files of the web runner that are either regenerated on the
/// runner machine or belong to a previous run.
const _runnerExcludes = {
  'node_modules',
  'test-results',
  'playwright-report',
  '.cache',
};

/// The directory layout that `patrol build web` produces and
/// `patrol test-without-building --input` consumes.
///
/// It is self-contained on purpose: running it needs neither Flutter nor a
/// resolved pub cache, only Node.
class WebArtifact {
  WebArtifact(this.root);

  factory WebArtifact.at(String path, {required FileSystem fs}) =>
      WebArtifact(fs.directory(path));

  final Directory root;

  Directory get appDir => root.childDirectory(kWebArtifactAppDir);

  Directory get runnerDir => root.childDirectory(kWebArtifactRunnerDir);

  /// The reason this directory can't be run, or null when it can.
  String? get problem {
    if (!root.existsSync()) {
      return 'Directory ${root.path} does not exist.';
    }
    if (!appDir.childFile('index.html').existsSync()) {
      return 'No compiled web app at ${appDir.path} '
          '(expected an index.html there).';
    }
    if (!runnerDir.childFile('package.json').existsSync()) {
      return 'No Playwright runner at ${runnerDir.path} '
          '(expected a package.json there).';
    }
    return null;
  }

  /// Whether [root] holds something other than the two directories this class
  /// writes, in which case it isn't ours to empty.
  bool get holdsForeignEntries =>
      root.existsSync() &&
      root.listSync().any((entry) {
        final name = entry.fileSystem.path.basename(entry.path);
        return name != kWebArtifactAppDir && name != kWebArtifactRunnerDir;
      });

  /// Copies the patrol package's `web_runner` at [source] into [runnerDir],
  /// leaving out what `npm install` regenerates.
  void copyRunnerFrom(Directory source) {
    if (runnerDir.existsSync()) {
      runnerDir.deleteSync(recursive: true);
    }
    _copyDirectory(source, runnerDir, excludeNames: _runnerExcludes);
  }

  void _copyDirectory(
    Directory from,
    Directory to, {
    Set<String> excludeNames = const {},
  }) {
    to.createSync(recursive: true);

    for (final entity in from.listSync()) {
      final name = from.fileSystem.path.basename(entity.path);
      if (excludeNames.contains(name)) {
        continue;
      }

      final target = to.fileSystem.path.join(to.path, name);
      if (entity is Directory) {
        _copyDirectory(entity, to.fileSystem.directory(target));
      } else if (entity is File) {
        entity.copySync(target);
      }
    }
  }
}
