package pl.leancode.patrol.e2e_app;

import static org.junit.Assume.*;

import java.util.Collection;

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameter;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolJUnitRunner;


@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters 
    public static Collection<Object[]> testCases() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName, Boolean skip) {
        this.dartTestName = dartTestName;
        this.skip = skip;
    }

    private String dartTestName;

    private Boolean skip;

    @Test
    public void runDartTest() {
        assumeFalse(skip);

        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }
}
