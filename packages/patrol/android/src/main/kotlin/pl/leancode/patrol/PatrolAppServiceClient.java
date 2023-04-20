package pl.leancode.patrol;

import io.grpc.Channel;
import io.grpc.StatusRuntimeException;
import pl.leancode.patrol.contracts.PatrolAppServiceGrpc;

import static pl.leancode.patrol.contracts.Contracts.*;

public class PatrolAppServiceClient {

    private final PatrolAppServiceGrpc.PatrolAppServiceBlockingStub blockingStub;

    /**
     * Construct client for accessing PatrolAppService server using the existing channel.
     */
    public PatrolAppServiceClient(Channel channel) {
        // 'channel' here is a Channel, not a ManagedChannel, so it is not this code's responsibility to
        // shut it down.

        // Passing Channels to code makes code easier to test and makes it easier to reuse Channels.
        blockingStub = PatrolAppServiceGrpc.newBlockingStub(channel);
    }

    public DartTestGroup listDartTests() throws StatusRuntimeException {
        ListDartTestsResponse response = blockingStub.listDartTests(Empty.newBuilder().build());

        return response.getGroup();
    }

    public Empty runDartTest(String name) throws StatusRuntimeException {
        RunDartTestRequest request = RunDartTestRequest.newBuilder().setName(name).build();
        return blockingStub.runDartTest(request);
    }
}
