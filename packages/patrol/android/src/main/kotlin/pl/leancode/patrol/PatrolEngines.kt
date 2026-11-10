package pl.leancode.patrol

import java.util.concurrent.TimeUnit
import java.util.concurrent.locks.ReentrantLock
import kotlin.concurrent.withLock

/**
 * Tracks the Flutter engines of the app under test that reported their readiness.
 *
 * Every engine reports once, when its PatrolAppService starts. A report during a test
 * means the app started a new engine, usually because Android recreated the activity.
 */
object PatrolEngines {
    private val lock = ReentrantLock()
    private val changed = lock.newCondition()

    /** How many engines reported their readiness so far. */
    @Volatile
    @JvmStatic
    var generation: Int = 0
        private set

    /**
     * The port PatrolAppService listens on in the engine that reported last, or null if the
     * engine did not report one.
     */
    @Volatile
    @JvmStatic
    var appServicePort: Int? = null
        private set

    /** Records the readiness report of a new engine and wakes up the threads in [await]. */
    @JvmStatic
    fun onEngineReady(port: Int?) = lock.withLock {
        appServicePort = port
        generation++
        changed.signalAll()
    }

    /** Wakes up the threads in [await], so that they check their `done` condition again. */
    @JvmStatic
    fun wakeUp() = lock.withLock {
        changed.signalAll()
    }

    /**
     * Waits until an engine newer than [knownGeneration] reports, [done] returns true, or
     * [timeoutMillis] passes.
     *
     * @return the current generation.
     */
    @JvmStatic
    fun await(knownGeneration: Int, timeoutMillis: Long, done: () -> Boolean): Int = lock.withLock {
        var nanos = TimeUnit.MILLISECONDS.toNanos(timeoutMillis)
        while (generation == knownGeneration && !done() && nanos > 0) {
            nanos = changed.awaitNanos(nanos)
        }
        generation
    }
}
