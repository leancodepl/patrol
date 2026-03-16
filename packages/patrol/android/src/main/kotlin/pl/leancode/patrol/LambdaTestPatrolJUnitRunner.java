package pl.leancode.patrol;

import android.content.ContentResolver;
import android.provider.Settings;
import android.util.Log;
import pl.leancode.patrol.contracts.PatrolAppServiceClientException;

import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Objects;

public class LambdaTestPatrolJUnitRunner extends PatrolJUnitRunner {
    @Override
    public PatrolAppServiceClient createAppServiceClient() {
        propagateJvmProxyToSystem();

        // Create client with a default constructor (localhost:8082) by default.
        PatrolAppServiceClient client = new PatrolAppServiceClient();
        waitForPatrolAppService();

        try {
            client.listDartTests();
        } catch (PatrolAppServiceClientException ex) {
            ex.printStackTrace();
            // localhost DNS may fail on cloud devices, try 127.0.0.1 directly
            Logger.INSTANCE.i("PatrolAppServiceClientException in createAppServiceClient " + ex.getMessage());
            client = new PatrolAppServiceClient("127.0.0.1");
            try {
                client.listDartTests();
            } catch (PatrolAppServiceClientException ex2) {
                ex2.printStackTrace();
                // If 127.0.0.1 also fails, try tun0 interface IP
                Logger.INSTANCE.i("127.0.0.1 also failed, trying tun0 loopback: " + getLoopback());
                client = new PatrolAppServiceClient(getLoopback());
            }
        }

        return client;
    }

    /**
     * Reads JVM-level proxy settings (set by TestMu/LambdaTest for geolocation)
     * and propagates them to Android's system-level HTTP proxy so that WebView
     * and other non-JVM HTTP clients also route through the proxy.
     */
    private void propagateJvmProxyToSystem() {
        String proxyHost = System.getProperty("http.proxyHost");
        String proxyPort = System.getProperty("http.proxyPort");

        Logger.INSTANCE.i("JVM proxy: host=" + proxyHost + ", port=" + proxyPort);

        if (proxyHost != null && !proxyHost.isEmpty()) {
            String proxyValue = proxyHost + ":" + (proxyPort != null ? proxyPort : "80");
            try {
                ContentResolver resolver = getTargetContext().getContentResolver();
                Settings.Global.putString(resolver, Settings.Global.HTTP_PROXY, proxyValue);
                Logger.INSTANCE.i("Set system HTTP proxy to: " + proxyValue);
            } catch (Exception e) {
                Logger.INSTANCE.i("Failed to set system HTTP proxy: " + e.getMessage());
            }
        } else {
            Logger.INSTANCE.i("No JVM proxy detected, skipping system proxy setup");
        }
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
