package pl.leancode.automatorserver.contracts;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 * <pre>
 * general
 * </pre>
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.49.1)",
    comments = "Source: contracts.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class NativeAutomatorGrpc {

  private NativeAutomatorGrpc() {}

  public static final String SERVICE_NAME = "patrol.NativeAutomator";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressHomeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressHome",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressHomeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressHomeMethod;
    if ((getPressHomeMethod = NativeAutomatorGrpc.getPressHomeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressHomeMethod = NativeAutomatorGrpc.getPressHomeMethod) == null) {
          NativeAutomatorGrpc.getPressHomeMethod = getPressHomeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressHome"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("pressHome"))
              .build();
        }
      }
    }
    return getPressHomeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressBackMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressBack",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressBackMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressBackMethod;
    if ((getPressBackMethod = NativeAutomatorGrpc.getPressBackMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressBackMethod = NativeAutomatorGrpc.getPressBackMethod) == null) {
          NativeAutomatorGrpc.getPressBackMethod = getPressBackMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressBack"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("pressBack"))
              .build();
        }
      }
    }
    return getPressBackMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressRecentAppsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressRecentApps",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressRecentAppsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getPressRecentAppsMethod;
    if ((getPressRecentAppsMethod = NativeAutomatorGrpc.getPressRecentAppsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressRecentAppsMethod = NativeAutomatorGrpc.getPressRecentAppsMethod) == null) {
          NativeAutomatorGrpc.getPressRecentAppsMethod = getPressRecentAppsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressRecentApps"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("pressRecentApps"))
              .build();
        }
      }
    }
    return getPressRecentAppsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDoublePressRecentAppsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "doublePressRecentApps",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDoublePressRecentAppsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDoublePressRecentAppsMethod;
    if ((getDoublePressRecentAppsMethod = NativeAutomatorGrpc.getDoublePressRecentAppsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDoublePressRecentAppsMethod = NativeAutomatorGrpc.getDoublePressRecentAppsMethod) == null) {
          NativeAutomatorGrpc.getDoublePressRecentAppsMethod = getDoublePressRecentAppsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "doublePressRecentApps"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("doublePressRecentApps"))
              .build();
        }
      }
    }
    return getDoublePressRecentAppsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenAppMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openApp",
      requestType = pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenAppMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenAppMethod;
    if ((getOpenAppMethod = NativeAutomatorGrpc.getOpenAppMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenAppMethod = NativeAutomatorGrpc.getOpenAppMethod) == null) {
          NativeAutomatorGrpc.getOpenAppMethod = getOpenAppMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openApp"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("openApp"))
              .build();
        }
      }
    }
    return getOpenAppMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenQuickSettingsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openQuickSettings",
      requestType = pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenQuickSettingsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenQuickSettingsMethod;
    if ((getOpenQuickSettingsMethod = NativeAutomatorGrpc.getOpenQuickSettingsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenQuickSettingsMethod = NativeAutomatorGrpc.getOpenQuickSettingsMethod) == null) {
          NativeAutomatorGrpc.getOpenQuickSettingsMethod = getOpenQuickSettingsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openQuickSettings"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("openQuickSettings"))
              .build();
        }
      }
    }
    return getOpenQuickSettingsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest,
      pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse> getGetNativeViewsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "getNativeViews",
      requestType = pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest,
      pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse> getGetNativeViewsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest, pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse> getGetNativeViewsMethod;
    if ((getGetNativeViewsMethod = NativeAutomatorGrpc.getGetNativeViewsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getGetNativeViewsMethod = NativeAutomatorGrpc.getGetNativeViewsMethod) == null) {
          NativeAutomatorGrpc.getGetNativeViewsMethod = getGetNativeViewsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest, pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "getNativeViews"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("getNativeViews"))
              .build();
        }
      }
    }
    return getGetNativeViewsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getTapMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "tap",
      requestType = pl.leancode.automatorserver.contracts.Contracts.TapRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getTapMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getTapMethod;
    if ((getTapMethod = NativeAutomatorGrpc.getTapMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getTapMethod = NativeAutomatorGrpc.getTapMethod) == null) {
          NativeAutomatorGrpc.getTapMethod = getTapMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "tap"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("tap"))
              .build();
        }
      }
    }
    return getTapMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDoubleTapMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "doubleTap",
      requestType = pl.leancode.automatorserver.contracts.Contracts.TapRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDoubleTapMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDoubleTapMethod;
    if ((getDoubleTapMethod = NativeAutomatorGrpc.getDoubleTapMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDoubleTapMethod = NativeAutomatorGrpc.getDoubleTapMethod) == null) {
          NativeAutomatorGrpc.getDoubleTapMethod = getDoubleTapMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "doubleTap"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("doubleTap"))
              .build();
        }
      }
    }
    return getDoubleTapMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnterTextMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enterText",
      requestType = pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnterTextMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnterTextMethod;
    if ((getEnterTextMethod = NativeAutomatorGrpc.getEnterTextMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnterTextMethod = NativeAutomatorGrpc.getEnterTextMethod) == null) {
          NativeAutomatorGrpc.getEnterTextMethod = getEnterTextMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enterText"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enterText"))
              .build();
        }
      }
    }
    return getEnterTextMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getSwipeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "swipe",
      requestType = pl.leancode.automatorserver.contracts.Contracts.SwipeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getSwipeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getSwipeMethod;
    if ((getSwipeMethod = NativeAutomatorGrpc.getSwipeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getSwipeMethod = NativeAutomatorGrpc.getSwipeMethod) == null) {
          NativeAutomatorGrpc.getSwipeMethod = getSwipeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "swipe"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.SwipeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("swipe"))
              .build();
        }
      }
    }
    return getSwipeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableAirplaneModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableAirplaneMode",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableAirplaneModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableAirplaneModeMethod;
    if ((getEnableAirplaneModeMethod = NativeAutomatorGrpc.getEnableAirplaneModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableAirplaneModeMethod = NativeAutomatorGrpc.getEnableAirplaneModeMethod) == null) {
          NativeAutomatorGrpc.getEnableAirplaneModeMethod = getEnableAirplaneModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableAirplaneMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableAirplaneMode"))
              .build();
        }
      }
    }
    return getEnableAirplaneModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableAirplaneModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableAirplaneMode",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableAirplaneModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableAirplaneModeMethod;
    if ((getDisableAirplaneModeMethod = NativeAutomatorGrpc.getDisableAirplaneModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableAirplaneModeMethod = NativeAutomatorGrpc.getDisableAirplaneModeMethod) == null) {
          NativeAutomatorGrpc.getDisableAirplaneModeMethod = getDisableAirplaneModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableAirplaneMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableAirplaneMode"))
              .build();
        }
      }
    }
    return getDisableAirplaneModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableWiFiMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableWiFi",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableWiFiMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableWiFiMethod;
    if ((getEnableWiFiMethod = NativeAutomatorGrpc.getEnableWiFiMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableWiFiMethod = NativeAutomatorGrpc.getEnableWiFiMethod) == null) {
          NativeAutomatorGrpc.getEnableWiFiMethod = getEnableWiFiMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableWiFi"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableWiFi"))
              .build();
        }
      }
    }
    return getEnableWiFiMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableWiFiMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableWiFi",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableWiFiMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableWiFiMethod;
    if ((getDisableWiFiMethod = NativeAutomatorGrpc.getDisableWiFiMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableWiFiMethod = NativeAutomatorGrpc.getDisableWiFiMethod) == null) {
          NativeAutomatorGrpc.getDisableWiFiMethod = getDisableWiFiMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableWiFi"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableWiFi"))
              .build();
        }
      }
    }
    return getDisableWiFiMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableCellularMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableCellular",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableCellularMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableCellularMethod;
    if ((getEnableCellularMethod = NativeAutomatorGrpc.getEnableCellularMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableCellularMethod = NativeAutomatorGrpc.getEnableCellularMethod) == null) {
          NativeAutomatorGrpc.getEnableCellularMethod = getEnableCellularMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableCellular"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableCellular"))
              .build();
        }
      }
    }
    return getEnableCellularMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableCellularMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableCellular",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableCellularMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableCellularMethod;
    if ((getDisableCellularMethod = NativeAutomatorGrpc.getDisableCellularMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableCellularMethod = NativeAutomatorGrpc.getDisableCellularMethod) == null) {
          NativeAutomatorGrpc.getDisableCellularMethod = getDisableCellularMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableCellular"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableCellular"))
              .build();
        }
      }
    }
    return getDisableCellularMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableBluetoothMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableBluetooth",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableBluetoothMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableBluetoothMethod;
    if ((getEnableBluetoothMethod = NativeAutomatorGrpc.getEnableBluetoothMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableBluetoothMethod = NativeAutomatorGrpc.getEnableBluetoothMethod) == null) {
          NativeAutomatorGrpc.getEnableBluetoothMethod = getEnableBluetoothMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableBluetooth"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableBluetooth"))
              .build();
        }
      }
    }
    return getEnableBluetoothMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableBluetoothMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableBluetooth",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableBluetoothMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableBluetoothMethod;
    if ((getDisableBluetoothMethod = NativeAutomatorGrpc.getDisableBluetoothMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableBluetoothMethod = NativeAutomatorGrpc.getDisableBluetoothMethod) == null) {
          NativeAutomatorGrpc.getDisableBluetoothMethod = getDisableBluetoothMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableBluetooth"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableBluetooth"))
              .build();
        }
      }
    }
    return getDisableBluetoothMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableDarkModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableDarkMode",
      requestType = pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableDarkModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getEnableDarkModeMethod;
    if ((getEnableDarkModeMethod = NativeAutomatorGrpc.getEnableDarkModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableDarkModeMethod = NativeAutomatorGrpc.getEnableDarkModeMethod) == null) {
          NativeAutomatorGrpc.getEnableDarkModeMethod = getEnableDarkModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableDarkMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableDarkMode"))
              .build();
        }
      }
    }
    return getEnableDarkModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableDarkModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableDarkMode",
      requestType = pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableDarkModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDisableDarkModeMethod;
    if ((getDisableDarkModeMethod = NativeAutomatorGrpc.getDisableDarkModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableDarkModeMethod = NativeAutomatorGrpc.getDisableDarkModeMethod) == null) {
          NativeAutomatorGrpc.getDisableDarkModeMethod = getDisableDarkModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableDarkMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableDarkMode"))
              .build();
        }
      }
    }
    return getDisableDarkModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openNotifications",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getOpenNotificationsMethod;
    if ((getOpenNotificationsMethod = NativeAutomatorGrpc.getOpenNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenNotificationsMethod = NativeAutomatorGrpc.getOpenNotificationsMethod) == null) {
          NativeAutomatorGrpc.getOpenNotificationsMethod = getOpenNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("openNotifications"))
              .build();
        }
      }
    }
    return getOpenNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getCloseNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "closeNotifications",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getCloseNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getCloseNotificationsMethod;
    if ((getCloseNotificationsMethod = NativeAutomatorGrpc.getCloseNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getCloseNotificationsMethod = NativeAutomatorGrpc.getCloseNotificationsMethod) == null) {
          NativeAutomatorGrpc.getCloseNotificationsMethod = getCloseNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "closeNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("closeNotifications"))
              .build();
        }
      }
    }
    return getCloseNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getCloseHeadsUpNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "closeHeadsUpNotification",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getCloseHeadsUpNotificationMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getCloseHeadsUpNotificationMethod;
    if ((getCloseHeadsUpNotificationMethod = NativeAutomatorGrpc.getCloseHeadsUpNotificationMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getCloseHeadsUpNotificationMethod = NativeAutomatorGrpc.getCloseHeadsUpNotificationMethod) == null) {
          NativeAutomatorGrpc.getCloseHeadsUpNotificationMethod = getCloseHeadsUpNotificationMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "closeHeadsUpNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("closeHeadsUpNotification"))
              .build();
        }
      }
    }
    return getCloseHeadsUpNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest,
      pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> getGetNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "getNotifications",
      requestType = pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest,
      pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> getGetNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest, pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> getGetNotificationsMethod;
    if ((getGetNotificationsMethod = NativeAutomatorGrpc.getGetNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getGetNotificationsMethod = NativeAutomatorGrpc.getGetNotificationsMethod) == null) {
          NativeAutomatorGrpc.getGetNotificationsMethod = getGetNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest, pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "getNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("getNotifications"))
              .build();
        }
      }
    }
    return getGetNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getTapOnNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "tapOnNotification",
      requestType = pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getTapOnNotificationMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getTapOnNotificationMethod;
    if ((getTapOnNotificationMethod = NativeAutomatorGrpc.getTapOnNotificationMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getTapOnNotificationMethod = NativeAutomatorGrpc.getTapOnNotificationMethod) == null) {
          NativeAutomatorGrpc.getTapOnNotificationMethod = getTapOnNotificationMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "tapOnNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("tapOnNotification"))
              .build();
        }
      }
    }
    return getTapOnNotificationMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getHandlePermissionDialogMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "handlePermissionDialog",
      requestType = pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getHandlePermissionDialogMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getHandlePermissionDialogMethod;
    if ((getHandlePermissionDialogMethod = NativeAutomatorGrpc.getHandlePermissionDialogMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getHandlePermissionDialogMethod = NativeAutomatorGrpc.getHandlePermissionDialogMethod) == null) {
          NativeAutomatorGrpc.getHandlePermissionDialogMethod = getHandlePermissionDialogMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "handlePermissionDialog"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("handlePermissionDialog"))
              .build();
        }
      }
    }
    return getHandlePermissionDialogMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getSetLocationAccuracyMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "setLocationAccuracy",
      requestType = pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getSetLocationAccuracyMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getSetLocationAccuracyMethod;
    if ((getSetLocationAccuracyMethod = NativeAutomatorGrpc.getSetLocationAccuracyMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getSetLocationAccuracyMethod = NativeAutomatorGrpc.getSetLocationAccuracyMethod) == null) {
          NativeAutomatorGrpc.getSetLocationAccuracyMethod = getSetLocationAccuracyMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "setLocationAccuracy"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("setLocationAccuracy"))
              .build();
        }
      }
    }
    return getSetLocationAccuracyMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDebugMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "debug",
      requestType = pl.leancode.automatorserver.contracts.Contracts.Empty.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty,
      pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDebugMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> getDebugMethod;
    if ((getDebugMethod = NativeAutomatorGrpc.getDebugMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDebugMethod = NativeAutomatorGrpc.getDebugMethod) == null) {
          NativeAutomatorGrpc.getDebugMethod = getDebugMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.Empty, pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "debug"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.Empty.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DefaultResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("debug"))
              .build();
        }
      }
    }
    return getDebugMethod;
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
   * <pre>
   * general
   * </pre>
   */
  public static abstract class NativeAutomatorImplBase implements io.grpc.BindableService {

    /**
     */
    public void pressHome(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressHomeMethod(), responseObserver);
    }

    /**
     */
    public void pressBack(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressBackMethod(), responseObserver);
    }

    /**
     */
    public void pressRecentApps(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressRecentAppsMethod(), responseObserver);
    }

    /**
     */
    public void doublePressRecentApps(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDoublePressRecentAppsMethod(), responseObserver);
    }

    /**
     */
    public void openApp(pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenAppMethod(), responseObserver);
    }

    /**
     */
    public void openQuickSettings(pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenQuickSettingsMethod(), responseObserver);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public void getNativeViews(pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNativeViewsMethod(), responseObserver);
    }

    /**
     */
    public void tap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getTapMethod(), responseObserver);
    }

    /**
     */
    public void doubleTap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDoubleTapMethod(), responseObserver);
    }

    /**
     */
    public void enterText(pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnterTextMethod(), responseObserver);
    }

    /**
     */
    public void swipe(pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSwipeMethod(), responseObserver);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public void enableAirplaneMode(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableAirplaneModeMethod(), responseObserver);
    }

    /**
     */
    public void disableAirplaneMode(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableAirplaneModeMethod(), responseObserver);
    }

    /**
     */
    public void enableWiFi(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableWiFiMethod(), responseObserver);
    }

    /**
     */
    public void disableWiFi(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableWiFiMethod(), responseObserver);
    }

    /**
     */
    public void enableCellular(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableCellularMethod(), responseObserver);
    }

    /**
     */
    public void disableCellular(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableCellularMethod(), responseObserver);
    }

    /**
     */
    public void enableBluetooth(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableBluetoothMethod(), responseObserver);
    }

    /**
     */
    public void disableBluetooth(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableBluetoothMethod(), responseObserver);
    }

    /**
     */
    public void enableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableDarkModeMethod(), responseObserver);
    }

    /**
     */
    public void disableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableDarkModeMethod(), responseObserver);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public void openNotifications(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void closeNotifications(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCloseNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void closeHeadsUpNotification(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getCloseHeadsUpNotificationMethod(), responseObserver);
    }

    /**
     */
    public void getNotifications(pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void tapOnNotification(pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getTapOnNotificationMethod(), responseObserver);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public void handlePermissionDialog(pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getHandlePermissionDialogMethod(), responseObserver);
    }

    /**
     */
    public void setLocationAccuracy(pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSetLocationAccuracyMethod(), responseObserver);
    }

    /**
     */
    public void debug(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDebugMethod(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getPressHomeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_PRESS_HOME)))
          .addMethod(
            getPressBackMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_PRESS_BACK)))
          .addMethod(
            getPressRecentAppsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_PRESS_RECENT_APPS)))
          .addMethod(
            getDoublePressRecentAppsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DOUBLE_PRESS_RECENT_APPS)))
          .addMethod(
            getOpenAppMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_OPEN_APP)))
          .addMethod(
            getOpenQuickSettingsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_OPEN_QUICK_SETTINGS)))
          .addMethod(
            getGetNativeViewsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest,
                pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse>(
                  this, METHODID_GET_NATIVE_VIEWS)))
          .addMethod(
            getTapMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.TapRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_TAP)))
          .addMethod(
            getDoubleTapMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.TapRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DOUBLE_TAP)))
          .addMethod(
            getEnterTextMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_ENTER_TEXT)))
          .addMethod(
            getSwipeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.SwipeRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_SWIPE)))
          .addMethod(
            getEnableAirplaneModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_ENABLE_AIRPLANE_MODE)))
          .addMethod(
            getDisableAirplaneModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DISABLE_AIRPLANE_MODE)))
          .addMethod(
            getEnableWiFiMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_ENABLE_WI_FI)))
          .addMethod(
            getDisableWiFiMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DISABLE_WI_FI)))
          .addMethod(
            getEnableCellularMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_ENABLE_CELLULAR)))
          .addMethod(
            getDisableCellularMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DISABLE_CELLULAR)))
          .addMethod(
            getEnableBluetoothMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_ENABLE_BLUETOOTH)))
          .addMethod(
            getDisableBluetoothMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DISABLE_BLUETOOTH)))
          .addMethod(
            getEnableDarkModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_ENABLE_DARK_MODE)))
          .addMethod(
            getDisableDarkModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DISABLE_DARK_MODE)))
          .addMethod(
            getOpenNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_OPEN_NOTIFICATIONS)))
          .addMethod(
            getCloseNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_CLOSE_NOTIFICATIONS)))
          .addMethod(
            getCloseHeadsUpNotificationMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_CLOSE_HEADS_UP_NOTIFICATION)))
          .addMethod(
            getGetNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest,
                pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse>(
                  this, METHODID_GET_NOTIFICATIONS)))
          .addMethod(
            getTapOnNotificationMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_TAP_ON_NOTIFICATION)))
          .addMethod(
            getHandlePermissionDialogMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_HANDLE_PERMISSION_DIALOG)))
          .addMethod(
            getSetLocationAccuracyMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_SET_LOCATION_ACCURACY)))
          .addMethod(
            getDebugMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.Empty,
                pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>(
                  this, METHODID_DEBUG)))
          .build();
    }
  }

  /**
   * <pre>
   * general
   * </pre>
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
    public void pressHome(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressHomeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void pressBack(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressBackMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void pressRecentApps(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressRecentAppsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void doublePressRecentApps(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDoublePressRecentAppsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openApp(pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenAppMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openQuickSettings(pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenQuickSettingsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public void getNativeViews(pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetNativeViewsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void tap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getTapMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void doubleTap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDoubleTapMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enterText(pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnterTextMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void swipe(pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSwipeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public void enableAirplaneMode(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableAirplaneModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableAirplaneMode(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableAirplaneModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableWiFi(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableWiFiMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableWiFi(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableWiFiMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableCellular(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableCellularMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableCellular(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableCellularMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableBluetooth(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableBluetoothMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableBluetooth(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableBluetoothMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableDarkModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableDarkModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public void openNotifications(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void closeNotifications(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCloseNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void closeHeadsUpNotification(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getCloseHeadsUpNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void getNotifications(pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void tapOnNotification(pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getTapOnNotificationMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public void handlePermissionDialog(pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getHandlePermissionDialogMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void setLocationAccuracy(pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSetLocationAccuracyMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void debug(pl.leancode.automatorserver.contracts.Contracts.Empty request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDebugMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * <pre>
   * general
   * </pre>
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
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse pressHome(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressHomeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse pressBack(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressBackMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse pressRecentApps(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressRecentAppsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse doublePressRecentApps(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDoublePressRecentAppsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse openApp(pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenAppMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse openQuickSettings(pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenQuickSettingsMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse getNativeViews(pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNativeViewsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse tap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getTapMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse doubleTap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDoubleTapMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse enterText(pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnterTextMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse swipe(pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSwipeMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse enableAirplaneMode(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableAirplaneModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse disableAirplaneMode(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableAirplaneModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse enableWiFi(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableWiFiMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse disableWiFi(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableWiFiMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse enableCellular(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableCellularMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse disableCellular(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableCellularMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse enableBluetooth(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableBluetoothMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse disableBluetooth(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableBluetoothMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse enableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableDarkModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse disableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableDarkModeMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse openNotifications(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse closeNotifications(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCloseNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse closeHeadsUpNotification(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getCloseHeadsUpNotificationMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse getNotifications(pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse tapOnNotification(pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getTapOnNotificationMethod(), getCallOptions(), request);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse handlePermissionDialog(pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getHandlePermissionDialogMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse setLocationAccuracy(pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSetLocationAccuracyMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DefaultResponse debug(pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDebugMethod(), getCallOptions(), request);
    }
  }

  /**
   * <pre>
   * general
   * </pre>
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
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> pressHome(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressHomeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> pressBack(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressBackMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> pressRecentApps(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressRecentAppsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> doublePressRecentApps(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDoublePressRecentAppsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> openApp(
        pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenAppMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> openQuickSettings(
        pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenQuickSettingsMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * general UI interaction
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse> getNativeViews(
        pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetNativeViewsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> tap(
        pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getTapMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> doubleTap(
        pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDoubleTapMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> enterText(
        pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnterTextMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> swipe(
        pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSwipeMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * services
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> enableAirplaneMode(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableAirplaneModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> disableAirplaneMode(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableAirplaneModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> enableWiFi(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableWiFiMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> disableWiFi(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableWiFiMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> enableCellular(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableCellularMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> disableCellular(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableCellularMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> enableBluetooth(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableBluetoothMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> disableBluetooth(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableBluetoothMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> enableDarkMode(
        pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableDarkModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> disableDarkMode(
        pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableDarkModeMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * notifications
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> openNotifications(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> closeNotifications(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCloseNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> closeHeadsUpNotification(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getCloseHeadsUpNotificationMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> getNotifications(
        pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> tapOnNotification(
        pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getTapOnNotificationMethod(), getCallOptions()), request);
    }

    /**
     * <pre>
     * permissions
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> handlePermissionDialog(
        pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getHandlePermissionDialogMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> setLocationAccuracy(
        pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSetLocationAccuracyMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse> debug(
        pl.leancode.automatorserver.contracts.Contracts.Empty request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDebugMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_PRESS_HOME = 0;
  private static final int METHODID_PRESS_BACK = 1;
  private static final int METHODID_PRESS_RECENT_APPS = 2;
  private static final int METHODID_DOUBLE_PRESS_RECENT_APPS = 3;
  private static final int METHODID_OPEN_APP = 4;
  private static final int METHODID_OPEN_QUICK_SETTINGS = 5;
  private static final int METHODID_GET_NATIVE_VIEWS = 6;
  private static final int METHODID_TAP = 7;
  private static final int METHODID_DOUBLE_TAP = 8;
  private static final int METHODID_ENTER_TEXT = 9;
  private static final int METHODID_SWIPE = 10;
  private static final int METHODID_ENABLE_AIRPLANE_MODE = 11;
  private static final int METHODID_DISABLE_AIRPLANE_MODE = 12;
  private static final int METHODID_ENABLE_WI_FI = 13;
  private static final int METHODID_DISABLE_WI_FI = 14;
  private static final int METHODID_ENABLE_CELLULAR = 15;
  private static final int METHODID_DISABLE_CELLULAR = 16;
  private static final int METHODID_ENABLE_BLUETOOTH = 17;
  private static final int METHODID_DISABLE_BLUETOOTH = 18;
  private static final int METHODID_ENABLE_DARK_MODE = 19;
  private static final int METHODID_DISABLE_DARK_MODE = 20;
  private static final int METHODID_OPEN_NOTIFICATIONS = 21;
  private static final int METHODID_CLOSE_NOTIFICATIONS = 22;
  private static final int METHODID_CLOSE_HEADS_UP_NOTIFICATION = 23;
  private static final int METHODID_GET_NOTIFICATIONS = 24;
  private static final int METHODID_TAP_ON_NOTIFICATION = 25;
  private static final int METHODID_HANDLE_PERMISSION_DIALOG = 26;
  private static final int METHODID_SET_LOCATION_ACCURACY = 27;
  private static final int METHODID_DEBUG = 28;

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
        case METHODID_PRESS_HOME:
          serviceImpl.pressHome((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_PRESS_BACK:
          serviceImpl.pressBack((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_PRESS_RECENT_APPS:
          serviceImpl.pressRecentApps((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DOUBLE_PRESS_RECENT_APPS:
          serviceImpl.doublePressRecentApps((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_OPEN_APP:
          serviceImpl.openApp((pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_OPEN_QUICK_SETTINGS:
          serviceImpl.openQuickSettings((pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_GET_NATIVE_VIEWS:
          serviceImpl.getNativeViews((pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNativeViewsResponse>) responseObserver);
          break;
        case METHODID_TAP:
          serviceImpl.tap((pl.leancode.automatorserver.contracts.Contracts.TapRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DOUBLE_TAP:
          serviceImpl.doubleTap((pl.leancode.automatorserver.contracts.Contracts.TapRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_ENTER_TEXT:
          serviceImpl.enterText((pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_SWIPE:
          serviceImpl.swipe((pl.leancode.automatorserver.contracts.Contracts.SwipeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_ENABLE_AIRPLANE_MODE:
          serviceImpl.enableAirplaneMode((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DISABLE_AIRPLANE_MODE:
          serviceImpl.disableAirplaneMode((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_ENABLE_WI_FI:
          serviceImpl.enableWiFi((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DISABLE_WI_FI:
          serviceImpl.disableWiFi((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_ENABLE_CELLULAR:
          serviceImpl.enableCellular((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DISABLE_CELLULAR:
          serviceImpl.disableCellular((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_ENABLE_BLUETOOTH:
          serviceImpl.enableBluetooth((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DISABLE_BLUETOOTH:
          serviceImpl.disableBluetooth((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_ENABLE_DARK_MODE:
          serviceImpl.enableDarkMode((pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DISABLE_DARK_MODE:
          serviceImpl.disableDarkMode((pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_OPEN_NOTIFICATIONS:
          serviceImpl.openNotifications((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_CLOSE_NOTIFICATIONS:
          serviceImpl.closeNotifications((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_CLOSE_HEADS_UP_NOTIFICATION:
          serviceImpl.closeHeadsUpNotification((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_GET_NOTIFICATIONS:
          serviceImpl.getNotifications((pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse>) responseObserver);
          break;
        case METHODID_TAP_ON_NOTIFICATION:
          serviceImpl.tapOnNotification((pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_HANDLE_PERMISSION_DIALOG:
          serviceImpl.handlePermissionDialog((pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_SET_LOCATION_ACCURACY:
          serviceImpl.setLocationAccuracy((pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
          break;
        case METHODID_DEBUG:
          serviceImpl.debug((pl.leancode.automatorserver.contracts.Contracts.Empty) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DefaultResponse>) responseObserver);
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

  private static abstract class NativeAutomatorBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    NativeAutomatorBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return pl.leancode.automatorserver.contracts.Contracts.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("NativeAutomator");
    }
  }

  private static final class NativeAutomatorFileDescriptorSupplier
      extends NativeAutomatorBaseDescriptorSupplier {
    NativeAutomatorFileDescriptorSupplier() {}
  }

  private static final class NativeAutomatorMethodDescriptorSupplier
      extends NativeAutomatorBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final String methodName;

    NativeAutomatorMethodDescriptorSupplier(String methodName) {
      this.methodName = methodName;
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.MethodDescriptor getMethodDescriptor() {
      return getServiceDescriptor().findMethodByName(methodName);
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
              .setSchemaDescriptor(new NativeAutomatorFileDescriptorSupplier())
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
              .addMethod(getHandlePermissionDialogMethod())
              .addMethod(getSetLocationAccuracyMethod())
              .addMethod(getDebugMethod())
              .build();
        }
      }
    }
    return result;
  }
}
