import 'package:file/file.dart';
import 'package:patrol_cli/src/base/constants.dart' as constants;
import 'package:patrol_cli/src/setup_validator/checks/android_checks.dart';
import 'package:patrol_cli/src/setup_validator/checks/ios_checks.dart';
import 'package:patrol_cli/src/setup_validator/checks/macos_checks.dart';
import 'package:patrol_cli/src/setup_validator/checks/shared_checks.dart';
import 'package:patrol_cli/src/setup_validator/environment_checks.dart';
import 'package:patrol_cli/src/setup_validator/finding.dart';
import 'package:patrol_cli/src/setup_validator/project_probe.dart';
import 'package:platform/platform.dart';

/// One titled group of findings in the validation output.
class ValidationSection {
  const ValidationSection({required this.title, required this.findings});

  final String title;
  final List<Finding> findings;
}

class ValidationReport {
  const ValidationReport({required this.sections});

  final List<ValidationSection> sections;

  Iterable<Finding> get findings =>
      sections.expand((section) => section.findings);

  int countOf(Severity severity) =>
      findings.where((finding) => finding.severity == severity).length;

  bool get hasErrors => countOf(Severity.error) > 0;
}

/// Validates the project's Patrol setup against the setup docs: a missing
/// marker is an Error, presence passes silently (detects omission only).
class SetupValidator {
  SetupValidator({
    required Directory projectRoot,
    required Platform platform,
    EnvironmentChecks? environmentChecks,
    String cliVersion = constants.version,
    String flutterExecutable = 'flutter',
  }) : _probe = ProjectProbe(projectRoot: projectRoot),
       _environmentChecks =
           environmentChecks ?? EnvironmentChecks(platform: platform),
       _cliVersion = cliVersion,
       _flutterExecutable = flutterExecutable;

  final ProjectProbe _probe;
  final EnvironmentChecks _environmentChecks;
  final String _cliVersion;
  final String _flutterExecutable;

  static const _platforms = ['android', 'ios', 'macos'];

  /// Runs all checks. [platformFilter] narrows platform-specific sections to
  /// the given subset of android/ios/macos; shared checks always run.
  ValidationReport validate({Set<String>? platformFilter}) {
    final ctx = SharedCheckContext(probe: _probe);

    if (ctx.isAddToAppModule) {
      // The documented setup targets standalone apps; erroring here would
      // send add-to-app users down the wrong path.
      return const ValidationReport(
        sections: [
          ValidationSection(
            title: 'Project',
            findings: [
              Finding(
                id: 'S0',
                severity: Severity.notice,
                summary:
                    'This is an add-to-app Flutter module (`flutter: '
                    'module:` in pubspec.yaml). `patrol validate` covers the '
                    'standalone-app setup from the docs; in add-to-app, '
                    'Patrol tests run from the host apps.',
              ),
            ],
          ),
        ],
      );
    }

    final declared = ctx.declaredPlatforms;
    final filtered = platformFilter == null
        ? declared
        : declared.intersection(platformFilter);

    return ValidationReport(
      sections: [
        ValidationSection(
          title: 'Environment',
          findings: _environmentChecks.check(
            declaredPlatforms: filtered,
            webPresent: _probe.dirExists('web'),
            flutterExecutable: _flutterExecutable,
          ),
        ),
        ValidationSection(title: 'Shared', findings: _sharedFindings(ctx)),
        ..._platformSections(ctx, filtered, platformFilter),
      ],
    );
  }

  List<Finding> _sharedFindings(SharedCheckContext ctx) {
    return [
      checkPatrolDependency(ctx),
      checkPatrolSection(ctx),
      checkAppName(ctx),
      checkStrayPatrolYaml(ctx),
      checkTestDirectory(ctx),
      checkIntegrationTestDirectory(ctx),
      checkTestBundleGitignored(ctx),
      checkVersionCompatibility(ctx, cliVersion: _cliVersion),
    ].nonNulls.toList();
  }

  List<ValidationSection> _platformSections(
    SharedCheckContext ctx,
    Set<String> validatedPlatforms,
    Set<String>? platformFilter,
  ) {
    final sections = <ValidationSection>[];

    for (final platform in _platforms) {
      if (platformFilter != null && !platformFilter.contains(platform)) {
        // Excluded by --platform: skip entirely, including the
        // present-but-undeclared notice below.
        continue;
      }
      if (validatedPlatforms.contains(platform)) {
        final findings = switch (platform) {
          'android' => androidFindings(AndroidCheckContext(probe: _probe)),
          'ios' => iosFindings(IOSCheckContext(probe: _probe)),
          'macos' => macosFindings(MacOSCheckContext(probe: _probe)),
          _ => <Finding>[],
        };
        sections.add(
          ValidationSection(title: _title(platform), findings: findings),
        );
        continue;
      } else if (ctx.declaredPlatforms.contains(platform)) {
        // Declared but excluded by --platform: skip silently.
        continue;
      } else if (_probe.dirExists(platform)) {
        sections.add(
          ValidationSection(
            title: _title(platform),
            findings: [
              Finding(
                id: 'P1',
                severity: Severity.notice,
                summary:
                    '${_title(platform)} project detected but not set up '
                    'for Patrol.',
                fix:
                    'Add `$platform:` under the `patrol:` section in '
                    'pubspec.yaml and re-run `patrol validate`.',
                docsUrl: '$docsBaseUrl#configure-pubspec',
              ),
            ],
          ),
        );
      }
    }

    return sections;
  }

  String _title(String platform) => switch (platform) {
    'android' => 'Android',
    'ios' => 'iOS',
    'macos' => 'macOS',
    _ => platform,
  };
}
