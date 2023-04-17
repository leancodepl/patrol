package pl.leancode.patrol

import android.util.Log
import androidx.test.rule.ActivityTestRule
import org.junit.Rule
import org.junit.rules.TestRule
import org.junit.runner.Description
import org.junit.runner.Runner
import org.junit.runner.notification.RunNotifier
import pl.leancode.patrol.contracts.Contracts.DartTestCase
import pl.leancode.patrol.contracts.Contracts.DartTestGroup

class PatrolTestRunner(private val testClass: Class<*>) : Runner() {
    private val tag = "PatrolTestRunner"

    private val description = Description.createTestDescription(testClass, "Flutter Patrol Tests")

    private lateinit var rule: TestRule

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

    override fun getDescription(): Description = description

    override fun run(notifier: RunNotifier) {
        try {
            if (rule is PatrolTestRule<*>) {
                (rule as PatrolTestRule<*>).launchActivity(null)
            }
        } catch (e: RuntimeException) {
            Log.v(tag, "launchActivity failed, possibly because the activity was already running. $e")
        }

        val dartTestGroup = PatrolServer.dartTestGroup.get() // Might throw, but we don't know what to do with it yet

        notifier.createVirtualTests(dartTestGroup) // Does nothing yet
        notifier.createDescription(dartTestGroup, description)


        Logger.i("Waiting for Dart tests results...")
        PatrolServer.testResults.get() // Wait until tests finish, ignore results (always success)
        Logger.i("Dart tests finished")

        // for (name in tests.keys) {
        //     val d = Description.createTestDescription(testClass, name)
        //     notifier.fireTestStarted(d)
        //     val outcome = tests[name]
        //     if (outcome != "success") {
        //         val dummyException = Exception(outcome)
        //         notifier.fireTestFailure(Failure(d, dummyException))
        //     }
        //     notifier.fireTestFinished(d)
        // }
    }
}

fun RunNotifier.createDescription(group: DartTestGroup, parentDescription: Description, level: Int = 0) {
    val groupName = group.name.ifEmpty { "root" }

    Logger.i("${" ".repeat(level * 2)}Created new group \"$groupName\"")
    val description = Description.createSuiteDescription(groupName)
    parentDescription.addChild(description)
    // Logger.i("Added new group ${group.name} to parent group ${parentDescription}")

    fireTestStarted(description)

    group.groupsList.forEach { createDescription(group = it, parentDescription = description, level = level + 1) }
    group.testsList.forEach { createDescription(test = it, parentDescription = description, level = level + 1) }
    fireTestFinished(description)
}

fun RunNotifier.createDescription(test: DartTestCase, parentDescription: Description, level: Int = 0) {
    Logger.i("${" ".repeat(level * 2)}Created new test \"${test.name}\"")
    val testDescription = Description.createTestDescription(test.name, test.name)
    parentDescription.addChild(parentDescription)
    // Logger.i("Added new test ${test.name} to parent group $parentDescription")

    fireTestStarted(testDescription)
    fireTestFinished(testDescription)
}

fun RunNotifier.createVirtualTests(topLevelGroup: DartTestGroup) {
    // TODO: Extend from Parametrized instead of Runner and create parametrized tests
}