package pl.leancode.patrol

import androidx.test.uiautomator.StaleObjectException

/** Reads every object from [query]. If any goes stale, re-runs [query] once and skips objects still stale. */
internal fun <T, R> readAllRetryingStale(
    query: () -> List<T>,
    read: (T) -> R,
    onRetry: (staleCount: Int) -> Unit = {},
    onSkipped: (staleCount: Int) -> Unit = {}
): List<R> {
    val (results, staleCount) = readAllSkippingStale(query(), read)
    if (staleCount == 0) {
        return results
    }

    onRetry(staleCount)
    val (retriedResults, stillStaleCount) = readAllSkippingStale(query(), read)
    if (stillStaleCount > 0) {
        onSkipped(stillStaleCount)
    }
    return retriedResults
}

private fun <T, R> readAllSkippingStale(objects: List<T>, read: (T) -> R): Pair<List<R>, Int> {
    val results = mutableListOf<R>()
    var staleCount = 0
    for (obj in objects) {
        try {
            results.add(read(obj))
        } catch (e: StaleObjectException) {
            staleCount++
        }
    }
    return results to staleCount
}
