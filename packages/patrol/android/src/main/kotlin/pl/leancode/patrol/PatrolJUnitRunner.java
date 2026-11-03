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

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
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
    private String coverageFilePath;
    private boolean coverageEnabled;
    // clearPackageData mode: each test's coverage is appended by the shell user.
    private boolean shellAppendCoverage;
    private boolean generatedSetUpDone = false;

    /** Simple name of the class written by build-time test discovery (`patrol build android --emit-test-manifest`). */
    private static final String GENERATED_TESTS_CLASS = "PatrolGeneratedTests";

    @Override
    protected boolean shouldWaitForActivitiesToComplete() {
        return false;
    }

    @Override
    public void onCreate(Bundle arguments) {
        // Capture coverage configuration before AGP wires up its own dump-on-
        // finish flow. We then disable AGP's auto-dump because AGP performs it
        // during finish() — by which time the process is being torn down and
        // we have no reliable window to append Dart-side coverage blocks.
        // Instead we drive the dump ourselves from runDartTest() while the
        // process is fully alive (see writeMergedCoverage).
        coverageFilePath = arguments.getString("coverageFile");
        coverageEnabled = "true".equalsIgnoreCase(arguments.getString("coverage"));
        if (coverageEnabled) {
            Logger.INSTANCE.i(
                "BS coverage: taking over JaCoCo dump → " + coverageFilePath
            );
            arguments.putString("coverage", "false");
            BrowserStackCoverage.INSTANCE.exportDartCoverageDir(getTargetContext());
            // Best-effort: a farm may strip this arg; writeMergedCoverage
            // also switches to shell-append when the direct write fails.
            if ("true".equalsIgnoreCase(arguments.getString("clearPackageData"))) {
                if (canShellAppendCoverage()) {
                    shellAppendCoverage = true;
                    Logger.INSTANCE.i("BS coverage: clearPackageData=true, appending each test via shell");
                } else {
                    Logger.INSTANCE.e(
                        "BS coverage: clearPackageData=true needs Android 12+ (API 31) "
                            + "and a shared-storage coverageFile — pm clear revokes this "
                            + "app's access to the coverage file, so only the first test "
                            + "will be reported."
                    );
                }
            }
        }

        // Register the listener that records each test's JUnit name for screenshots.
        String listeners = arguments.getString("listener");
        String patrolListener = PatrolTestNameListener.class.getName();
        arguments.putString(
                "listener",
                listeners == null || listeners.isEmpty()
                        ? patrolListener
                        : listeners + "," + patrolListener
        );

        super.onCreate(arguments);

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
     * BrowserStack's `coverageFile` (shared storage) when given — that's the
     * only place its coverage API picks the file up from. With
     * `clearPackageData:true` the app can't write there after the first test
     * (EACCES), so that mode goes through {@link #appendCoverageViaShell}.
     */
    private File resolveCoverageFile() {
        if (coverageFilePath != null && !coverageFilePath.isEmpty()) {
            return new File(coverageFilePath);
        }
        // getFilesDir() is available on all supported API levels (unlike
        // getDataDir(), API 24+) and matches the <filesDir>/patrol_coverage
        // location the Dart side and BrowserStackCoverage use.
        return new File(getTargetContext().getFilesDir(), "coverage.ec");
    }

    /**
     * Dumps JaCoCo coverage data (collected by the runtime agent) into
     * `coverageFilePath`, then appends patrol's Dart-side LCOV blocks. Called
     * after each Dart test from runDartTest() — at that point the process is
     * fully alive and we have unbounded time, unlike the AGP-driven dump
     * inside `finish()` which races against process teardown.
     *
     * If the JaCoCo runtime classes are absent (e.g. testCoverageEnabled=false
     * on the app under test), this method is a silent no-op.
     */
    private void writeMergedCoverage() {
        if (!coverageEnabled) return;
        File covFile = resolveCoverageFile();
        if (covFile == null) return;

        try {
            // org.jacoco.agent.rt.RT is added by AGP when testCoverageEnabled=true.
            Class<?> rtClass = Class.forName("org.jacoco.agent.rt.RT");
            Object agent = rtClass.getMethod("getAgent").invoke(null);
            byte[] data = (byte[]) agent.getClass()
                .getMethod("getExecutionData", boolean.class)
                .invoke(agent, false);

            // clearPackageData with the arg stripped by the farm: pm clear left
            // the file in place but took this app's access to it.
            if (!shellAppendCoverage && covFile.exists() && !covFile.canWrite() && canShellAppendCoverage()) {
                Logger.INSTANCE.i("BS coverage: " + covFile.getAbsolutePath() + " not writable, switching to shell-append");
                shellAppendCoverage = true;
            }
            if (shellAppendCoverage) {
                appendCoverageViaShell(covFile, data, agent);
                return;
            }

            File parent = covFile.getParentFile();
            if (parent != null && !parent.exists()) {
                parent.mkdirs();
            }

            // Assemble the whole file (JaCoCo dump + Dart blocks) in a staging
            // file next to the destination, then swap it in with a single
            // rename. Writing straight into covFile leaves it holding JaCoCo
            // and zero Dart blocks for the entire duration of the append; a
            // process killed in that window - e.g. by the BrowserStack session
            // timeout - hands the farm a Dart-less .ec, losing every earlier
            // test's Dart coverage.
            File staging = new File(covFile.getAbsolutePath() + ".patrol-staging");
            try {
                try (FileOutputStream fos = new FileOutputStream(staging, /* append= */ false)) {
                    fos.write(data);
                    fos.flush();
                    fos.getFD().sync();
                }
                Logger.INSTANCE.i("BS coverage: staged " + data.length + " JaCoCo bytes in " + staging.getAbsolutePath());

                BrowserStackCoverage.INSTANCE.appendDartCoverage(getTargetContext(), staging, null);

                if (!staging.renameTo(covFile)) {
                    // A same-directory rename is atomic on the filesystems Android
                    // uses here. If it is refused anyway, fall back to a copy so
                    // the run still produces coverage.
                    Logger.INSTANCE.e("BS coverage: rename to " + covFile.getAbsolutePath() + " failed, copying instead", null);
                    copyFile(staging, covFile);
                    staging.delete();
                }
            } catch (IOException e) {
                staging.delete();
                // Same as the canWrite() check above, for when it didn't catch it.
                if (!isPermissionDenied(e) || !canShellAppendCoverage()) throw e;
                Logger.INSTANCE.e("BS coverage: direct write denied, switching to shell-append", e);
                shellAppendCoverage = true;
                appendCoverageViaShell(covFile, data, agent);
                return;
            }
            Logger.INSTANCE.i("BS coverage: merged file now " + covFile.length() + " bytes");
        } catch (ClassNotFoundException e) {
            // coverage=true was requested but the JaCoCo runtime is missing: the
            // app under test wasn't instrumented. Warn loudly — a silent skip
            // means no coverage leaves the device and the misconfig is invisible.
            Logger.INSTANCE.e(
                "BS coverage: JaCoCo runtime absent, no coverage collected. "
                    + "Set `enableAndroidTestCoverage true` (AGP 8+) or "
                    + "`testCoverageEnabled true` (AGP 7) on the app's debug "
                    + "build type.",
                e
            );
        } catch (Throwable t) {
            Logger.INSTANCE.e("BS coverage: writeMergedCoverage failed " + t.getMessage(), t);
        }
    }

    /** The shell user can write a shared-storage coverageFile, not app-internal storage. */
    private boolean canShellAppendCoverage() {
        return coverageFilePath != null && !coverageFilePath.isEmpty()
            && !coverageFilePath.startsWith("/data/")
            && BrowserStackCoverage.INSTANCE.canAppendViaShell();
    }

    private static boolean isPermissionDenied(IOException e) {
        String message = e.getMessage();
        return message != null && (message.contains("EACCES") || message.contains("Permission denied"));
    }

    /**
     * Appends this process's coverage (JaCoCo `data` plus its Dart LCOV) to
     * `covFile` as the shell user. JaCoCo reads concatenated dumps, so every
     * test under `clearPackageData` adds its own block. JaCoCo probes and Dart
     * LCOV are cleared only after the append is confirmed, so a failure doesn't
     * lose them.
     */
    private void appendCoverageViaShell(File covFile, byte[] data, Object agent) throws Exception {
        File staging = new File(getTargetContext().getCacheDir(), "coverage.patrol-staging");
        try (FileOutputStream fos = new FileOutputStream(staging, /* append= */ false)) {
            fos.write(data);
        }
        BrowserStackCoverage.INSTANCE.appendDartCoverage(
            getTargetContext(), staging, BrowserStackCoverage.INSTANCE.newRunId());
        byte[] bytes = new byte[(int) staging.length()];
        try (FileInputStream in = new FileInputStream(staging)) {
            int off = 0;
            while (off < bytes.length) {
                int read = in.read(bytes, off, bytes.length - off);
                if (read < 0) break;
                off += read;
            }
        }
        BrowserStackCoverage.INSTANCE.appendViaShell(this, covFile.getAbsolutePath(), bytes);
        staging.delete();
        // Hand over only new probes and LCOV on the next append in this process.
        agent.getClass().getMethod("reset").invoke(agent);
        BrowserStackCoverage.INSTANCE.clearDartCoverage(getTargetContext());
    }

    private static void copyFile(File from, File to) throws IOException {
        try (FileInputStream in = new FileInputStream(from);
             FileOutputStream out = new FileOutputStream(to, /* append= */ false)) {
            byte[] buf = new byte[8192];
            int read;
            while ((read = in.read(buf)) > 0) {
                out.write(buf, 0, read);
            }
            out.flush();
            out.getFD().sync();
        }
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
        if (isSupersededByGeneratedTests()) {
            Logger.INSTANCE.i("PatrolJUnitRunner.setUp(): standing down, " + GENERATED_TESTS_CLASS + " runs these tests");
            return;
        }

        launchAppUnderTest(activityClass);
    }

    /**
     * <p>
     * Sets up and awaits the app for the test classes generated by build-time test discovery
     * ({@code patrol build --emit-test-manifest}).
     * </p>
     *
     * <p>
     * Equivalent to {@link #setUp(Class)} followed by {@link #waitForPatrolAppService()}, except it
     * never stands down: the generated classes hold the tests themselves, so nothing supersedes
     * them. Keeping them on their own entry point is what lets the stand-down check stay a plain
     * "is there a generated class next to the host" question. Only the first call launches the app;
     * the calls from the remaining generated classes in the process are no-ops.
     * </p>
     */
    public void setUpGenerated(Class<?> activityClass) {
        // Each generated class calls this from @BeforeClass, and without the ATO
        // they all share one instrumentation process. The server binds a fixed
        // port, so launch once and reuse it (same as the iOS static runner).
        if (generatedSetUpDone) {
            return;
        }
        generatedSetUpDone = true;

        launchAppUnderTest(activityClass);
        awaitPatrolAppService();
    }

    private void launchAppUnderTest(Class<?> activityClass) {
        Logger.INSTANCE.i("PatrolJUnitRunner.setUp(): activityClass = " + activityClass.getCanonicalName());

        // This code launches the app under test. It's based on ActivityTestRule#launchActivity.
        // It's simpler because we don't have the need for that much synchronization.
        // Currently, the only synchronization point we're interested in is when the app under test returns the list of tests.
        Instrumentation instrumentation = InstrumentationRegistry.getInstrumentation();

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
        if (isSupersededByGeneratedTests()) {
            return;
        }

        awaitPatrolAppService();
    }

    private void awaitPatrolAppService() {
        final String TAG = "PatrolJUnitRunner.setUp(): ";

        Logger.INSTANCE.i(TAG + "Waiting for PatrolAppService to report its readiness...");
        PatrolServer.Companion.getAppReady().block();

        Logger.INSTANCE.i(TAG + "PatrolAppService is ready to report Dart tests");
    }

    public Object[] listDartTests() {
        final String TAG = "PatrolJUnitRunner.listDartTests(): ";

        if (isSupersededByGeneratedTests()) {
            Logger.INSTANCE.i(TAG + "Reporting no tests, " + GENERATED_TESTS_CLASS + " covers the whole Dart test suite");
            return new Object[]{};
        }

        try {
            final DartGroupEntry dartTestGroup = patrolAppServiceClient.listDartTests();
            List<DartGroupEntry> dartTestCases = ContractsExtensionsKt.listTestsFlat(dartTestGroup, "");
            List<String> dartTestCaseNamesList = new ArrayList<>();
            for (DartGroupEntry dartTestCase : dartTestCases) {
                dartTestCaseSkipMap.put(dartTestCase.getName(), dartTestCase.getSkip());
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

    /**
     * <p>
     * Whether the calling test class must contribute no tests because build-time test discovery
     * compiled its generated class into the same APK.
     * </p>
     *
     * <p>
     * The generated class and the runtime-discovery host class each run the entire Dart suite, so
     * leaving both active runs everything twice. {@code patrol test} selects the generated class
     * explicitly, but any other runner (Firebase Test Lab, saucectl, emulator.wtf, Marathon)
     * instruments the APK as built.
     * </p>
     */
    private boolean isSupersededByGeneratedTests() {
        for (StackTraceElement frame : new Throwable().getStackTrace()) {
            final String caller = frame.getClassName();
            if (caller.equals(PatrolJUnitRunner.class.getName()) || caller.equals(getClass().getName())) {
                continue;
            }
            return isSupersededByGeneratedTests(caller);
        }
        return false;
    }

    /**
     * Whether a generated test class sits next to {@code callerClassName}, which is then the host
     * class it supersedes. The generated classes drive the runner through
     * {@link #setUpGenerated(Class)} and never reach this check, so the caller here is always a
     * host candidate.
     */
    static boolean isSupersededByGeneratedTests(String callerClassName) {
        final int packageEnd = callerClassName.lastIndexOf('.');
        if (packageEnd < 0 || callerClassName.substring(packageEnd + 1).equals(GENERATED_TESTS_CLASS)) {
            return false;
        }

        try {
            Class.forName(callerClassName.substring(0, packageEnd + 1) + GENERATED_TESTS_CLASS);
            return true;
        } catch (ClassNotFoundException e) {
            return false;
        }
    }

    /**
     * Requests execution of a Dart test and waits for it to finish.
     * Throws AssertionError if the test fails.
     */
    public RunDartTestResponse runDartTest(String name) {
        // Runtime-discovery path: the skip flag was recorded by listDartTests().
        // Guard against a missing entry so a null Boolean can't NPE on unboxing.
        final Boolean skip = dartTestCaseSkipMap.get(name);
        return runDartTest(name, Boolean.TRUE.equals(skip));
    }

    /**
     * Requests execution of a Dart test and waits for it to finish.
     * Throws AssertionError if the test fails.
     *
     * <p>
     * This overload takes the [skip] flag explicitly, so it works without a
     * prior {@link #listDartTests()} call. It's used by the statically generated
     * test class produced by build-time test discovery
     * (`patrol build android --emit-test-manifest`).
     * </p>
     */
    public RunDartTestResponse runDartTest(String name, boolean skip) {
        final String TAG = "PatrolJUnitRunner.runDartTest(" + name + "): ";

        if (skip) {
            Logger.INSTANCE.i(TAG + "Test skipped");
            assumeFalse(skip);
        }

        try {
            Logger.INSTANCE.i(TAG + "Requested execution");
            RunDartTestResponse response = patrolAppServiceClient.runDartTest(name);
            // Dump coverage NOW — Dart side has written its per-test LCOV in
            // tearDown(), and the instrumentation process is alive. Doing this
            // here instead of in finish() avoids racing the process teardown.
            writeMergedCoverage();
            if (response.getResult() == Contracts.RunDartTestResponseResult.failure) {
                throw new AssertionError("Dart test failed: " + name + "\n" + response.getDetails());
            }
            // The app can skip a test the native side was told to run, for example when a
            // platform-dependent `skip:` was evaluated differently during build-time discovery.
            if (response.getResult() == Contracts.RunDartTestResponseResult.skipped) {
                Logger.INSTANCE.i(TAG + "Test skipped by the app: " + response.getDetails());
                assumeTrue(response.getDetails(), false);
            }
            Logger.INSTANCE.i(TAG + "Test execution succeeded");
            return response;
        } catch (PatrolAppServiceClientException e) {
            Logger.INSTANCE.e(TAG + e.getMessage(), e.getCause());
            throw new RuntimeException(e);
        }
    }
}
