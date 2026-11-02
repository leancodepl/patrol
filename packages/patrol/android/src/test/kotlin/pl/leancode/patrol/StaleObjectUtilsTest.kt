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

        val result = readAllRetryingStale(
            query = { snapshots.removeFirst() },
            read = { if (it == "gone") throw StaleObjectException() else it.uppercase() }
        )

        assertEquals(listOf("A", "B", "C"), result)
        assertEquals(0, snapshots.size)
    }

    @Test
    fun `readAllRetryingStale() skips stale objects after the last attempt`() {
        var queries = 0
        val logs = mutableListOf<String>()

        val result = readAllRetryingStale(
            query = { queries++; listOf("a", "gone", "b") },
            read = { if (it == "gone") throw StaleObjectException() else it },
            maxAttempts = 3,
            log = { logs.add(it) }
        )

        assertEquals(listOf("a", "b"), result)
        assertEquals(3, queries)
        assertEquals("Skipped 1 stale objects after 3 attempts", logs.last())
    }

    @Test
    fun `readAllRetryingStale() does not swallow other exceptions`() {
        assertFailsWith<IllegalStateException> {
            readAllRetryingStale(
                query = { listOf(1) },
                read = { throw IllegalStateException("boom") }
            )
        }
    }
}
