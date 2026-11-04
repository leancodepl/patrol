/// Whether a BrowserStack Espresso build (the `GET /builds/{id}` JSON) ran with
/// `clearPackageData` on. Returns null when the response doesn't echo it.
///
/// With `clearPackageData:true` the runner appends each test's coverage as the
/// shell user (Android 12+); `patrol coverage pull` only logs that mode.
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
