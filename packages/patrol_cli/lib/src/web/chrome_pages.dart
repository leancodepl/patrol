/// The page among Chrome's DevTools Protocol [targets] (the `/json` listing)
/// whose id is [id], or the first page when none is.
Map<String, dynamic>? pickChromePage(List<Object?> targets, {String? id}) {
  final pages = targets.whereType<Map<String, dynamic>>().where(
    (target) => target['type'] == 'page',
  );
  return pages.where((page) => id != null && page['id'] == id).firstOrNull ??
      pages.firstOrNull;
}
