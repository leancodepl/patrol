package pl.leancode.patrol.contracts;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.49.1)",
    comments = "Source: contracts.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class NativeAutomatorGrpc {

  private NativeAutomatorGrpc() {}

  public static final String SERVICE_NAME = "patrol.NativeAutomator";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getInitializeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "initialize",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getInitializeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getInitializeMethod;
    if ((getInitializeMethod = NativeAutomatorGrpc.getInitializeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getInitializeMethod = NativeAutomatorGrpc.getInitializeMethod) == null) {
          NativeAutomatorGrpc.getInitializeMethod = getInitializeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "initialize"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getInitializeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.ConfigureRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getConfigureMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "configure",
      requestType = pl.leancode.patrol.contracts.Contracts.ConfigureRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.ConfigureRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getConfigureMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.ConfigureRequest, pl.leancode.patrol.contracts.Contracts.Empty> getConfigureMethod;
    if ((getConfigureMethod = NativeAutomatorGrpc.getConfigureMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getConfigureMethod = NativeAutomatorGrpc.getConfigureMethod) == null) {
          NativeAutomatorGrpc.getConfigureMethod = getConfigureMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.ConfigureRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "configure"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.ConfigureRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getConfigureMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getPressHomeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressHome",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getPressHomeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getPressHomeMethod;
    if ((getPressHomeMethod = NativeAutomatorGrpc.getPressHomeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressHomeMethod = NativeAutomatorGrpc.getPressHomeMethod) == null) {
          NativeAutomatorGrpc.getPressHomeMethod = getPressHomeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressHome"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getPressHomeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getPressBackMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressBack",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getPressBackMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getPressBackMethod;
    if ((getPressBackMethod = NativeAutomatorGrpc.getPressBackMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressBackMethod = NativeAutomatorGrpc.getPressBackMethod) == null) {
          NativeAutomatorGrpc.getPressBackMethod = getPressBackMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressBack"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getPressBackMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getPressRecentAppsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressRecentApps",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getPressRecentAppsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getPressRecentAppsMethod;
    if ((getPressRecentAppsMethod = NativeAutomatorGrpc.getPressRecentAppsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressRecentAppsMethod = NativeAutomatorGrpc.getPressRecentAppsMethod) == null) {
          NativeAutomatorGrpc.getPressRecentAppsMethod = getPressRecentAppsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressRecentApps"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getPressRecentAppsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDoublePressRecentAppsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "doublePressRecentApps",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDoublePressRecentAppsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getDoublePressRecentAppsMethod;
    if ((getDoublePressRecentAppsMethod = NativeAutomatorGrpc.getDoublePressRecentAppsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDoublePressRecentAppsMethod = NativeAutomatorGrpc.getDoublePressRecentAppsMethod) == null) {
          NativeAutomatorGrpc.getDoublePressRecentAppsMethod = getDoublePressRecentAppsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "doublePressRecentApps"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDoublePressRecentAppsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.OpenAppRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getOpenAppMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openApp",
      requestType = pl.leancode.patrol.contracts.Contracts.OpenAppRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.OpenAppRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getOpenAppMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.OpenAppRequest, pl.leancode.patrol.contracts.Contracts.Empty> getOpenAppMethod;
    if ((getOpenAppMethod = NativeAutomatorGrpc.getOpenAppMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenAppMethod = NativeAutomatorGrpc.getOpenAppMethod) == null) {
          NativeAutomatorGrpc.getOpenAppMethod = getOpenAppMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.OpenAppRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openApp"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.OpenAppRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getOpenAppMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getOpenQuickSettingsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openQuickSettings",
      requestType = pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getOpenQuickSettingsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest, pl.leancode.patrol.contracts.Contracts.Empty> getOpenQuickSettingsMethod;
    if ((getOpenQuickSettingsMethod = NativeAutomatorGrpc.getOpenQuickSettingsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenQuickSettingsMethod = NativeAutomatorGrpc.getOpenQuickSettingsMethod) == null) {
          NativeAutomatorGrpc.getOpenQuickSettingsMethod = getOpenQuickSettingsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openQuickSettings"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getOpenQuickSettingsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest,
      pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse> getGetNativeViewsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "getNativeViews",
      requestType = pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest,
      pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse> getGetNativeViewsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest, pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse> getGetNativeViewsMethod;
    if ((getGetNativeViewsMethod = NativeAutomatorGrpc.getGetNativeViewsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getGetNativeViewsMethod = NativeAutomatorGrpc.getGetNativeViewsMethod) == null) {
          NativeAutomatorGrpc.getGetNativeViewsMethod = getGetNativeViewsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest, pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "getNativeViews"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse.getDefaultInstance()))
              .build();
        }
      }
    }
    return getGetNativeViewsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getTapMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "tap",
      requestType = pl.leancode.patrol.contracts.Contracts.TapRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getTapMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapRequest, pl.leancode.patrol.contracts.Contracts.Empty> getTapMethod;
    if ((getTapMethod = NativeAutomatorGrpc.getTapMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getTapMethod = NativeAutomatorGrpc.getTapMethod) == null) {
          NativeAutomatorGrpc.getTapMethod = getTapMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.TapRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "tap"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.TapRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getTapMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getDoubleTapMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "doubleTap",
      requestType = pl.leancode.patrol.contracts.Contracts.TapRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getDoubleTapMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapRequest, pl.leancode.patrol.contracts.Contracts.Empty> getDoubleTapMethod;
    if ((getDoubleTapMethod = NativeAutomatorGrpc.getDoubleTapMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDoubleTapMethod = NativeAutomatorGrpc.getDoubleTapMethod) == null) {
          NativeAutomatorGrpc.getDoubleTapMethod = getDoubleTapMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.TapRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "doubleTap"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.TapRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDoubleTapMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.EnterTextRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnterTextMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enterText",
      requestType = pl.leancode.patrol.contracts.Contracts.EnterTextRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.EnterTextRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnterTextMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.EnterTextRequest, pl.leancode.patrol.contracts.Contracts.Empty> getEnterTextMethod;
    if ((getEnterTextMethod = NativeAutomatorGrpc.getEnterTextMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnterTextMethod = NativeAutomatorGrpc.getEnterTextMethod) == null) {
          NativeAutomatorGrpc.getEnterTextMethod = getEnterTextMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.EnterTextRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enterText"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.EnterTextRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getEnterTextMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.SwipeRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getSwipeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "swipe",
      requestType = pl.leancode.patrol.contracts.Contracts.SwipeRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.SwipeRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getSwipeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.SwipeRequest, pl.leancode.patrol.contracts.Contracts.Empty> getSwipeMethod;
    if ((getSwipeMethod = NativeAutomatorGrpc.getSwipeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getSwipeMethod = NativeAutomatorGrpc.getSwipeMethod) == null) {
          NativeAutomatorGrpc.getSwipeMethod = getSwipeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.SwipeRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "swipe"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.SwipeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getSwipeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getWaitUntilVisibleMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "waitUntilVisible",
      requestType = pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getWaitUntilVisibleMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest, pl.leancode.patrol.contracts.Contracts.Empty> getWaitUntilVisibleMethod;
    if ((getWaitUntilVisibleMethod = NativeAutomatorGrpc.getWaitUntilVisibleMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getWaitUntilVisibleMethod = NativeAutomatorGrpc.getWaitUntilVisibleMethod) == null) {
          NativeAutomatorGrpc.getWaitUntilVisibleMethod = getWaitUntilVisibleMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "waitUntilVisible"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getWaitUntilVisibleMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableAirplaneModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableAirplaneMode",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableAirplaneModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getEnableAirplaneModeMethod;
    if ((getEnableAirplaneModeMethod = NativeAutomatorGrpc.getEnableAirplaneModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableAirplaneModeMethod = NativeAutomatorGrpc.getEnableAirplaneModeMethod) == null) {
          NativeAutomatorGrpc.getEnableAirplaneModeMethod = getEnableAirplaneModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableAirplaneMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getEnableAirplaneModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableAirplaneModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableAirplaneMode",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableAirplaneModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getDisableAirplaneModeMethod;
    if ((getDisableAirplaneModeMethod = NativeAutomatorGrpc.getDisableAirplaneModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableAirplaneModeMethod = NativeAutomatorGrpc.getDisableAirplaneModeMethod) == null) {
          NativeAutomatorGrpc.getDisableAirplaneModeMethod = getDisableAirplaneModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableAirplaneMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDisableAirplaneModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableWiFiMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableWiFi",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableWiFiMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getEnableWiFiMethod;
    if ((getEnableWiFiMethod = NativeAutomatorGrpc.getEnableWiFiMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableWiFiMethod = NativeAutomatorGrpc.getEnableWiFiMethod) == null) {
          NativeAutomatorGrpc.getEnableWiFiMethod = getEnableWiFiMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableWiFi"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getEnableWiFiMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableWiFiMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableWiFi",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableWiFiMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getDisableWiFiMethod;
    if ((getDisableWiFiMethod = NativeAutomatorGrpc.getDisableWiFiMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableWiFiMethod = NativeAutomatorGrpc.getDisableWiFiMethod) == null) {
          NativeAutomatorGrpc.getDisableWiFiMethod = getDisableWiFiMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableWiFi"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDisableWiFiMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableCellularMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableCellular",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableCellularMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getEnableCellularMethod;
    if ((getEnableCellularMethod = NativeAutomatorGrpc.getEnableCellularMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableCellularMethod = NativeAutomatorGrpc.getEnableCellularMethod) == null) {
          NativeAutomatorGrpc.getEnableCellularMethod = getEnableCellularMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableCellular"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getEnableCellularMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableCellularMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableCellular",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableCellularMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getDisableCellularMethod;
    if ((getDisableCellularMethod = NativeAutomatorGrpc.getDisableCellularMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableCellularMethod = NativeAutomatorGrpc.getDisableCellularMethod) == null) {
          NativeAutomatorGrpc.getDisableCellularMethod = getDisableCellularMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableCellular"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDisableCellularMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableBluetoothMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableBluetooth",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableBluetoothMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getEnableBluetoothMethod;
    if ((getEnableBluetoothMethod = NativeAutomatorGrpc.getEnableBluetoothMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableBluetoothMethod = NativeAutomatorGrpc.getEnableBluetoothMethod) == null) {
          NativeAutomatorGrpc.getEnableBluetoothMethod = getEnableBluetoothMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableBluetooth"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getEnableBluetoothMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableBluetoothMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableBluetooth",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableBluetoothMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getDisableBluetoothMethod;
    if ((getDisableBluetoothMethod = NativeAutomatorGrpc.getDisableBluetoothMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableBluetoothMethod = NativeAutomatorGrpc.getDisableBluetoothMethod) == null) {
          NativeAutomatorGrpc.getDisableBluetoothMethod = getDisableBluetoothMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableBluetooth"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDisableBluetoothMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.DarkModeRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableDarkModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableDarkMode",
      requestType = pl.leancode.patrol.contracts.Contracts.DarkModeRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.DarkModeRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getEnableDarkModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.DarkModeRequest, pl.leancode.patrol.contracts.Contracts.Empty> getEnableDarkModeMethod;
    if ((getEnableDarkModeMethod = NativeAutomatorGrpc.getEnableDarkModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableDarkModeMethod = NativeAutomatorGrpc.getEnableDarkModeMethod) == null) {
          NativeAutomatorGrpc.getEnableDarkModeMethod = getEnableDarkModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.DarkModeRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableDarkMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.DarkModeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getEnableDarkModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.DarkModeRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableDarkModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableDarkMode",
      requestType = pl.leancode.patrol.contracts.Contracts.DarkModeRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.DarkModeRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getDisableDarkModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.DarkModeRequest, pl.leancode.patrol.contracts.Contracts.Empty> getDisableDarkModeMethod;
    if ((getDisableDarkModeMethod = NativeAutomatorGrpc.getDisableDarkModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableDarkModeMethod = NativeAutomatorGrpc.getDisableDarkModeMethod) == null) {
          NativeAutomatorGrpc.getDisableDarkModeMethod = getDisableDarkModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.DarkModeRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableDarkMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.DarkModeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDisableDarkModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getOpenNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openNotifications",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getOpenNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getOpenNotificationsMethod;
    if ((getOpenNotificationsMethod = NativeAutomatorGrpc.getOpenNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenNotificationsMethod = NativeAutomatorGrpc.getOpenNotificationsMethod) == null) {
          NativeAutomatorGrpc.getOpenNotificationsMethod = getOpenNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getOpenNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getCloseNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "closeNotifications",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getCloseNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getCloseNotificationsMethod;
    if ((getCloseNotificationsMethod = NativeAutomatorGrpc.getCloseNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getCloseNotificationsMethod = NativeAutomatorGrpc.getCloseNotificationsMethod) == null) {
          NativeAutomatorGrpc.getCloseNotificationsMethod = getCloseNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "closeNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getCloseNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getCloseHeadsUpNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "closeHeadsUpNotification",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getCloseHeadsUpNotificationMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getCloseHeadsUpNotificationMethod;
    if ((getCloseHeadsUpNotificationMethod = NativeAutomatorGrpc.getCloseHeadsUpNotificationMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getCloseHeadsUpNotificationMethod = NativeAutomatorGrpc.getCloseHeadsUpNotificationMethod) == null) {
          NativeAutomatorGrpc.getCloseHeadsUpNotificationMethod = getCloseHeadsUpNotificationMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "closeHeadsUpNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getCloseHeadsUpNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest,
      pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse> getGetNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "getNotifications",
      requestType = pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest,
      pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse> getGetNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest, pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse> getGetNotificationsMethod;
    if ((getGetNotificationsMethod = NativeAutomatorGrpc.getGetNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getGetNotificationsMethod = NativeAutomatorGrpc.getGetNotificationsMethod) == null) {
          NativeAutomatorGrpc.getGetNotificationsMethod = getGetNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest, pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "getNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse.getDefaultInstance()))
              .build();
        }
      }
    }
    return getGetNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getTapOnNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "tapOnNotification",
      requestType = pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getTapOnNotificationMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest, pl.leancode.patrol.contracts.Contracts.Empty> getTapOnNotificationMethod;
    if ((getTapOnNotificationMethod = NativeAutomatorGrpc.getTapOnNotificationMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getTapOnNotificationMethod = NativeAutomatorGrpc.getTapOnNotificationMethod) == null) {
          NativeAutomatorGrpc.getTapOnNotificationMethod = getTapOnNotificationMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "tapOnNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getTapOnNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest,
      pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse> getIsPermissionDialogVisibleMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "isPermissionDialogVisible",
      requestType = pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest,
      pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse> getIsPermissionDialogVisibleMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest, pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse> getIsPermissionDialogVisibleMethod;
    if ((getIsPermissionDialogVisibleMethod = NativeAutomatorGrpc.getIsPermissionDialogVisibleMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getIsPermissionDialogVisibleMethod = NativeAutomatorGrpc.getIsPermissionDialogVisibleMethod) == null) {
          NativeAutomatorGrpc.getIsPermissionDialogVisibleMethod = getIsPermissionDialogVisibleMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest, pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "isPermissionDialogVisible"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse.getDefaultInstance()))
              .build();
        }
      }
    }
    return getIsPermissionDialogVisibleMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getHandlePermissionDialogMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "handlePermissionDialog",
      requestType = pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getHandlePermissionDialogMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest, pl.leancode.patrol.contracts.Contracts.Empty> getHandlePermissionDialogMethod;
    if ((getHandlePermissionDialogMethod = NativeAutomatorGrpc.getHandlePermissionDialogMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getHandlePermissionDialogMethod = NativeAutomatorGrpc.getHandlePermissionDialogMethod) == null) {
          NativeAutomatorGrpc.getHandlePermissionDialogMethod = getHandlePermissionDialogMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "handlePermissionDialog"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getHandlePermissionDialogMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getSetLocationAccuracyMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "setLocationAccuracy",
      requestType = pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest,
      pl.leancode.patrol.contracts.Contracts.Empty> getSetLocationAccuracyMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest, pl.leancode.patrol.contracts.Contracts.Empty> getSetLocationAccuracyMethod;
    if ((getSetLocationAccuracyMethod = NativeAutomatorGrpc.getSetLocationAccuracyMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getSetLocationAccuracyMethod = NativeAutomatorGrpc.getSetLocationAccuracyMethod) == null) {
          NativeAutomatorGrpc.getSetLocationAccuracyMethod = getSetLocationAccuracyMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "setLocationAccuracy"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getSetLocationAccuracyMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDebugMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "debug",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getDebugMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getDebugMethod;
    if ((getDebugMethod = NativeAutomatorGrpc.getDebugMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDebugMethod = NativeAutomatorGrpc.getDebugMethod) == null) {
          NativeAutomatorGrpc.getDebugMethod = getDebugMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "debug"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getDebugMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getMarkPatrolAppServiceReadyMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "markPatrolAppServiceReady",
      requestType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      responseType = pl.leancode.patrol.contracts.Contracts.Empty.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty,
      pl.leancode.patrol.contracts.Contracts.Empty> getMarkPatrolAppServiceReadyMethod() {
    io.grpc.MethodDescriptor<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty> getMarkPatrolAppServiceReadyMethod;
    if ((getMarkPatrolAppServiceReadyMethod = NativeAutomatorGrpc.getMarkPatrolAppServiceReadyMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getMarkPatrolAppServiceReadyMethod = NativeAutomatorGrpc.getMarkPatrolAppServiceReadyMethod) == null) {
          NativeAutomatorGrpc.getMarkPatrolAppServiceReadyMethod = getMarkPatrolAppServiceReadyMethod =
              io.grpc.MethodDescriptor.<pl.leancode.patrol.contracts.Contracts.Empty, pl.leancode.patrol.contracts.Contracts.Empty>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "markPatrolAppServiceReady"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.lite.ProtoLiteUtils.marshaller(
                  pl.leancode.patrol.contracts.Contracts.Empty.getDefaultInstance()))
              .build();
        }
      }
    }
    return getMarkPatrolAppServiceReadyMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static NativeAutomatorStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NativeAutomatorStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NativeAutomatorStub>() {
        @java.lang.Override
        public NativeAutomatorStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NativeAutomatorStub(channel, callOptions);
        }
      };
    return NativeAutomatorStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static NativeAutomatorBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NativeAutomatorBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NativeAutomatorBlockingStub>() {
        @java.lang.Override
        public NativeAutomatorBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NativeAutomatorBlockingStub(channel, callOptions);
        }
      };
    return NativeAutomatorBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static NativeAutomatorFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<NativeAutomatorFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<NativeAutomatorFutureStub>() {
        @java.lang.Override
        public NativeAutomatorFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new NativeAutomatorFutureStub(channel, callOptions);
        }
      };
    return NativeAutomatorFutureStub.newStub(factory, channel);
  }

  /**
   */
  public static abstract class NativeAutomatorImplBase implements io.grpc.BindableService {

    /**
     */
    public void initialize(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getInitializeMethod(), responseObserver);
    }

    /**
     */
    public void configure(pl.leancode.patrol.contracts.Contracts.ConfigureRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getConfigureMethod(), responseObserver);
    }

    /**
     * <pre>
     * general
     * </pre>
     */
    public void pressHome(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressHomeMethod(), responseObserver);
    }

    /**
     */
    public void pressBack(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressBackMethod(), responseObserver);
    }

    /**
     */
    public void pressRecentApps(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressRecentAppsMethod(), responseObserver);
    }

    /**
     */
    public void doublePressRecentApps(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDoublePressRecentAppsMethod(), responseObserver);
    }

    /**
     */
    public void openApp(pl.leancode.patrol.contracts.Contracts.OpenAppRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenAppMethod(), responseObserver);
    }

    /**
     */
    public void openQuickSettings(pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenQuickSettingsMethod(), responseObserver);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public void getNativeViews(pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNativeViewsMethod(), responseObserver);
    }

    /**
     */
    public void tap(pl.leancode.patrol.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getTapMethod(), responseObserver);
    }

    /**
     */
    public void doubleTap(pl.leancode.patrol.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDoubleTapMethod(), responseObserver);
    }

    /**
     */
    public void enterText(pl.leancode.patrol.contracts.Contracts.EnterTextRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnterTextMethod(), responseObserver);
    }

    /**
     */
    public void swipe(pl.leancode.patrol.contracts.Contracts.SwipeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSwipeMethod(), responseObserver);
    }

    /**
     */
    public void waitUntilVisible(pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getWaitUntilVisibleMethod(), responseObserver);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public void enableAirplaneMode(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableAirplaneModeMethod(), responseObserver);
    }

    /**
     */
    public void disableAirplaneMode(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableAirplaneModeMethod(), responseObserver);
    }

    /**
     */
    public void enableWiFi(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableWiFiMethod(), responseObserver);
    }

    /**
     */
    public void disableWiFi(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableWiFiMethod(), responseObserver);
    }

    /**
     */
    public void enableCellular(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableCellularMethod(), responseObserver);
    }

    /**
     */
    public void disableCellular(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableCellularMethod(), responseObserver);
    }

    /**
     */
    public void enableBluetooth(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableBluetoothMethod(), responseObserver);
    }

    /**
     */
    public void disableBluetooth(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableBluetoothMethod(), responseObserver);
    }

    /**
     */
    public void enableDarkMode(pl.leancode.patrol.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableDarkModeMethod(), responseObserver);
    }

    /**
     */
    public void disableDarkMode(pl.leancode.patrol.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableDarkModeMethod(), responseObserver);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public void openNotifications(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void closeNotifications(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCloseNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void closeHeadsUpNotification(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCloseHeadsUpNotificationMethod(), responseObserver);
    }

    /**
     */
    public void getNotifications(pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void tapOnNotification(pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getTapOnNotificationMethod(), responseObserver);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public void isPermissionDialogVisible(pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getIsPermissionDialogVisibleMethod(), responseObserver);
    }

    /**
     */
    public void handlePermissionDialog(pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getHandlePermissionDialogMethod(), responseObserver);
    }

    /**
     */
    public void setLocationAccuracy(pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSetLocationAccuracyMethod(), responseObserver);
    }

    /**
     * <pre>
     * other
     * </pre>
     */
    public void debug(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDebugMethod(), responseObserver);
    }

    /**
     * <pre>
     * TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
     * </pre>
     */
    public void markPatrolAppServiceReady(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getMarkPatrolAppServiceReadyMethod(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getInitializeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_INITIALIZE)))
          .addMethod(
            getConfigureMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.ConfigureRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_CONFIGURE)))
          .addMethod(
            getPressHomeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_PRESS_HOME)))
          .addMethod(
            getPressBackMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_PRESS_BACK)))
          .addMethod(
            getPressRecentAppsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_PRESS_RECENT_APPS)))
          .addMethod(
            getDoublePressRecentAppsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DOUBLE_PRESS_RECENT_APPS)))
          .addMethod(
            getOpenAppMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.OpenAppRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_OPEN_APP)))
          .addMethod(
            getOpenQuickSettingsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_OPEN_QUICK_SETTINGS)))
          .addMethod(
            getGetNativeViewsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest,
                pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse>(
                  this, METHODID_GET_NATIVE_VIEWS)))
          .addMethod(
            getTapMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.TapRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_TAP)))
          .addMethod(
            getDoubleTapMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.TapRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DOUBLE_TAP)))
          .addMethod(
            getEnterTextMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.EnterTextRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_ENTER_TEXT)))
          .addMethod(
            getSwipeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.SwipeRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_SWIPE)))
          .addMethod(
            getWaitUntilVisibleMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_WAIT_UNTIL_VISIBLE)))
          .addMethod(
            getEnableAirplaneModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_ENABLE_AIRPLANE_MODE)))
          .addMethod(
            getDisableAirplaneModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DISABLE_AIRPLANE_MODE)))
          .addMethod(
            getEnableWiFiMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_ENABLE_WI_FI)))
          .addMethod(
            getDisableWiFiMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DISABLE_WI_FI)))
          .addMethod(
            getEnableCellularMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_ENABLE_CELLULAR)))
          .addMethod(
            getDisableCellularMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DISABLE_CELLULAR)))
          .addMethod(
            getEnableBluetoothMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_ENABLE_BLUETOOTH)))
          .addMethod(
            getDisableBluetoothMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DISABLE_BLUETOOTH)))
          .addMethod(
            getEnableDarkModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.DarkModeRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_ENABLE_DARK_MODE)))
          .addMethod(
            getDisableDarkModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.DarkModeRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DISABLE_DARK_MODE)))
          .addMethod(
            getOpenNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_OPEN_NOTIFICATIONS)))
          .addMethod(
            getCloseNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_CLOSE_NOTIFICATIONS)))
          .addMethod(
            getCloseHeadsUpNotificationMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_CLOSE_HEADS_UP_NOTIFICATION)))
          .addMethod(
            getGetNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest,
                pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse>(
                  this, METHODID_GET_NOTIFICATIONS)))
          .addMethod(
            getTapOnNotificationMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_TAP_ON_NOTIFICATION)))
          .addMethod(
            getIsPermissionDialogVisibleMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest,
                pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse>(
                  this, METHODID_IS_PERMISSION_DIALOG_VISIBLE)))
          .addMethod(
            getHandlePermissionDialogMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_HANDLE_PERMISSION_DIALOG)))
          .addMethod(
            getSetLocationAccuracyMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_SET_LOCATION_ACCURACY)))
          .addMethod(
            getDebugMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_DEBUG)))
          .addMethod(
            getMarkPatrolAppServiceReadyMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.patrol.contracts.Contracts.Empty,
                pl.leancode.patrol.contracts.Contracts.Empty>(
                  this, METHODID_MARK_PATROL_APP_SERVICE_READY)))
          .build();
    }
  }

  /**
   */
  public static final class NativeAutomatorStub extends io.grpc.stub.AbstractAsyncStub<NativeAutomatorStub> {
    private NativeAutomatorStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NativeAutomatorStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NativeAutomatorStub(channel, callOptions);
    }

    /**
     */
    public void initialize(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getInitializeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void configure(pl.leancode.patrol.contracts.Contracts.ConfigureRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getConfigureMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * general
     * </pre>
     */
    public void pressHome(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressHomeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void pressBack(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressBackMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void pressRecentApps(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressRecentAppsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void doublePressRecentApps(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDoublePressRecentAppsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openApp(pl.leancode.patrol.contracts.Contracts.OpenAppRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenAppMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openQuickSettings(pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenQuickSettingsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public void getNativeViews(pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetNativeViewsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void tap(pl.leancode.patrol.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getTapMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void doubleTap(pl.leancode.patrol.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDoubleTapMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enterText(pl.leancode.patrol.contracts.Contracts.EnterTextRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnterTextMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void swipe(pl.leancode.patrol.contracts.Contracts.SwipeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSwipeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void waitUntilVisible(pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getWaitUntilVisibleMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public void enableAirplaneMode(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableAirplaneModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableAirplaneMode(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableAirplaneModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableWiFi(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableWiFiMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableWiFi(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableWiFiMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableCellular(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableCellularMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableCellular(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableCellularMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableBluetooth(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableBluetoothMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableBluetooth(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableBluetoothMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableDarkMode(pl.leancode.patrol.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableDarkModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableDarkMode(pl.leancode.patrol.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableDarkModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public void openNotifications(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void closeNotifications(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCloseNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void closeHeadsUpNotification(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCloseHeadsUpNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void getNotifications(pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void tapOnNotification(pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getTapOnNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public void isPermissionDialogVisible(pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getIsPermissionDialogVisibleMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void handlePermissionDialog(pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getHandlePermissionDialogMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void setLocationAccuracy(pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSetLocationAccuracyMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * other
     * </pre>
     */
    public void debug(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDebugMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
     * </pre>
     */
    public void markPatrolAppServiceReady(pl.leancode.patrol.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getMarkPatrolAppServiceReadyMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   */
  public static final class NativeAutomatorBlockingStub extends io.grpc.stub.AbstractBlockingStub<NativeAutomatorBlockingStub> {
    private NativeAutomatorBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NativeAutomatorBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NativeAutomatorBlockingStub(channel, callOptions);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty initialize(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getInitializeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty configure(pl.leancode.patrol.contracts.Contracts.ConfigureRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getConfigureMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * general
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.Empty pressHome(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressHomeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty pressBack(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressBackMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty pressRecentApps(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressRecentAppsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty doublePressRecentApps(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDoublePressRecentAppsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty openApp(pl.leancode.patrol.contracts.Contracts.OpenAppRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenAppMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty openQuickSettings(pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenQuickSettingsMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse getNativeViews(pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNativeViewsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty tap(pl.leancode.patrol.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getTapMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty doubleTap(pl.leancode.patrol.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDoubleTapMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty enterText(pl.leancode.patrol.contracts.Contracts.EnterTextRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnterTextMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty swipe(pl.leancode.patrol.contracts.Contracts.SwipeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSwipeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty waitUntilVisible(pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getWaitUntilVisibleMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.Empty enableAirplaneMode(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableAirplaneModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty disableAirplaneMode(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableAirplaneModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty enableWiFi(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableWiFiMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty disableWiFi(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableWiFiMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty enableCellular(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableCellularMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty disableCellular(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableCellularMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty enableBluetooth(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableBluetoothMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty disableBluetooth(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableBluetoothMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty enableDarkMode(pl.leancode.patrol.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableDarkModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty disableDarkMode(pl.leancode.patrol.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableDarkModeMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.Empty openNotifications(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty closeNotifications(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCloseNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty closeHeadsUpNotification(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCloseHeadsUpNotificationMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse getNotifications(pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty tapOnNotification(pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getTapOnNotificationMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse isPermissionDialogVisible(pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getIsPermissionDialogVisibleMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty handlePermissionDialog(pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getHandlePermissionDialogMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.patrol.contracts.Contracts.Empty setLocationAccuracy(pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSetLocationAccuracyMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * other
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.Empty debug(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDebugMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
     * </pre>
     */
    public pl.leancode.patrol.contracts.Contracts.Empty markPatrolAppServiceReady(pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getMarkPatrolAppServiceReadyMethod(), getCallOptions(), request);
    }
  }

  /**
   */
  public static final class NativeAutomatorFutureStub extends io.grpc.stub.AbstractFutureStub<NativeAutomatorFutureStub> {
    private NativeAutomatorFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected NativeAutomatorFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new NativeAutomatorFutureStub(channel, callOptions);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> initialize(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getInitializeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> configure(
        pl.leancode.patrol.contracts.Contracts.ConfigureRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getConfigureMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * general
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> pressHome(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressHomeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> pressBack(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressBackMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> pressRecentApps(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressRecentAppsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> doublePressRecentApps(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDoublePressRecentAppsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> openApp(
        pl.leancode.patrol.contracts.Contracts.OpenAppRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenAppMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> openQuickSettings(
        pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenQuickSettingsMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse> getNativeViews(
        pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetNativeViewsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> tap(
        pl.leancode.patrol.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getTapMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> doubleTap(
        pl.leancode.patrol.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDoubleTapMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> enterText(
        pl.leancode.patrol.contracts.Contracts.EnterTextRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnterTextMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> swipe(
        pl.leancode.patrol.contracts.Contracts.SwipeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSwipeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> waitUntilVisible(
        pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getWaitUntilVisibleMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> enableAirplaneMode(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableAirplaneModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> disableAirplaneMode(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableAirplaneModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> enableWiFi(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableWiFiMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> disableWiFi(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableWiFiMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> enableCellular(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableCellularMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> disableCellular(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableCellularMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> enableBluetooth(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableBluetoothMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> disableBluetooth(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableBluetoothMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> enableDarkMode(
        pl.leancode.patrol.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableDarkModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> disableDarkMode(
        pl.leancode.patrol.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableDarkModeMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> openNotifications(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> closeNotifications(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCloseNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> closeHeadsUpNotification(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCloseHeadsUpNotificationMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse> getNotifications(
        pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> tapOnNotification(
        pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getTapOnNotificationMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse> isPermissionDialogVisible(
        pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getIsPermissionDialogVisibleMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> handlePermissionDialog(
        pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getHandlePermissionDialogMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> setLocationAccuracy(
        pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSetLocationAccuracyMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * other
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> debug(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDebugMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * TODO(bartekpacia): Move this RPC into a new PatrolNativeTestService service because it doesn't fit here
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.patrol.contracts.Contracts.Empty> markPatrolAppServiceReady(
        pl.leancode.patrol.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getMarkPatrolAppServiceReadyMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_INITIALIZE = 0;
  private static final int METHODID_CONFIGURE = 1;
  private static final int METHODID_PRESS_HOME = 2;
  private static final int METHODID_PRESS_BACK = 3;
  private static final int METHODID_PRESS_RECENT_APPS = 4;
  private static final int METHODID_DOUBLE_PRESS_RECENT_APPS = 5;
  private static final int METHODID_OPEN_APP = 6;
  private static final int METHODID_OPEN_QUICK_SETTINGS = 7;
  private static final int METHODID_GET_NATIVE_VIEWS = 8;
  private static final int METHODID_TAP = 9;
  private static final int METHODID_DOUBLE_TAP = 10;
  private static final int METHODID_ENTER_TEXT = 11;
  private static final int METHODID_SWIPE = 12;
  private static final int METHODID_WAIT_UNTIL_VISIBLE = 13;
  private static final int METHODID_ENABLE_AIRPLANE_MODE = 14;
  private static final int METHODID_DISABLE_AIRPLANE_MODE = 15;
  private static final int METHODID_ENABLE_WI_FI = 16;
  private static final int METHODID_DISABLE_WI_FI = 17;
  private static final int METHODID_ENABLE_CELLULAR = 18;
  private static final int METHODID_DISABLE_CELLULAR = 19;
  private static final int METHODID_ENABLE_BLUETOOTH = 20;
  private static final int METHODID_DISABLE_BLUETOOTH = 21;
  private static final int METHODID_ENABLE_DARK_MODE = 22;
  private static final int METHODID_DISABLE_DARK_MODE = 23;
  private static final int METHODID_OPEN_NOTIFICATIONS = 24;
  private static final int METHODID_CLOSE_NOTIFICATIONS = 25;
  private static final int METHODID_CLOSE_HEADS_UP_NOTIFICATION = 26;
  private static final int METHODID_GET_NOTIFICATIONS = 27;
  private static final int METHODID_TAP_ON_NOTIFICATION = 28;
  private static final int METHODID_IS_PERMISSION_DIALOG_VISIBLE = 29;
  private static final int METHODID_HANDLE_PERMISSION_DIALOG = 30;
  private static final int METHODID_SET_LOCATION_ACCURACY = 31;
  private static final int METHODID_DEBUG = 32;
  private static final int METHODID_MARK_PATROL_APP_SERVICE_READY = 33;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final NativeAutomatorImplBase serviceImpl;
    private final int methodId;

    MethodHandlers(NativeAutomatorImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_INITIALIZE:
          serviceImpl.initialize((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_CONFIGURE:
          serviceImpl.configure((pl.leancode.patrol.contracts.Contracts.ConfigureRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_PRESS_HOME:
          serviceImpl.pressHome((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_PRESS_BACK:
          serviceImpl.pressBack((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_PRESS_RECENT_APPS:
          serviceImpl.pressRecentApps((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DOUBLE_PRESS_RECENT_APPS:
          serviceImpl.doublePressRecentApps((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_OPEN_APP:
          serviceImpl.openApp((pl.leancode.patrol.contracts.Contracts.OpenAppRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_OPEN_QUICK_SETTINGS:
          serviceImpl.openQuickSettings((pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_GET_NATIVE_VIEWS:
          serviceImpl.getNativeViews((pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse>) responseObserver);
          break;
        case METHODID_TAP:
          serviceImpl.tap((pl.leancode.patrol.contracts.Contracts.TapRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DOUBLE_TAP:
          serviceImpl.doubleTap((pl.leancode.patrol.contracts.Contracts.TapRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_ENTER_TEXT:
          serviceImpl.enterText((pl.leancode.patrol.contracts.Contracts.EnterTextRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_SWIPE:
          serviceImpl.swipe((pl.leancode.patrol.contracts.Contracts.SwipeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_WAIT_UNTIL_VISIBLE:
          serviceImpl.waitUntilVisible((pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_ENABLE_AIRPLANE_MODE:
          serviceImpl.enableAirplaneMode((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DISABLE_AIRPLANE_MODE:
          serviceImpl.disableAirplaneMode((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_ENABLE_WI_FI:
          serviceImpl.enableWiFi((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DISABLE_WI_FI:
          serviceImpl.disableWiFi((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_ENABLE_CELLULAR:
          serviceImpl.enableCellular((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DISABLE_CELLULAR:
          serviceImpl.disableCellular((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_ENABLE_BLUETOOTH:
          serviceImpl.enableBluetooth((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DISABLE_BLUETOOTH:
          serviceImpl.disableBluetooth((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_ENABLE_DARK_MODE:
          serviceImpl.enableDarkMode((pl.leancode.patrol.contracts.Contracts.DarkModeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DISABLE_DARK_MODE:
          serviceImpl.disableDarkMode((pl.leancode.patrol.contracts.Contracts.DarkModeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_OPEN_NOTIFICATIONS:
          serviceImpl.openNotifications((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_CLOSE_NOTIFICATIONS:
          serviceImpl.closeNotifications((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_CLOSE_HEADS_UP_NOTIFICATION:
          serviceImpl.closeHeadsUpNotification((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_GET_NOTIFICATIONS:
          serviceImpl.getNotifications((pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse>) responseObserver);
          break;
        case METHODID_TAP_ON_NOTIFICATION:
          serviceImpl.tapOnNotification((pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_IS_PERMISSION_DIALOG_VISIBLE:
          serviceImpl.isPermissionDialogVisible((pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse>) responseObserver);
          break;
        case METHODID_HANDLE_PERMISSION_DIALOG:
          serviceImpl.handlePermissionDialog((pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_SET_LOCATION_ACCURACY:
          serviceImpl.setLocationAccuracy((pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_DEBUG:
          serviceImpl.debug((pl.leancode.patrol.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.patrol.contracts.Contracts.Empty>) responseObserver);
          break;
        case METHODID_MARK_PATROL_APP_SERVICE_READY:
          serviceImpl.markPatrolAppServiceReady((pl.leancode.patrol.contracts.Contracts.Empty) request,
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
      synchronized (NativeAutomatorGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .addMethod(getInitializeMethod())
              .addMethod(getConfigureMethod())
              .addMethod(getPressHomeMethod())
              .addMethod(getPressBackMethod())
              .addMethod(getPressRecentAppsMethod())
              .addMethod(getDoublePressRecentAppsMethod())
              .addMethod(getOpenAppMethod())
              .addMethod(getOpenQuickSettingsMethod())
              .addMethod(getGetNativeViewsMethod())
              .addMethod(getTapMethod())
              .addMethod(getDoubleTapMethod())
              .addMethod(getEnterTextMethod())
              .addMethod(getSwipeMethod())
              .addMethod(getWaitUntilVisibleMethod())
              .addMethod(getEnableAirplaneModeMethod())
              .addMethod(getDisableAirplaneModeMethod())
              .addMethod(getEnableWiFiMethod())
              .addMethod(getDisableWiFiMethod())
              .addMethod(getEnableCellularMethod())
              .addMethod(getDisableCellularMethod())
              .addMethod(getEnableBluetoothMethod())
              .addMethod(getDisableBluetoothMethod())
              .addMethod(getEnableDarkModeMethod())
              .addMethod(getDisableDarkModeMethod())
              .addMethod(getOpenNotificationsMethod())
              .addMethod(getCloseNotificationsMethod())
              .addMethod(getCloseHeadsUpNotificationMethod())
              .addMethod(getGetNotificationsMethod())
              .addMethod(getTapOnNotificationMethod())
              .addMethod(getIsPermissionDialogVisibleMethod())
              .addMethod(getHandlePermissionDialogMethod())
              .addMethod(getSetLocationAccuracyMethod())
              .addMethod(getDebugMethod())
              .addMethod(getMarkPatrolAppServiceReadyMethod())
              .build();
        }
      }
    }
    return result;
  }
}
