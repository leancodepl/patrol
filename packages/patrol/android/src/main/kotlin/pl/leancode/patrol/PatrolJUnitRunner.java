package pl.leancode.patrol;

import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnitRunner;

public class PatrolJUnitRunner extends AndroidJUnitRunner {
    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);
        String exampleArg = arguments.getString("exampleArg");

        // This argument is true only when the Orchestrator requests a list of tests from the app under test
        String listTestsForOrchestrator = arguments.getString("listTestsForOrchestrator");
        Logger.INSTANCE.i("PatrolJUnitRunner onCreate, exampleArg: " + exampleArg + ", listTestsForOrchestrator: " + listTestsForOrchestrator);

        //if (listTestsForOrchestrator) {
        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();

        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setClassName(instrumentation.getTargetContext(), "pl.leancode.patrol.example.MainActivity"); // FIXME: hardcoded package name
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        instrumentation.getContext().startActivity(intent);
        //instrumentation.sta(intent);
        //}

    }
}
