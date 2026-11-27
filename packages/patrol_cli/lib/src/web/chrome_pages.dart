/// The pages among Chrome's DevTools Protocol [targets] (the `/json` listing).
List<Map<String, dynamic>> chromePages(List<Object?> targets) => targets
    .whereType<Map<String, dynamic>>()
    .where((target) => target['type'] == 'page')
    .toList();

/// The page among Chrome's DevTools Protocol [targets] (the `/json` listing)
/// whose id is [id], or the first page when none is.
Map<String, dynamic>? pickChromePage(List<Object?> targets, {String? id}) {
  final pages = chromePages(targets);
  return pages.where((page) => id != null && page['id'] == id).firstOrNull ??
      pages.firstOrNull;
}

/// The page among [targets] that is in front, the only one [visibleIds] names.
/// When no page or more than one is visible, [pickChromePage] chooses with
/// [fallbackId].
Map<String, dynamic>? pickFrontPage(
  List<Object?> targets, {
  required Set<String> visibleIds,
  String? fallbackId,
}) {
  final visible = chromePages(
    targets,
  ).where((page) => visibleIds.contains(page['id'])).toList();
  return visible.length == 1
      ? visible.single
      : pickChromePage(targets, id: fallbackId);
}
