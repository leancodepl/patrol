package pl.leancode.patrol;


public class AndroidServerPortProvider {
    private static int serverPort;

    public static void setPort(int newValue) {
        serverPort = newValue;
    }

    public static int getPort() {
        return serverPort;
    }
}