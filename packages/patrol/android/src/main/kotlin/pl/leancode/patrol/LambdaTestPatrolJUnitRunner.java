package pl.leancode.patrol;

import android.util.Log;
import pl.leancode.patrol.contracts.PatrolAppServiceClientException;

import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Objects;

public class LambdaTestPatrolJUnitRunner extends PatrolJUnitRunner {
    public PatrolAppServiceClient patrolAppServiceClient;

    @Override
    void createAppServiceClient(Integer port) {
        // Create client with a default constructor (localhost:port) by default.
        patrolAppServiceClient = new PatrolAppServiceClient(port);
        waitForPatrolAppService();

        try {
            patrolAppServiceClient.listDartTests();
        } catch (PatrolAppServiceClientException ex) {
            ex.printStackTrace();
            // If the client on localhost:port fails, let's apply the workaround
            Logger.INSTANCE.i("PatrolAppServiceClientException in createAppServiceClient " + ex.getMessage());
            Logger.INSTANCE.i("LOOPBACK: " + getLoopback());
            patrolAppServiceClient = new PatrolAppServiceClient(getLoopback(), port);
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
        } catch (SocketException ignored) {
        }

        return null;
    }
}
