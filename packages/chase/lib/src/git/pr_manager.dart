import '../cli/common/cli_logger.dart';
import '../config/chase_config.dart';
import 'git_client.dart';
import 'github_client.dart';

/// Orchestrates the branch + PR workflow for test submissions.
class PrManager {
  PrManager({
    required GitClient gitClient,
    required ChaseConfig config,
    required CliLogger logger,
  })  : _gitClient = gitClient,
        _config = config,
        _logger = logger;

  final GitClient _gitClient;
  final ChaseConfig _config;
  final CliLogger _logger;

  /// Creates a PR with the generated test files.
  ///
  /// Returns the PR URL on success, null on failure.
  Future<String?> createTestPr({
    required List<String> generatedFiles,
    required String summary,
    required String costSummary,
  }) async {
    if (generatedFiles.isEmpty) return null;

    try {
      // Get current branch
      final devBranch = await _gitClient.currentBranch();
      final testBranch =
          '${_config.git.branchPrefix}tests-for-$devBranch';

      _logger.detail('Dev branch: $devBranch');
      _logger.detail('Test branch: $testBranch');

      // Create test branch
      final branchCreated = await _gitClient.createBranch(testBranch);
      if (!branchCreated) {
        _logger.error('Failed to create branch: $testBranch');
        return null;
      }

      // Stage test files
      await _gitClient.add(generatedFiles);

      // Commit
      final commitMessage = _buildCommitMessage(
        generatedFiles: generatedFiles,
        summary: summary,
      );
      final committed = await _gitClient.commit(commitMessage);
      if (!committed) {
        _logger.error('Failed to commit test files.');
        await _gitClient.checkout(devBranch);
        return null;
      }

      // Push
      if (_config.git.autoPush) {
        final pushed = await _gitClient.push(branch: testBranch);
        if (!pushed) {
          _logger.error('Failed to push to remote.');
          await _gitClient.checkout(devBranch);
          return null;
        }
      }

      // Create PR
      String? prUrl;
      if (_config.git.autoCreatePr) {
        prUrl = await _createPr(
          testBranch: testBranch,
          devBranch: devBranch,
          generatedFiles: generatedFiles,
          summary: summary,
          costSummary: costSummary,
        );
      }

      // Switch back to dev branch
      await _gitClient.checkout(devBranch);

      return prUrl;
    } on Exception catch (e) {
      _logger.error('PR workflow error: $e');
      return null;
    }
  }

  Future<String?> _createPr({
    required String testBranch,
    required String devBranch,
    required List<String> generatedFiles,
    required String summary,
    required String costSummary,
  }) async {
    final githubToken = _config.apiKeys.github;
    if (githubToken == null || githubToken.isEmpty) {
      _logger.warn('No GitHub token configured. Skipping PR creation.');
      return null;
    }

    final remoteUrl = await _gitClient.remoteUrl();
    if (remoteUrl == null) {
      _logger.error('Could not determine remote URL.');
      return null;
    }

    final repoInfo = _gitClient.parseGitHubRepo(remoteUrl);
    if (repoInfo == null) {
      _logger.error('Could not parse GitHub repo from: $remoteUrl');
      return null;
    }

    final github = GithubClient(token: githubToken);

    try {
      final pr = await github.createPullRequest(
        owner: repoInfo.owner,
        repo: repoInfo.repo,
        title: '${_config.git.commitPrefix} Add Patrol tests for $devBranch',
        body: _buildPrBody(
          generatedFiles: generatedFiles,
          summary: summary,
          costSummary: costSummary,
        ),
        head: testBranch,
        base: devBranch,
      );

      return pr.url;
    } on GithubApiException catch (e) {
      _logger.error('Failed to create PR: $e');
      return null;
    } finally {
      github.dispose();
    }
  }

  String _buildCommitMessage({
    required List<String> generatedFiles,
    required String summary,
  }) {
    final buffer = StringBuffer()
      ..writeln('${_config.git.commitPrefix} Add Patrol integration tests')
      ..writeln()
      ..writeln('Generated ${generatedFiles.length} test file(s):');

    for (final file in generatedFiles) {
      buffer.writeln('  - $file');
    }

    if (summary.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(summary);
    }

    return buffer.toString();
  }

  String _buildPrBody({
    required List<String> generatedFiles,
    required String summary,
    required String costSummary,
  }) {
    final buffer = StringBuffer()
      ..writeln('## Chase — AI-Generated Patrol Tests')
      ..writeln()
      ..writeln('### Generated Files')
      ..writeln();

    for (final file in generatedFiles) {
      buffer.writeln('- `$file`');
    }

    if (summary.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('### Summary')
        ..writeln()
        ..writeln(summary);
    }

    buffer
      ..writeln()
      ..writeln('### Cost')
      ..writeln()
      ..writeln(costSummary)
      ..writeln()
      ..writeln('---')
      ..writeln('*Generated by [Chase](https://github.com/nicenathapong/chase) — AI-powered Patrol test generation*');

    return buffer.toString();
  }
}
