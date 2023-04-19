package pl.leancode.patrol.example;

import android.os.SystemClock;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.Logger;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        return new Object[]{"my_test_1.dart", "my_test_2.dart", "my_test_3.dart"};
        // return new Object[]{"permissions_many_test.dart", "permissions_location_test.dart", "example_test.dart"};
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
// Commented out because PatrolJUnitRunner does this now
//        Logger.INSTANCE.i("Create MainActivityTest for Dart test: " + dartTestName);
//        Intent intent = new Intent(Intent.ACTION_PICK);
//        rule.launchActivity(intent);
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        Logger.INSTANCE.i("Test executed: " + dartTestName);
        // rule.getPatrolServer().Companion.getTestResults();

        if (dartTestName.equals("permissions_location_test.dart")) {
            // Demo to show that time is reported correctly in test results
            SystemClock.sleep(5 * 1000);
        }
    }

// Commented out because PatrolJUnitRunner does this now
//    @Rule
//    public PatrolTestRule<MainActivity> rule = new PatrolTestRule<>(MainActivity.class);
}
