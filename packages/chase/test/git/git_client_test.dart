import 'package:chase/src/git/git_client.dart';
import 'package:test/test.dart';

void main() {
  group('GitClient', () {
    group('parseGitHubRepo', () {
      late GitClient client;

      setUp(() {
        client = GitClient();
      });

      test('parses SSH remote URL', () {
        final result = client.parseGitHubRepo(
          'git@github.com:leancode/chase.git',
        );

        expect(result, isNotNull);
        expect(result!.owner, 'leancode');
        expect(result.repo, 'chase');
      });

      test('parses HTTPS remote URL', () {
        final result = client.parseGitHubRepo(
          'https://github.com/leancode/chase.git',
        );

        expect(result, isNotNull);
        expect(result!.owner, 'leancode');
        expect(result.repo, 'chase');
      });

      test('parses HTTPS URL without .git', () {
        final result = client.parseGitHubRepo(
          'https://github.com/leancode/chase',
        );

        expect(result, isNotNull);
        expect(result!.owner, 'leancode');
        expect(result.repo, 'chase');
      });

      test('returns null for non-GitHub URL', () {
        final result = client.parseGitHubRepo(
          'https://gitlab.com/user/repo.git',
        );

        expect(result, isNull);
      });
    });
  });
}
