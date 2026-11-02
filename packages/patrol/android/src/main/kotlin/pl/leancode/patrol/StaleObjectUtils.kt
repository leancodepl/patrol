package pl.leancode.patrol

import androidx.test.uiautomator.StaleObjectException

// Reads every object from [query]; if any goes stale, re-runs the query. The last attempt skips stale objects.
internal fun <T, R> readAllRetryingStale(
    query: () -> List<T>,
    read: (T) -> R,
    maxAttempts: Int = 2,
    log: (String) -> Unit = {}
): List<R> {
    require(maxAttempts >= 1) { "maxAttempts must be at least 1" }

    var attempt = 1
    while (true) {
        val results = mutableListOf<R>()
        var staleCount = 0
        for (obj in query()) {
            try {
                results.add(read(obj))
            } catch (e: StaleObjectException) {
                staleCount++
            }
        }

        if (staleCount == 0) {
            return results
        }
        if (attempt == maxAttempts) {
            log("Skipped $staleCount stale objects after $maxAttempts attempts")
            return results
        }
        log("$staleCount objects went stale, re-reading (attempt ${attempt + 1}/$maxAttempts)")
        attempt++
    }
}
