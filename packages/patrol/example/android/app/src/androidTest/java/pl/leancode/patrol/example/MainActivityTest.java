package pl.leancode.patrol.example;

import android.util.Log;
import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.net.URL;
import java.util.stream.Collectors;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        PatrolGetter g = new PatrolGetter();
        Thread t = new Thread(g);
        t.start();
        try {
            t.join(60000);
            if (g.result != null) {
                t.interrupt();
                return g.result;
            } else {
                Log.e("MATE", "Null result");
                return new Object[0];
            }
        } catch (InterruptedException e) {
            t.interrupt();
            Log.e("MATE", "Failed getting");
            return new Object[0];
        }
    }

    public MainActivityTest(String dartTestName) {
        this.dartTestName = dartTestName;
    }

    private final String dartTestName;

    @Test
    public void runDartTest() {
        CustomPatrolJUnitRunner instrumentation = (CustomPatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.runDartTest(dartTestName);
    }

    static class PatrolGetter implements Runnable {
        public volatile Object[] result;

        @Override
        public void run() {
            listInterfaces();
            CustomPatrolJUnitRunner instrumentation = (CustomPatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
            instrumentation.setUp(MainActivity.class);
            instrumentation.waitForPatrolAppService();
            result = instrumentation.listDartTests();
        }

        private static void doAHttpCall() {
            CustomPatrolJUnitRunner instrumentation = (CustomPatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();

            try {
                URL address = new URL("http://" + instrumentation.getLoopback());
                HttpURLConnection conn = (HttpURLConnection) address.openConnection();
                try {
                    conn.setRequestProperty("User-Agent", "Mozilla/5.0 ( compatible ) ");
                    conn.setRequestProperty("Accept", "*/*");
                    conn.setRequestMethod("GET");
                    conn.setDoInput(true);

                    Log.e("MATHTTP", "Status: " + conn.getResponseCode());

                    try (InputStream in = new BufferedInputStream(conn.getErrorStream())) {
                        String res = new BufferedReader(new InputStreamReader(in)).lines().collect(Collectors.joining("\n"));
                        Log.e("MATHTTP", res);
                    }
                    conn.getHeaderFields().forEach((k, v) -> Log.e("MATHTTP", k + "=" + v));
                } finally {
                    conn.disconnect();
                }
            } catch (IOException e) {
                Log.e("MATHTTP", e.toString());
            }
        }

        private static void listInterfaces() {
            try {
                java.util.Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
                while (interfaces.hasMoreElements()) {
                    NetworkInterface i = interfaces.nextElement();
                    Log.i("APPINET", "Interface: " + i.getDisplayName());
                    i.getInterfaceAddresses().forEach(a -> Log.i("APPINET", "    Address: " + a.toString() + "; " + a.getAddress().toString()));

                }
            } catch (SocketException e) {
                Log.e("APPINET", "Cannot list interfaces: " + e.toString());
            }
        }
    }
}
