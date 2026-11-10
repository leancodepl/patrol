package pl.leancode.patrol

import androidx.test.uiautomator.StaleObjectException
import org.junit.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith

class StaleObjectUtilsTest {
    @Test
    fun `readAllRetryingStale() reads everything once when nothing is stale`() {
        var queries = 0

        val result = readAllRetryingStale(
            query = { queries++; listOf(1, 2, 3) },
            read = { it * 10 }
        )

        assertEquals(listOf(10, 20, 30), result)
        assertEquals(1, queries)
    }

    @Test
    fun `readAllRetryingStale() re-runs the query when an object goes stale`() {
        // first snapshot has a row that disappears mid-read, second one is consistent
        val snapshots = ArrayDeque(listOf(listOf("a", "gone", "b"), listOf("a", "b", "c")))
        val retries = mutableListOf<Int>()
        val skips = mutableListOf<Int>()

        val result = readAllRetryingStale(
            query = { snapshots.removeFirst() },
            read = { if (it == "gone") throw StaleObjectException() else it.uppercase() },
            onRetry = { retries.add(it) },
            onSkipped = { skips.add(it) }
        )

        assertEquals(listOf("A", "B", "C"), result)
        assertEquals(0, snapshots.size)
        assertEquals(listOf(1), retries)
        assertEquals(emptyList(), skips)
    }

    @Test
    fun `readAllRetryingStale() skips objects still stale after one retry`() {
        var queries = 0
        val skips = mutableListOf<Int>()

        val result = readAllRetryingStale(
            query = { queries++; listOf("a", "gone", "b") },
            read = { if (it == "gone") throw StaleObjectException() else it },
            onSkipped = { skips.add(it) }
        )

        assertEquals(listOf("a", "b"), result)
        assertEquals(2, queries)
        assertEquals(listOf(1), skips)
    }

    @Test
    fun `readAllRetryingStale() does not swallow other exceptions from read`() {
        assertFailsWith<IllegalStateException> {
            readAllRetryingStale(
                query = { listOf(1) },
                read = { throw IllegalStateException("boom") }
            )
        }
    }

    @Test
    fun `readAllRetryingStale() does not swallow exceptions from query`() {
        assertFailsWith<IllegalStateException> {
            readAllRetryingStale<Int, Int>(
                query = { throw IllegalStateException("boom") },
                read = { it }
            )
        }
    }
}
