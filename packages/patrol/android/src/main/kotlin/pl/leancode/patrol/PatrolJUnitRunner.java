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

import static pl.leancode.patrol.contracts.Contracts.RunDartTestResponse;

public class PatrolJUnitRunner extends AndroidJUnitRunner {
    private static PatrolAppServiceClient patrolAppServiceClient;

    @Override
    protected boolean shouldWaitForActivitiesToComplete() {
        return false;
    }

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);

        // We override onCreate(), because we need to gather the Dart tests before the tests are run.
        // By default, AndroidJUnitRunner doesn't run the app during the initial run (when it gathers the test list).
        // But in our case, the app must be run to gather the list of tests (because the tests (the Dart ones) live in the app itself).

        // This is only true when the Orchestrator requests a list of tests from the app during the initial run.
        String initialRun = arguments.getString("listTestsForOrchestrator");

        // This value comes from app's build.gradle. This is not ideal but works.
        String packageName = arguments.getString("packageName");

        Logger.INSTANCE.i("--------------------------------");
        Logger.INSTANCE.i("PatrolJUnitRunner.onCreate(), " + "packageName: " + packageName + (Objects.equals(initialRun, "true") ? " (initial run)" : ""));

        // This code is based on ActivityTestRule#launchActivity.
        // It's simpler because we don't feel the need for that much synchronization as in ActivityTestRule.
        // Currently, the only synchronization point we're interested in is when the app under test returns the list of tests.
        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
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

    public static RunDartTestResponse runDartTest(String name) {
        Logger.INSTANCE.i("PatrolJUnitRunner.runDartTest(" + name + ")");
        try {
            RunDartTestResponse response = patrolAppServiceClient.runDartTest(name);
            if (response.getResult() == RunDartTestResponse.Result.FAILURE) {
                throw new AssertionError("Dart test failed: " + name);
            }
            return response;
        } catch (StatusRuntimeException e) {
            Logger.INSTANCE.e("Failed to run Dart test: " + e.getMessage(), e.getCause());
            throw e;
        }
    }
}
