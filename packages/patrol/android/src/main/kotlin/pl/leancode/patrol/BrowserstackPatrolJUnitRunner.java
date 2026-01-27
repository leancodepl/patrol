package pl.leancode.patrol;

import static org.junit.Assume.assumeFalse;

import android.util.Log;
import pl.leancode.patrol.contracts.Contracts;
import pl.leancode.patrol.contracts.PatrolAppServiceClientException;

import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Objects;

public class BrowserstackPatrolJUnitRunner extends PatrolJUnitRunner {
    @Override
    public PatrolAppServiceClient createAppServiceClient() {
        // Create client with a default constructor (localhost:8082) by default.
        PatrolAppServiceClient client = new PatrolAppServiceClient();
        waitForPatrolAppService();

        try {
            client.listDartTests();

            //TODO verify in a project where we use BrowserStack
        } catch (PatrolAppServiceClientException ex) {
            ex.printStackTrace();
            // If the client on localhost:8082 fails, let's apply the workaround
            Logger.INSTANCE.i("PatrolAppServiceClientException in createAppServiceClient " + ex.getMessage());
            Logger.INSTANCE.i("LOOPBACK: " + getLoopback());
            client = new PatrolAppServiceClient(getLoopback());
        }

        return client;
    }

    /**
     * Overrides runDartTest to handle BrowserStack proxy timeouts.
     * When a 504 timeout occurs (common for tests running >200s on BrowserStack),
     * this method polls the getDartTestStatus endpoint until the test completes.
     */
    @Override
    public Contracts.RunDartTestResponse runDartTest(String name) {
        final String TAG = "BrowserstackRunner.runDartTest(" + name + "): ";

        // Handle skipped tests first
        final Boolean skip = dartTestCaseSkipMap.get(name);
        if (skip != null && skip) {
            Logger.INSTANCE.i(TAG + "Test skipped");
            assumeFalse(skip);
        }

        try {
            Logger.INSTANCE.i(TAG + "Requesting execution");
            Contracts.RunDartTestResponse response = patrolAppServiceClient.runDartTest(name);
            if (response.getResult() == Contracts.RunDartTestResponseResult.failure) {
                throw new AssertionError("Dart test failed: " + name + "\n" + response.getDetails());
            }
            Logger.INSTANCE.i(TAG + "Test execution succeeded");
            return response;
        } catch (PatrolAppServiceClientException e) {
            // Check if it's a timeout error (504 from BrowserStack proxy)
            if (isTimeoutError(e)) {
                Logger.INSTANCE.i(TAG + "Timeout detected, starting status polling");
                return pollForTestCompletion(name);
            }
            Logger.INSTANCE.e(TAG + e.getMessage(), e.getCause());
            throw new RuntimeException(e);
        }
    }

    private boolean isTimeoutError(Exception e) {
        String message = e.getMessage();
        if (message == null) return false;
        return message.contains("504") ||
               message.contains("timeout") ||
               message.contains("Timeout");
    }

    private Contracts.RunDartTestResponse pollForTestCompletion(String testName) {
        final String TAG = "BrowserstackRunner.pollForTestCompletion(" + testName + "): ";
        final int maxRetries = 360;  // 30 minutes at 5s intervals
        final int intervalMs = 5000;

        for (int i = 0; i < maxRetries; i++) {
            try {
                Thread.sleep(intervalMs);

                Contracts.GetDartTestStatusResponse status =
                    patrolAppServiceClient.getDartTestStatus(testName);

                switch (status.getStatus()) {
                    case success:
                        Logger.INSTANCE.i(TAG + "Test completed successfully after polling");
                        return new Contracts.RunDartTestResponse(
                            Contracts.RunDartTestResponseResult.success, null);
                    case failure:
                        String details = status.getDetails();
                        Logger.INSTANCE.i(TAG + "Test failed after polling");
                        throw new AssertionError("Dart test failed: " + testName + "\n" + details);
                    case running:
                        Logger.INSTANCE.i(TAG + "Poll " + i + ": test still running");
                        continue;
                    case notStarted:
                        // This shouldn't happen if we got here from a timeout
                        Logger.INSTANCE.i(TAG + "Poll " + i + ": unexpected notStarted status");
                        continue;
                    default:
                        throw new RuntimeException("Unexpected status: " + status.getStatus());
                }
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Polling interrupted", ie);
            } catch (PatrolAppServiceClientException pce) {
                Logger.INSTANCE.i(TAG + "Poll " + i + " failed: " + pce.getMessage());
                // Continue polling on transient errors
            }
        }

        throw new RuntimeException("Test polling timed out after 30 minutes");
    }

    public String getLoopback() {
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface i = interfaces.nextElement();
                Log.d("LOOPBACK", i.getDisplayName());
                if (Objects.equals(i.getDisplayName(), "tun0")) {
                    for (java.net.InterfaceAddress a : i.getInterfaceAddresses()) {
                        if (a.getAddress() instanceof Inet4Address) {
                            return a.getAddress().toString().substring(1);
                        }
                    }
                }

            }
        } catch (SocketException e) {
        }

        return null;
    }
}
