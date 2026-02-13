import 'dart:io';

import '../utils/process_runner.dart';

/// Git operations wrapper for diff, branch, commit, and push.
class GitClient {
  GitClient({
    ProcessRunner? processRunner,
    String? projectRoot,
  })  : _processRunner = processRunner ?? const ProcessRunner(),
        _projectRoot = projectRoot;

  final ProcessRunner _processRunner;
  final String? _projectRoot;

  /// The project root directory (git root).
  String get projectRoot {
    if (_projectRoot != null) return _projectRoot!;
    return Directory.current.path;
  }

  /// Gets the diff between the current branch and [baseBranch].
  Future<String> diff(String baseBranch) async {
    final result = await _processRunner.run(
      'git',
      ['diff', '$baseBranch...HEAD'],
      workingDirectory: projectRoot,
    );

    if (!result.success) {
      // Try without merge-base syntax for repos without common ancestor
      final fallbackResult = await _processRunner.run(
        'git',
        ['diff', baseBranch],
        workingDirectory: projectRoot,
      );
      return fallbackResult.stdout;
    }

    return result.stdout;
  }

  /// Gets the current branch name.
  Future<String> currentBranch() async {
    final result = await _processRunner.run(
      'git',
      ['branch', '--show-current'],
      workingDirectory: projectRoot,
    );
    return result.stdout.trim();
  }

  /// Gets the current git status.
  Future<String> status() async {
    final result = await _processRunner.run(
      'git',
      ['status', '--short'],
      workingDirectory: projectRoot,
    );
    return result.stdout;
  }

  /// Creates a new branch.
  Future<bool> createBranch(String branchName) async {
    final result = await _processRunner.run(
      'git',
      ['checkout', '-b', branchName],
      workingDirectory: projectRoot,
    );
    return result.success;
  }

  /// Switches to an existing branch.
  Future<bool> checkout(String branchName) async {
    final result = await _processRunner.run(
      'git',
      ['checkout', branchName],
      workingDirectory: projectRoot,
    );
    return result.success;
  }

  /// Stages files for commit.
  Future<bool> add(List<String> files) async {
    final result = await _processRunner.run(
      'git',
      ['add', ...files],
      workingDirectory: projectRoot,
    );
    return result.success;
  }

  /// Creates a commit.
  Future<bool> commit(String message) async {
    final result = await _processRunner.run(
      'git',
      ['commit', '-m', message],
      workingDirectory: projectRoot,
    );
    return result.success;
  }

  /// Pushes to remote.
  Future<bool> push({String remote = 'origin', String? branch}) async {
    final args = ['push'];
    if (branch != null) {
      args.addAll(['-u', remote, branch]);
    } else {
      args.add(remote);
    }

    final result = await _processRunner.run(
      'git',
      args,
      workingDirectory: projectRoot,
    );
    return result.success;
  }

  /// Gets the remote URL for the repository.
  Future<String?> remoteUrl({String remote = 'origin'}) async {
    final result = await _processRunner.run(
      'git',
      ['remote', 'get-url', remote],
      workingDirectory: projectRoot,
    );
    return result.success ? result.stdout.trim() : null;
  }

  /// Parses owner/repo from a GitHub remote URL.
  ({String owner, String repo})? parseGitHubRepo(String remoteUrl) {
    // SSH format: git@github.com:owner/repo.git
    final sshMatch = RegExp(r'git@github\.com:(.+)/(.+?)(?:\.git)?$')
        .firstMatch(remoteUrl);
    if (sshMatch != null) {
      return (owner: sshMatch.group(1)!, repo: sshMatch.group(2)!);
    }

    // HTTPS format: https://github.com/owner/repo.git
    final httpsMatch = RegExp(r'github\.com/(.+)/(.+?)(?:\.git)?$')
        .firstMatch(remoteUrl);
    if (httpsMatch != null) {
      return (owner: httpsMatch.group(1)!, repo: httpsMatch.group(2)!);
    }

    return null;
  }
}
