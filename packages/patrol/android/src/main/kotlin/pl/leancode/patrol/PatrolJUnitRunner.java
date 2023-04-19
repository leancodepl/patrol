package pl.leancode.patrol;

import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnitRunner;

public class PatrolJUnitRunner extends AndroidJUnitRunner {
    public static String valueFromApp;

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);

        // This is a demo showing how arguments can be passed from Gradle
        String exampleArg = arguments.getString("exampleArg");

        // This is only true when the Orchestrator requests a list of tests from the app during the initial run.
        String listTestsForOrchestrator = arguments.getString("listTestsForOrchestrator");
        Logger.INSTANCE.i("PatrolJUnitRunner onCreate, exampleArg: " + exampleArg + ", listTestsForOrchestrator: " + listTestsForOrchestrator);

        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();

        // This code is based on ActivityTestRule#launchActivity.
        // It's simpler because we don't feel the need for that much synchronization as in ActivityTestRule.
        // Currently, the only synchronization point we're interested in is when the app under test returns the list of tests.
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setClassName(instrumentation.getTargetContext(), "pl.leancode.patrol.example.MainActivity"); // FIXME: hardcoded package name
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        instrumentation.getContext().startActivity(intent);

        valueFromApp = "hello! this is from app";
    }
}
