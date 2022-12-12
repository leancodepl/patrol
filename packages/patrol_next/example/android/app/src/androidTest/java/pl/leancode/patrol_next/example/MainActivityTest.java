package pl.leancode.patrol_next.example;

import org.junit.Rule;
import org.junit.rules.TestRule;
import org.junit.runner.RunWith;

import dev.flutter.plugins.integration_test.FlutterTestRunner;
import pl.leancode.patrol_next.PatrolTestRule;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {

    @Rule
    public TestRule rule = new PatrolTestRule<>(MainActivity.class);
}
