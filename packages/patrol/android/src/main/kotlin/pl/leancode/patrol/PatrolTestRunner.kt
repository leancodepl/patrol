package pl.leancode.patrol

import android.util.Log
import androidx.test.rule.ActivityTestRule
import org.junit.Rule
import org.junit.rules.TestRule
import org.junit.runner.Description
import org.junit.runner.notification.Failure
import org.junit.runner.notification.RunNotifier
import java.util.concurrent.ExecutionException

class PatrolTestRunner(private val testClass: Class<*>) {
    private val tag = "PatrolTestRunner"

    var rule: TestRule? = null

    init {
        // Look for an `ActivityTestRule` annotated `@Rule` and invoke `launchActivity()`
        val fields = testClass.declaredFields
        for (field in fields) {
            if (field.isAnnotationPresent(Rule::class.java)) {
                try {
                    val instance = testClass.newInstance()
                    if (field[instance] is ActivityTestRule<*>) {
                        rule = field[instance] as TestRule
                        break
                    }
                } catch (e: InstantiationException) {
                    // This might occur if the developer did not make the rule public.
                    // We could call field.setAccessible(true) but it seems better to throw.
                    throw RuntimeException("Unable to access activity rule", e)
                } catch (e: IllegalAccessException) {
                    throw RuntimeException("Unable to access activity rule", e)
                }
            }
        }
    }

    override fun getDescription(): Description? {
        return Description.createTestDescription(testClass, "Flutter Patrol Tests")
    }

    override fun run(notifier: RunNotifier) {
        if (rule == null) {
            throw RuntimeException("Unable to run tests due to missing activity rule")
        }

        try {
            if (rule is PatrolTestRule<*>) {
                (rule as PatrolTestRule<*>).launchActivity(null)
            }
        } catch (e: RuntimeException) {
            Log.v(tag, "launchActivity failed, possibly because the activity was already running. $e")
            Log.v(
                tag,
                "Try disabling auto-launch of the activity, e.g. ActivityTestRule<>(MainActivity.class, true, false);"
            )
        }

        var results: Map<String, String>? = null
        results = try {
            // IntegrationTestPlugin.testResults.get()
            // Start from here:
            PatrolServer.testResults
        } catch (e: ExecutionException) {
            throw IllegalThreadStateException("Unable to get test results")
        } catch (e: InterruptedException) {
            throw IllegalThreadStateException("Unable to get test results")
        }
        for (name in results.keys) {
            val d = Description.createTestDescription(testClass, name)
            notifier.fireTestStarted(d)
            val outcome = results.get(name)
            if (outcome != "success") {
                val dummyException = Exception(outcome)
                notifier.fireTestFailure(Failure(d, dummyException))
            }
            notifier.fireTestFinished(d)
        }
    }
}
