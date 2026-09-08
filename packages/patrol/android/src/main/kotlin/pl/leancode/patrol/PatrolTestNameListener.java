package pl.leancode.patrol;

import org.junit.runner.Description;
import org.junit.runner.notification.RunListener;

/** Records the running test's JUnit class/method so native screenshots match what the farm reports. */
public final class PatrolTestNameListener extends RunListener {
    @Override
    public void testStarted(Description description) {
        Automator automator = Automator.Companion.getInstance();
        automator.setScreenshotClassName(description.getClassName());
        automator.setScreenshotMethodName(description.getMethodName());
    }
}
