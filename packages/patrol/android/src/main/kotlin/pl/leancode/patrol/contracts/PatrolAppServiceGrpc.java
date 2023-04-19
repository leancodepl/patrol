package pl.leancode.patrol.contracts;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.49.1)",
    comments = "Source: contracts.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class PatrolAppServiceGrpc {

  private PatrolAppServiceGrpc() {}

  public static final String SERVICE_NAME = "patrol.PatrolAppService";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse> getListDartTestsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "listDartTests",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse> getListDartTestsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse> getListDartTestsMethod;
    if ((getListDartTestsMethod = PatrolAppServiceGrpc.getListDartTestsMethod) == null) {
      synchronized (PatrolAppServiceGrpc.class) {
        if ((getListDartTestsMethod = PatrolAppServiceGrpc.getListDartTestsMethod) == null) {
          PatrolAppServiceGrpc.getListDartTestsMethod = getListDartTestsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "listDartTests"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse.getDefaultInstance()))
              .build();
        }
      }
    }
    return getListDartTestsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.RunDartTestRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getRunDartTestMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "runDartTest",
      requestType = pl.leancode.patrol.contracts.Contracts.RunDartTestRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.RunDartTestRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getRunDartTestMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.RunDartTestRequest, pl.leancode.patrol.contracts.Contracts.Empty> getRunDartTestMethod;
    if ((getRunDartTestMethod = PatrolAppServiceGrpc.getRunDartTestMethod) == null) {
      synchronized (PatrolAppServiceGrpc.class) {
        if ((getRunDartTestMethod = PatrolAppServiceGrpc.getRunDartTestMethod) == null) {
          PatrolAppServiceGrpc.getRunDartTestMethod = getRunDartTestMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.RunDartTestRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "runDartTest"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.RunDartTestRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getRunDartTestMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static PatrolAppServiceStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<PatrolAppServiceStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<PatrolAppServiceStub>() {
        @java.lang.Override
        public PatrolAppServiceStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new PatrolAppServiceStub(channel, callOptions);
        }
      };
    return PatrolAppServiceStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static PatrolAppServiceBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<PatrolAppServiceBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<PatrolAppServiceBlockingStub>() {
        @java.lang.Override
        public PatrolAppServiceBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new PatrolAppServiceBlockingStub(channel, callOptions);
        }
      };
    return PatrolAppServiceBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static PatrolAppServiceFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<PatrolAppServiceFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<PatrolAppServiceFutureStub>() {
        @java.lang.Override
        public PatrolAppServiceFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new PatrolAppServiceFutureStub(channel, callOptions);
        }
      };
    return PatrolAppServiceFutureStub.newStub(factory, channel);
  }

  /**
   */
  public static abstract class PatrolAppServiceImplBase implements io.grpc.BindableService {

    /**
     */
    public void listDartTests(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getListDartTestsMethod(), responseObserver);
    }

    /**
     */
    public void runDartTest(pl.leancode.patrol.contracts.Contracts.RunDartTestRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getRunDartTestMethod(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getListDartTestsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse>(
                  this, METHODID_LIST_DART_TESTS)))
          .addMethod(
            getRunDartTestMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.RunDartTestRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_RUN_DART_TEST)))
          .build();
    }
  }

  /**
   */
  public static final class PatrolAppServiceStub extends io.grpc.stub.AbstractAsyncStub<PatrolAppServiceStub> {
    private PatrolAppServiceStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected PatrolAppServiceStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new PatrolAppServiceStub(channel, callOptions);
    }

    /**
     */
    public void listDartTests(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getListDartTestsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void runDartTest(pl.leancode.patrol.contracts.Contracts.RunDartTestRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getRunDartTestMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   */
  public static final class PatrolAppServiceBlockingStub extends io.grpc.stub.AbstractBlockingStub<PatrolAppServiceBlockingStub> {
    private PatrolAppServiceBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected PatrolAppServiceBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new PatrolAppServiceBlockingStub(channel, callOptions);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse listDartTests(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getListDartTestsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty runDartTest(pl.leancode.patrol.contracts.Contracts.RunDartTestRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getRunDartTestMethod(), getCallOptions(), request);
    }
  }

  /**
   */
  public static final class PatrolAppServiceFutureStub extends io.grpc.stub.AbstractFutureStub<PatrolAppServiceFutureStub> {
    private PatrolAppServiceFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected PatrolAppServiceFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new PatrolAppServiceFutureStub(channel, callOptions);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse> listDartTests(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getListDartTestsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> runDartTest(
        pl.leancode.patrol.contracts.Contracts.RunDartTestRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getRunDartTestMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_LIST_DART_TESTS = 0;
  private static final int METHODID_RUN_DART_TEST = 1;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final PatrolAppServiceImplBase serviceImpl;
    private final int methodId;

    MethodHandlers(PatrolAppServiceImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_LIST_DART_TESTS:
          serviceImpl.listDartTests((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.ListDartTestsResponse>) responseObserver);
          break;
        case METHODID_RUN_DART_TEST:
          serviceImpl.runDartTest((pl.leancode.patrol.contracts.Contracts.RunDartTestRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        default:
          throw new AssertionError();
      }
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public io.grpc.stub.StreamObserver<Req> invoke(
        io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        default:
          throw new AssertionError();
      }
    }
  }

  private static volatile io.grpc.ServiceDescriptor serviceDescriptor;

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    io.grpc.ServiceDescriptor result = serviceDescriptor;
    if (result == null) {
      synchronized (PatrolAppServiceGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .addMethod(getListDartTestsMethod())
              .addMethod(getRunDartTestMethod())
              .build();
        }
      }
    }
    return result;
  }
}
