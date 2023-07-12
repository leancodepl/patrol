package pl.leancode.patrol.example;

import android.util.Log;
import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.Parameterized;
import org.junit.runners.Parameterized.Parameters;

import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;

@RunWith(Parameterized.class)
public class MainActivityTest {
    @Parameters(name = "{0}")
    public static Object[] testCases() {
        listInterfaces();
        CustomPatrolJUnitRunner instrumentation = (CustomPatrolJUnitRunner) InstrumentationRegistry.getInstrumentation();
        instrumentation.setUp(MainActivity.class);
        instrumentation.waitForPatrolAppService();
        return instrumentation.listDartTests();
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

    private static void listInterfaces() {
        try {
            Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface i = interfaces.nextElement();
                Log.i("APPINET", "Interface: " + i.getDisplayName());
                i.getInterfaceAddresses().forEach(a -> Log.i("APPINET", "    Address: " + a.toString() + "; " + a.getAddress().toString()));

            }
        } catch (SocketException e) {
            Log.e("APPINET", "Cannot list interfaces: " + e.getMessage());
        }
    }
}
