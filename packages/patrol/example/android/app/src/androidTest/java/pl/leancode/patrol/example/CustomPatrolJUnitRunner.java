package pl.leancode.patrol.example;

import android.util.Log;
import io.grpc.StatusRuntimeException;
import pl.leancode.patrol.Logger;
import pl.leancode.patrol.PatrolAppServiceClient;
import pl.leancode.patrol.PatrolJUnitRunner;

import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Objects;

public class CustomPatrolJUnitRunner extends PatrolJUnitRunner {
    @Override
    public PatrolAppServiceClient createAppServiceClient() {
        // Create client with a default constructor (localhost:8082) by default.
        PatrolAppServiceClient client = new PatrolAppServiceClient();
        waitForPatrolAppService();

        try {
            client.listDartTests();
        } catch (StatusRuntimeException ex) {
            ex.printStackTrace();
            // If the client on localhost:8082 fails, let's apply the wokraround
            Logger.INSTANCE.i("StatusRuntimeException in createAppServiceClient " + ex.getMessage());
            Logger.INSTANCE.i("LOOPBACK: " + getLoopback());
            client = new PatrolAppServiceClient(getLoopback());
        }

        return client;
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
                            return a.getAddress().toString().substring(1) + ":8082";
                        }
                    }
                }

            }
        } catch (SocketException e) {
        }

        return null;
    }
}
