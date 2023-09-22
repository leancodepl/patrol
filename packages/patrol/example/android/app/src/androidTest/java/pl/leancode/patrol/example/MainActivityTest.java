package pl.leancode.patrol.example;

import android.util.Log;
import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.PatrolJUnitRunner;

import java.io.File;
import java.io.IOException;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    private void log(String text) {
        Log.d("MainActivity log", text);
    }

    @Test
    public void runDartTest() throws IOException {
        PatrolJUnitRunner instrumentation = (PatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();

// targetContext (app under test) data is cleared on each test run
//        File cacheDir = instrumentation.getTargetContext().getCacheDir();
//        File externalCacheDir = instrumentation.getTargetContext().getExternalCacheDir();

        File cacheDir = instrumentation.getContext().getCacheDir();
        boolean exists = cacheDir.exists();
        boolean created = cacheDir.mkdirs();
        log("cacheDir.mkdir(): exists=" + exists + ", created=" + created);

        log("cacheDir: " + cacheDir);

        File cacheDirFile = new File(cacheDir, "patrol.txt");
        created = cacheDirFile.createNewFile();
        log("cacheDirFile.createNewFile(): created=" + created);
//
//        File externalCacheDirFile = new File(externalCacheDir, "patrol.txt");
//        created = externalCacheDirFile.createNewFile();
//        log("externalCacheDirFile.createNewFile(): created=" + created);

        instrumentation.runDartTest(dartTestName);
    }
}
