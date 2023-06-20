package pl.leancode.patrol;

import io.grpc.Grpc;
import io.grpc.InsecureChannelCredentials;
import io.grpc.ManagedChannel;
import io.grpc.StatusRuntimeException;
import pl.leancode.patrol.contracts.PatrolAppServiceGrpc;

import static pl.leancode.patrol.contracts.Contracts.*;

/**
 * Enables querying Dart tests, running them, waiting for them to finish, and getting their results
 */
public class PatrolAppServiceClient {

    private final PatrolAppServiceGrpc.PatrolAppServiceBlockingStub blockingStub;

    public PatrolAppServiceClient() {
        String target = "localhost:8082"; // TODO: Document this value better
        Logger.INSTANCE.i("Created PatrolAppServiceClient with default target: " + target);
        ManagedChannel channel = Grpc.newChannelBuilder(target, InsecureChannelCredentials.create()).build();
        blockingStub = PatrolAppServiceGrpc.newBlockingStub(channel);
    }

    public PatrolAppServiceClient(String target) {
        Logger.INSTANCE.i("Created PatrolAppServiceClient, target: " + target);
        ManagedChannel channel = Grpc.newChannelBuilder(target, InsecureChannelCredentials.create()).build();
        blockingStub = PatrolAppServiceGrpc.newBlockingStub(channel);
    }

    public DartTestGroup listDartTests() throws StatusRuntimeException {
        Empty request = Empty.newBuilder().build();
        ListDartTestsResponse response = blockingStub.listDartTests(request);

        return response.getGroup();
    }

    public RunDartTestResponse runDartTest(String name) throws StatusRuntimeException {
        RunDartTestRequest request = RunDartTestRequest.newBuilder().setName(name).build();
        return blockingStub.runDartTest(request);
    }
}
