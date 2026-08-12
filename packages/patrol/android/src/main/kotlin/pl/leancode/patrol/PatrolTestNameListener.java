package pl.leancode.patrol;

import org.junit.runner.Description;
import org.junit.runner.notification.RunListener;

/**
 * Records the currently running JUnit test's class and method names so native
 * screenshots (see {@link Automator}) can be written to the folder a device
 * farm scans for that test.
 *
 * <p>
 * Reading the identity straight from the test's {@link Description} means it
 * matches what the farm reports for both the parameterized host class
 * (`MainActivityTest#runDartTest[...]`) and the statically generated class from
 * build-time discovery (`PatrolGeneratedTests#test_...`), with no reconstruction.
 * </p>
 */
public final class PatrolTestNameListener extends RunListener {
    @Override
    public void testStarted(Description description) {
        Automator automator = Automator.Companion.getInstance();
        automator.setScreenshotClassName(description.getClassName());
        automator.setScreenshotMethodName(description.getMethodName());
    }
}
