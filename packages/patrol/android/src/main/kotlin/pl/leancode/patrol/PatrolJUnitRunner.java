// Terminology note:
// "Run a test" is used interchangeably with "execute a test".
// "Run a Dart test" is used interchangeably with "request execution of a Dart test" and "execute a Dart test".
// "ATO" is short for "Android Test Orchestrator".

package pl.leancode.patrol;

import static org.junit.Assume.*;

import android.app.Instrumentation;
import android.content.Intent;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnitRunner;

import pl.leancode.patrol.contracts.Contracts;
import pl.leancode.patrol.contracts.PatrolAppServiceClientException;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

import static pl.leancode.patrol.contracts.Contracts.DartGroupEntry;
import static pl.leancode.patrol.contracts.Contracts.RunDartTestResponse;

/**
 * <p>
 * A customized AndroidJUnitRunner that enables Patrol on Android.
 * </p>
 */
public class PatrolJUnitRunner extends AndroidJUnitRunner {
    public PatrolAppServiceClient patrolAppServiceClient;
    private Map<String, Boolean> dartTestCaseSkipMap = new HashMap<>();

    // Maps the reported JUnit name (possibly URL-safe) to the real Dart test
    // name used for execution. Identity mapping unless url-safe names are on.
    private final Map<String, String> reportedNameToDartName = new HashMap<>();

    // When true, reported JUnit names are sanitized to be URL-safe so screenshot
    // paths render on BrowserStack. The original name is kept for execution.
    private final boolean urlSafeTestNames = BuildConfig.PATROL_URL_SAFE_TEST_NAMES;

    @Override
    protected boolean shouldWaitForActivitiesToComplete() {
        return false;
    }

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);

        // This is only true when the ATO requests a list of tests from the app during the initial run.
        boolean isInitialRun = Boolean.parseBoolean(arguments.getString("listTestsForOrchestrator"));

        Logger.INSTANCE.i("--------------------------------");
        Logger.INSTANCE.i("PatrolJUnitRunner.onCreate() " + (isInitialRun ? "(initial run)" : ""));
    }

    @Override
    public void finish(int resultCode, Bundle results) {
        if (patrolAppServiceClient != null) {
            try {
                patrolAppServiceClient.close();
            } catch (Exception e) {
                Logger.INSTANCE.e("Failed to close PatrolAppServiceClient", e);
            }
        }
        super.finish(resultCode, results);
    }

    /**
     * <p>
     * The native test runner needs to know what tests exist before it can execute them.
     * To gather the tests, the native test runner (by default: AndroidJUnitRunner) runs
     * the instrumentation during the ATO's initial run and collects the tests.
     * </p>
     *
     * <p>
     * This default behavior doesn't work with Flutter apps. That's because in Flutter
     * apps, the tests are in the app itself, so running only the instrumentation
     * during the initial run is not enough.
     * The app must also be run, and queried for Dart tests.
     * That's what this method does.
     * </p>
     */
    public void setUp(Class<?> activityClass) {
        Logger.INSTANCE.i("PatrolJUnitRunner.setUp(): activityClass = " + activityClass.getCanonicalName());

        // This code launches the app under test. It's based on ActivityTestRule#launchActivity.
        // It's simpler because we don't have the need for that much synchronization.
        // Currently, the only synchronization point we're interested in is when the app under test returns the list of tests.
        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();

        // Record the JUnit test class so native screenshots are written to the
        // path BrowserStack scans: Downloads/screenshots/<className>/<methodName>/.
        Package activityPackage = activityClass.getPackage();
        String appPackage = activityPackage != null
                ? activityPackage.getName()
                : instrumentation.getTargetContext().getPackageName();
        Automator.Companion.getInstance().setTestClassName(appPackage + ".MainActivityTest");

        PatrolServer patrolServer = new PatrolServer();
        patrolServer.start(); // Gets killed when the instrumentation process dies. We're okay with this.



        // Try to get the launcher intent first, which handles activity aliases properly
        Intent intent = instrumentation.getTargetContext().getPackageManager()
                .getLaunchIntentForPackage(instrumentation.getTargetContext().getPackageName());
        
        if (intent == null) {
            // Fallback to the original approach if no launcher intent is found
            intent = new Intent(Intent.ACTION_MAIN);
            intent.setClassName(instrumentation.getTargetContext(), activityClass.getCanonicalName());
        }
        
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        instrumentation.getTargetContext().startActivity(intent);

        patrolAppServiceClient = createAppServiceClient();
    }

    public PatrolAppServiceClient createAppServiceClient() {
        return new PatrolAppServiceClient();
    }

    /**
     * <p>
     * Waits until PatrolAppService, running in the Dart side of the app, reports
     * that it's ready to be asked about the list of Dart tests.
     * </p>
     *
     * <p>
     * PatrolAppService becomes ready once the special Dart test named "patrol_test_explorer" finishes running.
     * </p>
     */
    public void waitForPatrolAppService() {
        final String TAG = "PatrolJUnitRunner.setUp(): ";

        Logger.INSTANCE.i(TAG + "Waiting for PatrolAppService to report its readiness...");
        PatrolServer.Companion.getAppReady().block();

        Logger.INSTANCE.i(TAG + "PatrolAppService is ready to report Dart tests");
    }

    public Object[] listDartTests() {
        final String TAG = "PatrolJUnitRunner.listDartTests(): ";

        try {
            final DartGroupEntry dartTestGroup = patrolAppServiceClient.listDartTests();
            List<DartGroupEntry> dartTestCases = ContractsExtensionsKt.listTestsFlat(dartTestGroup, "");
            List<String> dartTestCaseNamesList = new ArrayList<>();
            for (DartGroupEntry dartTestCase : dartTestCases) {
                final String dartTestName = dartTestCase.getName();
                dartTestCaseSkipMap.put(dartTestName, dartTestCase.getSkip());

                // The reported name equals the Dart name unless url-safe names
                // are on, in which case it is sanitized (de-duped on collision).
                String reportedName = dartTestName;
                if (urlSafeTestNames) {
                    final String base = toUrlSafe(dartTestName);
                    reportedName = base;
                    int suffix = 2;
                    while (reportedNameToDartName.containsKey(reportedName)) {
                        reportedName = base + "_" + suffix++;
                    }
                }
                reportedNameToDartName.put(reportedName, dartTestName);
                dartTestCaseNamesList.add(reportedName);
            }
            Object[] dartTestCaseNames = dartTestCaseNamesList.toArray();
            Logger.INSTANCE.i(TAG + "Got Dart tests: " + Arrays.toString(dartTestCaseNames));
            return dartTestCaseNames;
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + "Failed to list Dart tests: ", e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Requests execution of a Dart test and waits for it to finish.
     * Throws AssertionError if the test fails.
     */
    public RunDartTestResponse runDartTest(String name) {
        // `name` is the reported JUnit name; when url-safe names are enabled it
        // is the sanitized form, so map it back to the real Dart test name.
        String dartTestName = reportedNameToDartName.get(name);
        if (dartTestName == null) {
            dartTestName = name;
        }

        final String TAG = "PatrolJUnitRunner.runDartTest(" + dartTestName + "): ";

        // Expose the reported name so a Dart-triggered native screenshot names
        // its file to match the folder BrowserStack scans for this test.
        Automator.Companion.getInstance().setCurrentDartTestName(name);

        final Boolean skip = dartTestCaseSkipMap.get(dartTestName);
        if (skip) {
            Logger.INSTANCE.i(TAG + "Test skipped");
            assumeFalse(skip);
        }

        try {
            Logger.INSTANCE.i(TAG + "Requested execution");
            RunDartTestResponse response = patrolAppServiceClient.runDartTest(dartTestName);
            if (response.getResult() == Contracts.RunDartTestResponseResult.failure) {
                throw new AssertionError("Dart test failed: " + dartTestName + "\n" + response.getDetails());
            }
            Logger.INSTANCE.i(TAG + "Test execution succeeded");
            return response;
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + e.getMessage(), e.getCause());
            throw new RuntimeException(e);
        }
    }

    // Replaces characters outside [A-Za-z0-9._-] with '_' so the name is safe to
    // use in a screenshot path/URL. Only applied to the reported (JUnit) name.
    private static String toUrlSafe(String name) {
        return name.replaceAll("[^A-Za-z0-9._-]", "_");
    }
}
