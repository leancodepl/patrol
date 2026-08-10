import 'package:equatable/equatable.dart';

/// How a [Finding] affects the outcome of `patrol validate`.
enum Severity {
  /// A doc-required setup step is definitively missing. Fails the command.
  error,

  /// Likely wrong, but the probe can be mistaken. Never affects exit code.
  warning,

  /// Informational: unverifiable steps, undeclared platforms, minor advice.
  notice,
}

/// A single result of an unsatisfied (or unverifiable) setup check.
class Finding with Equatable {
  const Finding({
    required this.id,
    required this.severity,
    required this.summary,
    this.fix,
    this.docsUrl,
  });

  /// Check identifier, e.g. `S3` (shared), `A1` (Android), `E1` (environment).
  final String id;

  final Severity severity;

  /// What is wrong, in one sentence.
  final String summary;

  /// How to fix it, in one short instruction.
  final String? fix;

  /// Deep link to the docs section that covers this step.
  final String? docsUrl;

  @override
  List<Object?> get props => [id, severity, summary, fix, docsUrl];
}
