package pl.leancode.patrol;

import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnitRunner;
import io.grpc.StatusRuntimeException;
import pl.leancode.patrol.contracts.Contracts.DartTestGroup;

import java.util.Objects;
import java.util.concurrent.ExecutionException;

public class PatrolJUnitRunner extends AndroidJUnitRunner {
    private static PatrolAppServiceClient patrolAppServiceClient;

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);

        // We override onCreate(), because we need to gather the Dart tests before the tests are run.


        // This is only true when the Orchestrator requests a list of tests from the app during the initial run.
        String initialRun = arguments.getString("listTestsForOrchestrator");
        Logger.INSTANCE.i("--------------------------------");
        Logger.INSTANCE.i("PatrolJUnitRunner.onCreate()" + (Objects.equals(initialRun, "true") ? "initial run" : ""));

        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();

        // This is defined in the "patrol" section in pubspec.yaml
        String packageName = InstrumentationRegistry.getArguments().getString("PATROL_APP_PACKAGE_NAME"); // TODO: applicationID != package name, will break when using flavors
        Logger.INSTANCE.i("PatrolJUnitRunner.onCreate(): packageName: " + packageName);

        // This code is based on ActivityTestRule#launchActivity.
        // It's simpler because we don't feel the need for that much synchronization as in ActivityTestRule.
        // Currently, the only synchronization point we're interested in is when the app under test returns the list of tests.
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setClassName(instrumentation.getTargetContext(), packageName + ".MainActivity"); // TODO: Some users may want to customize it
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        instrumentation.getContext().startActivity(intent);

        // PatrolServer starts the NativeAutomator service
        PatrolServer patrolServer = new PatrolServer();
        patrolServer.start(); // It will be killed once the test finishes, and for now, we're okay with this

        patrolAppServiceClient = new PatrolAppServiceClient();
    }

    /// Sets PatrolJUnitRunner.dartTestGroup if this is the initial test run.
    public static DartTestGroup setUp() {
        Logger.INSTANCE.i("PatrolJUnitRunner.setUp(): waiting for PatrolAppService to report its readiness...");
        try {
            PatrolServer.Companion.getAppReadyFuture().get();
        } catch (InterruptedException | ExecutionException e) {
            Logger.INSTANCE.e("Exception was thrown when waiting for appReady: ", e);
            throw new RuntimeException(e);
        }

        Logger.INSTANCE.i("PatrolJUnitRunner.setUp(): PatrolAppService is ready, will ask it for Dart tests...");


        try {
            return patrolAppServiceClient.listDartTests();
        } catch (StatusRuntimeException e) {
            Logger.INSTANCE.e("PatrolJUnitRunner.setUp(): failed to list dart tests");
            throw e;
        }
    }

    public static void runDartTest(String name) {
        Logger.INSTANCE.i("PatrolJUnitRunner.runDartTest(" + name + ")");
        try {
            patrolAppServiceClient.runDartTest(name);
        } catch (StatusRuntimeException e) {
            Logger.INSTANCE.e("Failed to run Dart test: " + e.getMessage(), e.getCause());
            throw e;
        }
    }
}
