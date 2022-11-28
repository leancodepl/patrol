package pl.leancode.patrol.example;

import org.junit.Rule;
import org.junit.rules.TestRule;
import org.junit.runner.RunWith;

import dev.flutter.plugins.integration_test.FlutterTestRunner;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {

    @Rule
    public TestRule rule = new PatrolTestRule();
}
