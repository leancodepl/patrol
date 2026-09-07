/// Whether a BrowserStack Espresso build (the `GET /builds/{id}` JSON) ran with
/// `clearPackageData` on. Returns null when the response doesn't echo it.
///
/// Coverage and `clearPackageData:true` are mutually exclusive on BrowserStack:
/// `pm clear` between orchestrator-driven tests revokes the app's permission to
/// write the shared coverage file, so only the first test's coverage survives.
/// `patrol bs pull-coverage` fails fast rather than hand back that result.
bool? buildUsedClearPackageData(Map<String, dynamic> build) {
  final caps = build['input_capabilities'];
  if (caps is! Map<String, dynamic>) {
    return null;
  }
  final value = caps['clearPackageData'];
  if (value is bool) {
    return value;
  }
  if (value is String) {
    return value.toLowerCase() == 'true';
  }
  return null;
}
