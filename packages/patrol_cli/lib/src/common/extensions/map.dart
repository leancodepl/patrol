extension MapX<K, V> on Map<K, V?> {
  Map<K, V> withNullsRemoved() {
    return {
      for (final entry in entries)
        if (entry.value != null) entry.key: entry.value as V,
    };
  }
}
