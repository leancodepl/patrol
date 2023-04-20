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
        boolean isInitialRun = PatrolJUnitRunner.setUpIfNecessary();

        Logger.INSTANCE.i("Test cases requested, value from app: " + PatrolJUnitRunner.valueFromApp);
        Logger.INSTANCE.i("Got DartTestGroup: " + PatrolJUnitRunner.dartTestGroup);

        Object[] dartTestFiles = ContractsExtensionsKt.listFlatDartFiles(PatrolJUnitRunner.dartTestGroup).toArray();
        Logger.INSTANCE.i("Got Dart test files: " + Arrays.toString(dartTestFiles));

        if (!isInitialRun) {
            return new Object[]{"huh why is it not appearing"};
        }

        return dartTestFiles;

        // return new Object[]{"my_test_1.dart", "my_test_2.dart", "my_test_3.dart"};
        // return new Object[]{"permissions_many_test.dart", "permissions_location_test.dart", "example_test.dart"};
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        Logger.INSTANCE.i("Test executed: " + dartTestName);
        // PatrolAppService.startDartTest(dartTestName)

        if (dartTestName.equals("my_test_2.dart")) {
            // Demo to show that time is reported correctly in test results
            SystemClock.sleep(3 * 1000);
        }

        // PatrolAppService.getDartTestResults()
    }
}