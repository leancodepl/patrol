package pl.leancode.patrol.example;

import android.content.Intent;
import org.junit.Rule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;
import pl.leancode.patrol.Logger;
import pl.leancode.patrol.PatrolTestRule;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters
    public static Object[] testCases() {
        return new Object[]{"permissions_many_test.dart", "permissions_location_test.dart", "example_test.dart"};
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
        Logger.INSTANCE.i("Create MainActivityTest for Dart test: " + dartTestName);
        Intent intent = new Intent(Intent.ACTION_PICK);
        rule.launchActivity(intent);
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        Logger.INSTANCE.i("Test executed: " + dartTestName);
        // rule.getPatrolServer().Companion.getTestResults();
    }

    @Rule
    public PatrolTestRule<MainActivity> rule = new PatrolTestRule<>(MainActivity.class);
}
