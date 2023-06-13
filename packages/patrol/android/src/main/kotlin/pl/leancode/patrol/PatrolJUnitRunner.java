// Terminology note:
// "Run a test" is used interchangeably with "execute a test".
// "Run a Dart test" is used interchangeably with "request execution of a Dart test" and "execute Dart test".

package pl.leancode.patrol;

import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnitRunner;
import io.grpc.StatusRuntimeException;
import pl.leancode.patrol.contracts.Contracts.DartTestGroup;

import java.util.Arrays;
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

        // We need to know what Dart tests exist before we can request their execution.
        // To gather the Dart tests, we need to run the app during the Orchestrator's initial run.
        // But by default, AndroidJUnitRunner doesn't run the app during the initial run, when it gathers the tests to execute.
        // That's why we override this onCreate().

        // This is only true when the Orchestrator requests a list of tests from the app during the initial run.
        String initialRun = arguments.getString("listTestsForOrchestrator");

        // This value comes from app's build.gradle. This is not ideal but works.
        String packageName = arguments.getString("packageName");

        Logger.INSTANCE.i("--------------------------------");
        Logger.INSTANCE.i("PatrolJUnitRunner.onCreate(), " + "packageName: " + packageName + (Objects.equals(initialRun, "true") ? " (initial run)" : ""));

        // This code is based on ActivityTestRule#launchActivity.
        // It's simpler because we don't have the need for that much synchronization.
        // Currently, the only synchronization point we're interested in is when the app under test returns the list of tests.
        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.setClassName(instrumentation.getTargetContext(), packageName + ".MainActivity"); // TODO: Some users may want to customize it
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        instrumentation.getContext().startActivity(intent);

        PatrolServer patrolServer = new PatrolServer();
        patrolServer.start(); // Gets killed when the instrumentation process dies. We're okay with this.

        patrolAppServiceClient = new PatrolAppServiceClient();
    }

    /**
     * <p>
     * Waits until PatrolAppService, running in the Dart side of the app, reports that it's ready to be asked about
     * the list of Dart tests.
     * </p>
     *
     * <p>
     * PatrolAppService becomes ready once the Dart test "patrol_test_explorer" finishes running.
     * </p>
     */
    public static void waitForPatrolAppService() {
        final String TAG = "PatrolJUnitRunner.setUp(): ";

        try {
            Logger.INSTANCE.i(TAG + "Waiting for PatrolAppService to report its readiness...");
            PatrolServer.Companion.getAppReadyFuture().get();
        } catch (InterruptedException | ExecutionException e) {
            Logger.INSTANCE.e(TAG + "Exception was thrown when waiting for appReady: ", e);
            throw new RuntimeException(e);
        }

        Logger.INSTANCE.i(TAG + "PatrolAppService is ready to report Dart tests");
    }

    public static Object[] listDartTests() {
        final String TAG = "PatrolJUnitRunner.listDartTests(): ";

        try {
            final DartTestGroup dartTestGroup = patrolAppServiceClient.listDartTests();
            Object[] dartTestFiles = ContractsExtensionsKt.listFlatDartFiles(dartTestGroup).toArray();
            Logger.INSTANCE.i(TAG + "Got Dart tests: " + Arrays.toString(dartTestFiles));
            return dartTestFiles;
        } catch (StatusRuntimeException e) {
            Logger.INSTANCE.e(TAG + "Failed to list Dart tests: ", e);
            throw e;
        }
    }

    /**
     * Requests execution of a Dart test and waits for it to finish.
     * Throws AssertionError if the test fails.
     */
    public static RunDartTestResponse runDartTest(String name) {
        final String TAG = "PatrolJUnitRunner.runDartTest(" + name + "): ";

        try {
            Logger.INSTANCE.i(TAG + "Requested execution");
            RunDartTestResponse response = patrolAppServiceClient.runDartTest(name);
            if (response.getResult() == RunDartTestResponse.Result.FAILURE) {
                throw new AssertionError("Dart test failed: " + name + "\n" + response.getDetails());
            }
            return response;
        } catch (StatusRuntimeException e) {
            Logger.INSTANCE.e(TAG + e.getMessage(), e.getCause());
            throw e;
        }
    }
}
