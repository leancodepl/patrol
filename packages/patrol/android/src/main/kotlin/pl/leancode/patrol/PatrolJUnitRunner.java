// Terminology note:
// "Run a test" is used interchangeably with "execute a test".
// "Run a Dart test" is used interchangeably with "request execution of a Dart test" and "execute a Dart test".
// "ATO" is short for "Android Test Orchestrator".

package pl.leancode.patrol;

import android.annotation.SuppressLint;
import android.app.Instrumentation;
import android.content.ContentResolver;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.runner.AndroidJUnitRunner;
import androidx.test.services.storage.file.HostedFile;
import androidx.test.services.storage.internal.TestStorageUtil;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import pl.leancode.patrol.contracts.Contracts;
import pl.leancode.patrol.contracts.Contracts.ListDartLifecycleCallbacksResponse;
import pl.leancode.patrol.contracts.PatrolAppServiceClientException;

import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;

import static pl.leancode.patrol.contracts.Contracts.DartGroupEntry;
import static pl.leancode.patrol.contracts.Contracts.RunDartTestResponse;

/**
 * <p>
 * A customized AndroidJUnitRunner that enables Patrol on Android.
 * </p>
 */
@SuppressLint({"UnsafeOptInUsageError", "RestrictedApi"})
public class PatrolJUnitRunner extends AndroidJUnitRunner {
    public PatrolAppServiceClient patrolAppServiceClient;

    /**
     * <p>
     * Available only after onCreate() has been run.
     * </p>
     */
    protected boolean isInitialRun;

    private ContentResolver getContentResolver() {
        return InstrumentationRegistry.getInstrumentation().getTargetContext().getContentResolver();
    }

    private Uri stateFileUri = HostedFile.buildUri(
            HostedFile.FileHost.OUTPUT,
            "patrol_callbacks.json"
    );

    public boolean isInitialRun() {
        return isInitialRun;
    }

    @Override
    protected boolean shouldWaitForActivitiesToComplete() {
        return false;
    }

    @Override
    public void onCreate(Bundle arguments) {
        super.onCreate(arguments);

        // This is only true when the ATO requests a list of tests from the app during the initial run.
        this.isInitialRun = Boolean.parseBoolean(arguments.getString("listTestsForOrchestrator"));

        Logger.INSTANCE.i("--------------------------------");
        Logger.INSTANCE.i("PatrolJUnitRunner.onCreate() " + (this.isInitialRun ? "(initial run)" : ""));
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
        Intent intent = new Intent(Intent.ACTION_MAIN);
        intent.putExtra("isInitialRun", isInitialRun);
        intent.setClassName(instrumentation.getTargetContext(), activityClass.getCanonicalName());
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        instrumentation.getTargetContext().startActivity(intent);

        PatrolServer patrolServer = new PatrolServer();
        patrolServer.start(); // Gets killed when the instrumentation process dies. We're okay with this.

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
        final String TAG = "PatrolJUnitRunner.waitForPatrolAppService(): ";

        Logger.INSTANCE.i(TAG + "Waiting for PatrolAppService to report its readiness...");
        PatrolServer.Companion.getAppReady().block();

        Logger.INSTANCE.i(TAG + "PatrolAppService is ready to report Dart tests");
    }

    public Object[] listDartTests() {
        final String TAG = "PatrolJUnitRunner.listDartTests(): ";

        // This call should be in MainActivityTest.java, but that would require
        // users to change that file in their projects, thus breaking backward
        // compatibility.
        handleLifecycleCallbacks();

        try {
            final DartGroupEntry dartTestGroup = patrolAppServiceClient.listDartTests();
            List<DartGroupEntry> dartTestCases = ContractsExtensionsKt.listTestsFlat(dartTestGroup, "");
            List<String> dartTestCaseNamesList = new ArrayList<>();
            for (DartGroupEntry dartTestCase : dartTestCases) {
                dartTestCaseNamesList.add(dartTestCase.getName());
            }
            Object[] dartTestCaseNames = dartTestCaseNamesList.toArray();
            Logger.INSTANCE.i(TAG + "Got Dart tests: " + Arrays.toString(dartTestCaseNames));
            return dartTestCaseNames;
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + "Failed to list Dart tests: ", e);
            throw new RuntimeException(e);
        }
    }

    private void handleLifecycleCallbacks() {
        if (isInitialRun()) {
            Object[] lifecycleCallbacks = listLifecycleCallbacks();
            saveLifecycleCallbacks(lifecycleCallbacks);
        } else {
            setLifecycleCallbacksState();
        }
    }

    public Object[] listLifecycleCallbacks() {
        final String TAG = "PatrolJUnitRunner.listLifecycleCallbacks(): ";

        try {
            final ListDartLifecycleCallbacksResponse response = patrolAppServiceClient.listDartLifecycleCallbacks();
            final List<String> setUpAlls = response.getSetUpAlls();
            Logger.INSTANCE.i(TAG + "Got Dart lifecycle callbacks: " + setUpAlls);

            return setUpAlls.toArray();
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + "Failed to list Dart lifecycle callbacks: ", e);
            throw new RuntimeException(e);
        }
    }

    public void saveLifecycleCallbacks(Object[] callbacks) {
        Map<String, Boolean> callbackMap = new HashMap<>();
        for (Object callback : callbacks) {
            callbackMap.put((String) callback, false);
        }

        writeStateFile(callbackMap);
    }

    public void markLifecycleCallbackExecuted(String name) {
        Logger.INSTANCE.i("PatrolJUnitRunnerMarking.markLifecycleCallbackExecuted(" + name + ")");
        Map<String, Boolean> state = readStateFile();
        state.put(name, true);
        writeStateFile(state);
    }

    private Map<String, Boolean> readStateFile() {
        try {
            InputStream inputStream = TestStorageUtil.getInputStream(stateFileUri, getContentResolver());
            String content = convertStreamToString(inputStream);
            Gson gson = new Gson();
            Type typeOfHashMap = new TypeToken<Map<String, String>>() {}.getType();
            Map<String, Boolean> data = gson.fromJson(content, typeOfHashMap);
            return data;
        } catch (FileNotFoundException e) {
            throw new RuntimeException("Failed to read state file", e);
        }
    }

    private void writeStateFile(Map<String, Boolean> data) {
        try {
            OutputStream outputStream = TestStorageUtil.getOutputStream(stateFileUri, getContentResolver());
            Gson gson = new Gson();
            Type typeOfHashMap = new TypeToken<Map<String, String>>() {}.getType();
            String json = gson.toJson(data, typeOfHashMap);
            outputStream.write(json.getBytes());
            outputStream.write("\n".getBytes());
        } catch (IOException e) {
            throw new RuntimeException("Failed to write state file", e);
        }
    }

    static String convertStreamToString(InputStream inputStream) {
        Scanner s = new Scanner(inputStream).useDelimiter("\\A");
        return s.hasNext() ? s.next() : "";
    }

    /**
     * Sets the state of lifecycle callbacks in the app.
     * <p>
     * This is required because the app is launched in a new process for each test.
     */
    public void setLifecycleCallbacksState() {
        final String TAG = "PatrolJUnitRunner.setLifecycleCallbacksStateInApp(): ";

        try {
            patrolAppServiceClient.setLifecycleCallbacksState(readStateFile());
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + "Failed to set lifecycle callbacks state in app: ", e);
            throw new RuntimeException(e);
        }
    }

    /**
     * Requests execution of a Dart test and waits for it to finish.
     * Throws AssertionError if the test fails.
     */
    public RunDartTestResponse runDartTest(String name) {
        final String TAG = "PatrolJUnitRunner.runDartTest(\"" + name + "\"): ";

        try {
            Logger.INSTANCE.i(TAG + "Requested execution");
            RunDartTestResponse response = patrolAppServiceClient.runDartTest(name);
            if (response.getResult() == Contracts.RunDartTestResponseResult.failure) {
                throw new AssertionError("Dart test failed: " + name + "\n" + response.getDetails());
            }
            return response;
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + e.getMessage(), e.getCause());
            throw new RuntimeException(e);
        }
    }
}
