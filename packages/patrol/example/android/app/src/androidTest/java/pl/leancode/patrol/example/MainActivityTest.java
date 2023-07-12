package pl.leancode.patrol.example;

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.BrowserstackPatrolJUnitRunner;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        BrowserstackPatrolJUnitRunner instrumentation = (BrowserstackPatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        BrowserstackPatrolJUnitRunner instrumentation = (BrowserstackPatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}
