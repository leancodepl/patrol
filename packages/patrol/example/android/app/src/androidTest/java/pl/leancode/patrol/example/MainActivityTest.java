package pl.leancode.patrol.example;

import android.os.SystemClock;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.ContractsExtensionsKt;
import pl.leancode.patrol.Logger;
import pl.leancode.patrol.PatrolJUnitRunner;

import java.util.Arrays;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolJUnitRunner.setUp();

//        Logger.INSTANCE.i("Test cases requested, value from app: " + PatrolJUnitRunner.valueFromApp);
//        Logger.INSTANCE.i("Got DartTestGroup: " + PatrolJUnitRunner.dartTestGroup);

        Object[] dartTestFiles = ContractsExtensionsKt.listFlatDartFiles(PatrolJUnitRunner.dartTestGroup).toArray();
        Logger.INSTANCE.i("Got Dart test files: " + Arrays.toString(dartTestFiles));
        return dartTestFiles;
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        Logger.INSTANCE.i("MainActivityTest.runDartTest(): " + dartTestName);
        PatrolJUnitRunner.runDartTest(dartTestName);

        if (dartTestName.equals("permissions_test.dart")) {
            // Demo to show that time is reported correctly in test results

            SystemClock.sleep(3 * 1000);
        }

        // PatrolAppService.getDartTestResults()
    }
}