package pl.leancode.patrol.example;

import pl.leancode.patrol.Logger;
import pl.leancode.patrol.PatrolAppServiceClient;
import pl.leancode.patrol.PatrolJUnitRunner;

import java.net.Inet4Address;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Objects;

public class CustomPatrolJUnitRunner extends PatrolJUnitRunner {
    @Override
    public PatrolAppServiceClient createAppServiceClient() {
        Logger.INSTANCE.i("LOOPBACK: " + getLoopback());
        return new PatrolAppServiceClient(getLoopback());
    }

    public String getLoopback() {
        try {
            java.util.Enumeration<NetworkInterface> interfaces = NetworkInterface.getNetworkInterfaces();
            while (interfaces.hasMoreElements()) {
                NetworkInterface i = interfaces.nextElement();
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
