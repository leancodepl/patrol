extension MapX<K, V> on Map<K, V?> {
  Map<K, V> withNullsRemoved() {
    return {
      for (final entry in entries)
        if (entry.value != null) entry.key: entry.value as V,
    };
  }
}

extension StringX on String {
  /// Adapted from https://stackoverflow.com/a/60404614/7009800
  List<String> splitFirst(String sep) {
    final index = indexOf(sep);
    final parts = [substring(0, index).trim(), substring(index + 1).trim()];

    return parts;
  }
}
