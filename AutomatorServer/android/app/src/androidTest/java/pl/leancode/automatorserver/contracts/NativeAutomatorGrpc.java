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
  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest,
      pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse> getPressHomeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressHome",
      requestType = pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest,
      pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse> getPressHomeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest, pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse> getPressHomeMethod;
    if ((getPressHomeMethod = NativeAutomatorGrpc.getPressHomeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressHomeMethod = NativeAutomatorGrpc.getPressHomeMethod) == null) {
          NativeAutomatorGrpc.getPressHomeMethod = getPressHomeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest, pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressHome"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("pressHome"))
              .build();
        }
      }
    }
    return getPressHomeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressBackRequest,
      pl.leancode.automatorserver.contracts.Contracts.PressBackResponse> getPressBackMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressBack",
      requestType = pl.leancode.automatorserver.contracts.Contracts.PressBackRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.PressBackResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressBackRequest,
      pl.leancode.automatorserver.contracts.Contracts.PressBackResponse> getPressBackMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressBackRequest, pl.leancode.automatorserver.contracts.Contracts.PressBackResponse> getPressBackMethod;
    if ((getPressBackMethod = NativeAutomatorGrpc.getPressBackMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressBackMethod = NativeAutomatorGrpc.getPressBackMethod) == null) {
          NativeAutomatorGrpc.getPressBackMethod = getPressBackMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.PressBackRequest, pl.leancode.automatorserver.contracts.Contracts.PressBackResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressBack"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.PressBackRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.PressBackResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("pressBack"))
              .build();
        }
      }
    }
    return getPressBackMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest,
      pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse> getPressRecentAppsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "pressRecentApps",
      requestType = pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest,
      pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse> getPressRecentAppsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest, pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse> getPressRecentAppsMethod;
    if ((getPressRecentAppsMethod = NativeAutomatorGrpc.getPressRecentAppsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getPressRecentAppsMethod = NativeAutomatorGrpc.getPressRecentAppsMethod) == null) {
          NativeAutomatorGrpc.getPressRecentAppsMethod = getPressRecentAppsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest, pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "pressRecentApps"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("pressRecentApps"))
              .build();
        }
      }
    }
    return getPressRecentAppsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest,
      pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse> getDoublePressRecentAppsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "doublePressRecentApps",
      requestType = pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest,
      pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse> getDoublePressRecentAppsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest, pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse> getDoublePressRecentAppsMethod;
    if ((getDoublePressRecentAppsMethod = NativeAutomatorGrpc.getDoublePressRecentAppsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDoublePressRecentAppsMethod = NativeAutomatorGrpc.getDoublePressRecentAppsMethod) == null) {
          NativeAutomatorGrpc.getDoublePressRecentAppsMethod = getDoublePressRecentAppsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest, pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "doublePressRecentApps"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("doublePressRecentApps"))
              .build();
        }
      }
    }
    return getDoublePressRecentAppsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest,
      pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse> getOpenAppMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openApp",
      requestType = pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest,
      pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse> getOpenAppMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest, pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse> getOpenAppMethod;
    if ((getOpenAppMethod = NativeAutomatorGrpc.getOpenAppMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenAppMethod = NativeAutomatorGrpc.getOpenAppMethod) == null) {
          NativeAutomatorGrpc.getOpenAppMethod = getOpenAppMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest, pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openApp"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("openApp"))
              .build();
        }
      }
    }
    return getOpenAppMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest,
      pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse> getOpenNotificationsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openNotifications",
      requestType = pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest,
      pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse> getOpenNotificationsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest, pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse> getOpenNotificationsMethod;
    if ((getOpenNotificationsMethod = NativeAutomatorGrpc.getOpenNotificationsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenNotificationsMethod = NativeAutomatorGrpc.getOpenNotificationsMethod) == null) {
          NativeAutomatorGrpc.getOpenNotificationsMethod = getOpenNotificationsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest, pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openNotifications"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("openNotifications"))
              .build();
        }
      }
    }
    return getOpenNotificationsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest,
      pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse> getOpenQuickSettingsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "openQuickSettings",
      requestType = pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest,
      pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse> getOpenQuickSettingsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest, pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse> getOpenQuickSettingsMethod;
    if ((getOpenQuickSettingsMethod = NativeAutomatorGrpc.getOpenQuickSettingsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getOpenQuickSettingsMethod = NativeAutomatorGrpc.getOpenQuickSettingsMethod) == null) {
          NativeAutomatorGrpc.getOpenQuickSettingsMethod = getOpenQuickSettingsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest, pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "openQuickSettings"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("openQuickSettings"))
              .build();
        }
      }
    }
    return getOpenQuickSettingsMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> getEnableDarkModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableDarkMode",
      requestType = pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> getEnableDarkModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> getEnableDarkModeMethod;
    if ((getEnableDarkModeMethod = NativeAutomatorGrpc.getEnableDarkModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableDarkModeMethod = NativeAutomatorGrpc.getEnableDarkModeMethod) == null) {
          NativeAutomatorGrpc.getEnableDarkModeMethod = getEnableDarkModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableDarkMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableDarkMode"))
              .build();
        }
      }
    }
    return getEnableDarkModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> getDisableDarkModeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableDarkMode",
      requestType = pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
      pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> getDisableDarkModeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> getDisableDarkModeMethod;
    if ((getDisableDarkModeMethod = NativeAutomatorGrpc.getDisableDarkModeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableDarkModeMethod = NativeAutomatorGrpc.getDisableDarkModeMethod) == null) {
          NativeAutomatorGrpc.getDisableDarkModeMethod = getDisableDarkModeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest, pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableDarkMode"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableDarkMode"))
              .build();
        }
      }
    }
    return getDisableDarkModeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest,
      pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> getEnableWiFiMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableWiFi",
      requestType = pl.leancode.automatorserver.contracts.Contracts.WiFiRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.WiFiResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest,
      pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> getEnableWiFiMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest, pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> getEnableWiFiMethod;
    if ((getEnableWiFiMethod = NativeAutomatorGrpc.getEnableWiFiMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableWiFiMethod = NativeAutomatorGrpc.getEnableWiFiMethod) == null) {
          NativeAutomatorGrpc.getEnableWiFiMethod = getEnableWiFiMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest, pl.leancode.automatorserver.contracts.Contracts.WiFiResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableWiFi"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.WiFiRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.WiFiResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableWiFi"))
              .build();
        }
      }
    }
    return getEnableWiFiMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest,
      pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> getDisableWiFiMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableWiFi",
      requestType = pl.leancode.automatorserver.contracts.Contracts.WiFiRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.WiFiResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest,
      pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> getDisableWiFiMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest, pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> getDisableWiFiMethod;
    if ((getDisableWiFiMethod = NativeAutomatorGrpc.getDisableWiFiMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableWiFiMethod = NativeAutomatorGrpc.getDisableWiFiMethod) == null) {
          NativeAutomatorGrpc.getDisableWiFiMethod = getDisableWiFiMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.WiFiRequest, pl.leancode.automatorserver.contracts.Contracts.WiFiResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableWiFi"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.WiFiRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.WiFiResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableWiFi"))
              .build();
        }
      }
    }
    return getDisableWiFiMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.CellularRequest,
      pl.leancode.automatorserver.contracts.Contracts.CellularResponse> getEnableCellularMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enableCellular",
      requestType = pl.leancode.automatorserver.contracts.Contracts.CellularRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.CellularResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.CellularRequest,
      pl.leancode.automatorserver.contracts.Contracts.CellularResponse> getEnableCellularMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.CellularRequest, pl.leancode.automatorserver.contracts.Contracts.CellularResponse> getEnableCellularMethod;
    if ((getEnableCellularMethod = NativeAutomatorGrpc.getEnableCellularMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnableCellularMethod = NativeAutomatorGrpc.getEnableCellularMethod) == null) {
          NativeAutomatorGrpc.getEnableCellularMethod = getEnableCellularMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.CellularRequest, pl.leancode.automatorserver.contracts.Contracts.CellularResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enableCellular"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.CellularRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.CellularResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enableCellular"))
              .build();
        }
      }
    }
    return getEnableCellularMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.CellularRequest,
      pl.leancode.automatorserver.contracts.Contracts.CellularResponse> getDisableCellularMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "disableCellular",
      requestType = pl.leancode.automatorserver.contracts.Contracts.CellularRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.CellularResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.CellularRequest,
      pl.leancode.automatorserver.contracts.Contracts.CellularResponse> getDisableCellularMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.CellularRequest, pl.leancode.automatorserver.contracts.Contracts.CellularResponse> getDisableCellularMethod;
    if ((getDisableCellularMethod = NativeAutomatorGrpc.getDisableCellularMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDisableCellularMethod = NativeAutomatorGrpc.getDisableCellularMethod) == null) {
          NativeAutomatorGrpc.getDisableCellularMethod = getDisableCellularMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.CellularRequest, pl.leancode.automatorserver.contracts.Contracts.CellularResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "disableCellular"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.CellularRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.CellularResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("disableCellular"))
              .build();
        }
      }
    }
    return getDisableCellularMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest,
      pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse> getGetNativeWidgetsMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "getNativeWidgets",
      requestType = pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest,
      pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse> getGetNativeWidgetsMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest, pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse> getGetNativeWidgetsMethod;
    if ((getGetNativeWidgetsMethod = NativeAutomatorGrpc.getGetNativeWidgetsMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getGetNativeWidgetsMethod = NativeAutomatorGrpc.getGetNativeWidgetsMethod) == null) {
          NativeAutomatorGrpc.getGetNativeWidgetsMethod = getGetNativeWidgetsMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest, pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "getNativeWidgets"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("getNativeWidgets"))
              .build();
        }
      }
    }
    return getGetNativeWidgetsMethod;
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

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.TapResponse> getTapMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "tap",
      requestType = pl.leancode.automatorserver.contracts.Contracts.TapRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.TapResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.TapResponse> getTapMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.TapResponse> getTapMethod;
    if ((getTapMethod = NativeAutomatorGrpc.getTapMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getTapMethod = NativeAutomatorGrpc.getTapMethod) == null) {
          NativeAutomatorGrpc.getTapMethod = getTapMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.TapResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "tap"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("tap"))
              .build();
        }
      }
    }
    return getTapMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.TapResponse> getDoubleTapMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "doubleTap",
      requestType = pl.leancode.automatorserver.contracts.Contracts.TapRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.TapResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest,
      pl.leancode.automatorserver.contracts.Contracts.TapResponse> getDoubleTapMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.TapResponse> getDoubleTapMethod;
    if ((getDoubleTapMethod = NativeAutomatorGrpc.getDoubleTapMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getDoubleTapMethod = NativeAutomatorGrpc.getDoubleTapMethod) == null) {
          NativeAutomatorGrpc.getDoubleTapMethod = getDoubleTapMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.TapRequest, pl.leancode.automatorserver.contracts.Contracts.TapResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "doubleTap"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("doubleTap"))
              .build();
        }
      }
    }
    return getDoubleTapMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest,
      pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse> getEnterTextMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "enterText",
      requestType = pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest,
      pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse> getEnterTextMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest, pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse> getEnterTextMethod;
    if ((getEnterTextMethod = NativeAutomatorGrpc.getEnterTextMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getEnterTextMethod = NativeAutomatorGrpc.getEnterTextMethod) == null) {
          NativeAutomatorGrpc.getEnterTextMethod = getEnterTextMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest, pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "enterText"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("enterText"))
              .build();
        }
      }
    }
    return getEnterTextMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest,
      pl.leancode.automatorserver.contracts.Contracts.SwipeResponse> getSwipeMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "swipe",
      requestType = pl.leancode.automatorserver.contracts.Contracts.SwipeRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.SwipeResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest,
      pl.leancode.automatorserver.contracts.Contracts.SwipeResponse> getSwipeMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest, pl.leancode.automatorserver.contracts.Contracts.SwipeResponse> getSwipeMethod;
    if ((getSwipeMethod = NativeAutomatorGrpc.getSwipeMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getSwipeMethod = NativeAutomatorGrpc.getSwipeMethod) == null) {
          NativeAutomatorGrpc.getSwipeMethod = getSwipeMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.SwipeRequest, pl.leancode.automatorserver.contracts.Contracts.SwipeResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "swipe"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.SwipeRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.SwipeResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("swipe"))
              .build();
        }
      }
    }
    return getSwipeMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest,
      pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse> getHandlePermissionDialogMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "handlePermissionDialog",
      requestType = pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest,
      pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse> getHandlePermissionDialogMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest, pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse> getHandlePermissionDialogMethod;
    if ((getHandlePermissionDialogMethod = NativeAutomatorGrpc.getHandlePermissionDialogMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getHandlePermissionDialogMethod = NativeAutomatorGrpc.getHandlePermissionDialogMethod) == null) {
          NativeAutomatorGrpc.getHandlePermissionDialogMethod = getHandlePermissionDialogMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest, pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "handlePermissionDialog"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("handlePermissionDialog"))
              .build();
        }
      }
    }
    return getHandlePermissionDialogMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest,
      pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse> getSetLocationAccuracyMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "setLocationAccuracy",
      requestType = pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest,
      pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse> getSetLocationAccuracyMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest, pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse> getSetLocationAccuracyMethod;
    if ((getSetLocationAccuracyMethod = NativeAutomatorGrpc.getSetLocationAccuracyMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getSetLocationAccuracyMethod = NativeAutomatorGrpc.getSetLocationAccuracyMethod) == null) {
          NativeAutomatorGrpc.getSetLocationAccuracyMethod = getSetLocationAccuracyMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest, pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "setLocationAccuracy"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("setLocationAccuracy"))
              .build();
        }
      }
    }
    return getSetLocationAccuracyMethod;
  }

  private static volatile io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest,
      pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse> getTapOnNotificationMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "tapOnNotification",
      requestType = pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest.class,
      responseType = pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest,
      pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse> getTapOnNotificationMethod() {
    io.grpc.MethodDescriptor<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest, pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse> getTapOnNotificationMethod;
    if ((getTapOnNotificationMethod = NativeAutomatorGrpc.getTapOnNotificationMethod) == null) {
      synchronized (NativeAutomatorGrpc.class) {
        if ((getTapOnNotificationMethod = NativeAutomatorGrpc.getTapOnNotificationMethod) == null) {
          NativeAutomatorGrpc.getTapOnNotificationMethod = getTapOnNotificationMethod =
              io.grpc.MethodDescriptor.<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest, pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "tapOnNotification"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse.getDefaultInstance()))
              .setSchemaDescriptor(new NativeAutomatorMethodDescriptorSupplier("tapOnNotification"))
              .build();
        }
      }
    }
    return getTapOnNotificationMethod;
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
    public void pressHome(pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressHomeMethod(), responseObserver);
    }

    /**
     */
    public void pressBack(pl.leancode.automatorserver.contracts.Contracts.PressBackRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressBackResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressBackMethod(), responseObserver);
    }

    /**
     */
    public void pressRecentApps(pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getPressRecentAppsMethod(), responseObserver);
    }

    /**
     */
    public void doublePressRecentApps(pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDoublePressRecentAppsMethod(), responseObserver);
    }

    /**
     */
    public void openApp(pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenAppMethod(), responseObserver);
    }

    /**
     */
    public void openNotifications(pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void openQuickSettings(pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getOpenQuickSettingsMethod(), responseObserver);
    }

    /**
     */
    public void enableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableDarkModeMethod(), responseObserver);
    }

    /**
     */
    public void disableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableDarkModeMethod(), responseObserver);
    }

    /**
     */
    public void enableWiFi(pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableWiFiMethod(), responseObserver);
    }

    /**
     */
    public void disableWiFi(pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableWiFiMethod(), responseObserver);
    }

    /**
     */
    public void enableCellular(pl.leancode.automatorserver.contracts.Contracts.CellularRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.CellularResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnableCellularMethod(), responseObserver);
    }

    /**
     */
    public void disableCellular(pl.leancode.automatorserver.contracts.Contracts.CellularRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.CellularResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDisableCellularMethod(), responseObserver);
    }

    /**
     */
    public void getNativeWidgets(pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNativeWidgetsMethod(), responseObserver);
    }

    /**
     */
    public void getNotifications(pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getGetNotificationsMethod(), responseObserver);
    }

    /**
     */
    public void tap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getTapMethod(), responseObserver);
    }

    /**
     */
    public void doubleTap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getDoubleTapMethod(), responseObserver);
    }

    /**
     */
    public void enterText(pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getEnterTextMethod(), responseObserver);
    }

    /**
     */
    public void swipe(pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.SwipeResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSwipeMethod(), responseObserver);
    }

    /**
     */
    public void handlePermissionDialog(pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getHandlePermissionDialogMethod(), responseObserver);
    }

    /**
     */
    public void setLocationAccuracy(pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSetLocationAccuracyMethod(), responseObserver);
    }

    /**
     */
    public void tapOnNotification(pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getTapOnNotificationMethod(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getPressHomeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest,
                pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse>(
                  this, METHODID_PRESS_HOME)))
          .addMethod(
            getPressBackMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.PressBackRequest,
                pl.leancode.automatorserver.contracts.Contracts.PressBackResponse>(
                  this, METHODID_PRESS_BACK)))
          .addMethod(
            getPressRecentAppsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest,
                pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse>(
                  this, METHODID_PRESS_RECENT_APPS)))
          .addMethod(
            getDoublePressRecentAppsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest,
                pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse>(
                  this, METHODID_DOUBLE_PRESS_RECENT_APPS)))
          .addMethod(
            getOpenAppMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest,
                pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse>(
                  this, METHODID_OPEN_APP)))
          .addMethod(
            getOpenNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest,
                pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse>(
                  this, METHODID_OPEN_NOTIFICATIONS)))
          .addMethod(
            getOpenQuickSettingsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest,
                pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse>(
                  this, METHODID_OPEN_QUICK_SETTINGS)))
          .addMethod(
            getEnableDarkModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
                pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse>(
                  this, METHODID_ENABLE_DARK_MODE)))
          .addMethod(
            getDisableDarkModeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest,
                pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse>(
                  this, METHODID_DISABLE_DARK_MODE)))
          .addMethod(
            getEnableWiFiMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.WiFiRequest,
                pl.leancode.automatorserver.contracts.Contracts.WiFiResponse>(
                  this, METHODID_ENABLE_WI_FI)))
          .addMethod(
            getDisableWiFiMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.WiFiRequest,
                pl.leancode.automatorserver.contracts.Contracts.WiFiResponse>(
                  this, METHODID_DISABLE_WI_FI)))
          .addMethod(
            getEnableCellularMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.CellularRequest,
                pl.leancode.automatorserver.contracts.Contracts.CellularResponse>(
                  this, METHODID_ENABLE_CELLULAR)))
          .addMethod(
            getDisableCellularMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.CellularRequest,
                pl.leancode.automatorserver.contracts.Contracts.CellularResponse>(
                  this, METHODID_DISABLE_CELLULAR)))
          .addMethod(
            getGetNativeWidgetsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest,
                pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse>(
                  this, METHODID_GET_NATIVE_WIDGETS)))
          .addMethod(
            getGetNotificationsMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest,
                pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse>(
                  this, METHODID_GET_NOTIFICATIONS)))
          .addMethod(
            getTapMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.TapRequest,
                pl.leancode.automatorserver.contracts.Contracts.TapResponse>(
                  this, METHODID_TAP)))
          .addMethod(
            getDoubleTapMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.TapRequest,
                pl.leancode.automatorserver.contracts.Contracts.TapResponse>(
                  this, METHODID_DOUBLE_TAP)))
          .addMethod(
            getEnterTextMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest,
                pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse>(
                  this, METHODID_ENTER_TEXT)))
          .addMethod(
            getSwipeMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.SwipeRequest,
                pl.leancode.automatorserver.contracts.Contracts.SwipeResponse>(
                  this, METHODID_SWIPE)))
          .addMethod(
            getHandlePermissionDialogMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest,
                pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse>(
                  this, METHODID_HANDLE_PERMISSION_DIALOG)))
          .addMethod(
            getSetLocationAccuracyMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest,
                pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse>(
                  this, METHODID_SET_LOCATION_ACCURACY)))
          .addMethod(
            getTapOnNotificationMethod(),
            io.grpc.stub.ServerCalls.asyncUnaryCall(
              new MethodHandlers<
                pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest,
                pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse>(
                  this, METHODID_TAP_ON_NOTIFICATION)))
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
    public void pressHome(pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressHomeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void pressBack(pl.leancode.automatorserver.contracts.Contracts.PressBackRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressBackResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressBackMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void pressRecentApps(pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getPressRecentAppsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void doublePressRecentApps(pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDoublePressRecentAppsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openApp(pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenAppMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openNotifications(pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenNotificationsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void openQuickSettings(pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getOpenQuickSettingsMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableDarkModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableDarkModeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableWiFi(pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableWiFiMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableWiFi(pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableWiFiMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enableCellular(pl.leancode.automatorserver.contracts.Contracts.CellularRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.CellularResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnableCellularMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void disableCellular(pl.leancode.automatorserver.contracts.Contracts.CellularRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.CellularResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDisableCellularMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void getNativeWidgets(pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getGetNativeWidgetsMethod(), getCallOptions()), request, responseObserver);
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
    public void tap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getTapMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void doubleTap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getDoubleTapMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void enterText(pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getEnterTextMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void swipe(pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.SwipeResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSwipeMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void handlePermissionDialog(pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getHandlePermissionDialogMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void setLocationAccuracy(pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSetLocationAccuracyMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void tapOnNotification(pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request,
        io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getTapOnNotificationMethod(), getCallOptions()), request, responseObserver);
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
    public pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse pressHome(pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressHomeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.PressBackResponse pressBack(pl.leancode.automatorserver.contracts.Contracts.PressBackRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressBackMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse pressRecentApps(pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getPressRecentAppsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse doublePressRecentApps(pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDoublePressRecentAppsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse openApp(pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenAppMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse openNotifications(pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse openQuickSettings(pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getOpenQuickSettingsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse enableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableDarkModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse disableDarkMode(pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableDarkModeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.WiFiResponse enableWiFi(pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableWiFiMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.WiFiResponse disableWiFi(pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableWiFiMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.CellularResponse enableCellular(pl.leancode.automatorserver.contracts.Contracts.CellularRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnableCellularMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.CellularResponse disableCellular(pl.leancode.automatorserver.contracts.Contracts.CellularRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDisableCellularMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse getNativeWidgets(pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNativeWidgetsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse getNotifications(pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getGetNotificationsMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.TapResponse tap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getTapMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.TapResponse doubleTap(pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getDoubleTapMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse enterText(pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getEnterTextMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.SwipeResponse swipe(pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSwipeMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse handlePermissionDialog(pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getHandlePermissionDialogMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse setLocationAccuracy(pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSetLocationAccuracyMethod(), getCallOptions(), request);
    }

    /**
     */
    public pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse tapOnNotification(pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getTapOnNotificationMethod(), getCallOptions(), request);
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
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse> pressHome(
        pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressHomeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.PressBackResponse> pressBack(
        pl.leancode.automatorserver.contracts.Contracts.PressBackRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressBackMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse> pressRecentApps(
        pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getPressRecentAppsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse> doublePressRecentApps(
        pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDoublePressRecentAppsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse> openApp(
        pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenAppMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse> openNotifications(
        pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenNotificationsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse> openQuickSettings(
        pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getOpenQuickSettingsMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> enableDarkMode(
        pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableDarkModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse> disableDarkMode(
        pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableDarkModeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> enableWiFi(
        pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableWiFiMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse> disableWiFi(
        pl.leancode.automatorserver.contracts.Contracts.WiFiRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableWiFiMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.CellularResponse> enableCellular(
        pl.leancode.automatorserver.contracts.Contracts.CellularRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnableCellularMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.CellularResponse> disableCellular(
        pl.leancode.automatorserver.contracts.Contracts.CellularRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDisableCellularMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse> getNativeWidgets(
        pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getGetNativeWidgetsMethod(), getCallOptions()), request);
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
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.TapResponse> tap(
        pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getTapMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.TapResponse> doubleTap(
        pl.leancode.automatorserver.contracts.Contracts.TapRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getDoubleTapMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse> enterText(
        pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getEnterTextMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.SwipeResponse> swipe(
        pl.leancode.automatorserver.contracts.Contracts.SwipeRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSwipeMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse> handlePermissionDialog(
        pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getHandlePermissionDialogMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse> setLocationAccuracy(
        pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSetLocationAccuracyMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse> tapOnNotification(
        pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getTapOnNotificationMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_PRESS_HOME = 0;
  private static final int METHODID_PRESS_BACK = 1;
  private static final int METHODID_PRESS_RECENT_APPS = 2;
  private static final int METHODID_DOUBLE_PRESS_RECENT_APPS = 3;
  private static final int METHODID_OPEN_APP = 4;
  private static final int METHODID_OPEN_NOTIFICATIONS = 5;
  private static final int METHODID_OPEN_QUICK_SETTINGS = 6;
  private static final int METHODID_ENABLE_DARK_MODE = 7;
  private static final int METHODID_DISABLE_DARK_MODE = 8;
  private static final int METHODID_ENABLE_WI_FI = 9;
  private static final int METHODID_DISABLE_WI_FI = 10;
  private static final int METHODID_ENABLE_CELLULAR = 11;
  private static final int METHODID_DISABLE_CELLULAR = 12;
  private static final int METHODID_GET_NATIVE_WIDGETS = 13;
  private static final int METHODID_GET_NOTIFICATIONS = 14;
  private static final int METHODID_TAP = 15;
  private static final int METHODID_DOUBLE_TAP = 16;
  private static final int METHODID_ENTER_TEXT = 17;
  private static final int METHODID_SWIPE = 18;
  private static final int METHODID_HANDLE_PERMISSION_DIALOG = 19;
  private static final int METHODID_SET_LOCATION_ACCURACY = 20;
  private static final int METHODID_TAP_ON_NOTIFICATION = 21;

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
          serviceImpl.pressHome((pl.leancode.automatorserver.contracts.Contracts.PressHomeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressHomeResponse>) responseObserver);
          break;
        case METHODID_PRESS_BACK:
          serviceImpl.pressBack((pl.leancode.automatorserver.contracts.Contracts.PressBackRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressBackResponse>) responseObserver);
          break;
        case METHODID_PRESS_RECENT_APPS:
          serviceImpl.pressRecentApps((pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.PressRecentAppsResponse>) responseObserver);
          break;
        case METHODID_DOUBLE_PRESS_RECENT_APPS:
          serviceImpl.doublePressRecentApps((pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DoublePressRecentAppsResponse>) responseObserver);
          break;
        case METHODID_OPEN_APP:
          serviceImpl.openApp((pl.leancode.automatorserver.contracts.Contracts.OpenAppRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenAppResponse>) responseObserver);
          break;
        case METHODID_OPEN_NOTIFICATIONS:
          serviceImpl.openNotifications((pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenNotificationsResponse>) responseObserver);
          break;
        case METHODID_OPEN_QUICK_SETTINGS:
          serviceImpl.openQuickSettings((pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.OpenQuickSettingsResponse>) responseObserver);
          break;
        case METHODID_ENABLE_DARK_MODE:
          serviceImpl.enableDarkMode((pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse>) responseObserver);
          break;
        case METHODID_DISABLE_DARK_MODE:
          serviceImpl.disableDarkMode((pl.leancode.automatorserver.contracts.Contracts.DarkModeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.DarkModeResponse>) responseObserver);
          break;
        case METHODID_ENABLE_WI_FI:
          serviceImpl.enableWiFi((pl.leancode.automatorserver.contracts.Contracts.WiFiRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse>) responseObserver);
          break;
        case METHODID_DISABLE_WI_FI:
          serviceImpl.disableWiFi((pl.leancode.automatorserver.contracts.Contracts.WiFiRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.WiFiResponse>) responseObserver);
          break;
        case METHODID_ENABLE_CELLULAR:
          serviceImpl.enableCellular((pl.leancode.automatorserver.contracts.Contracts.CellularRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.CellularResponse>) responseObserver);
          break;
        case METHODID_DISABLE_CELLULAR:
          serviceImpl.disableCellular((pl.leancode.automatorserver.contracts.Contracts.CellularRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.CellularResponse>) responseObserver);
          break;
        case METHODID_GET_NATIVE_WIDGETS:
          serviceImpl.getNativeWidgets((pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNativeWidgetsResponse>) responseObserver);
          break;
        case METHODID_GET_NOTIFICATIONS:
          serviceImpl.getNotifications((pl.leancode.automatorserver.contracts.Contracts.GetNotificationsRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.GetNotificationsResponse>) responseObserver);
          break;
        case METHODID_TAP:
          serviceImpl.tap((pl.leancode.automatorserver.contracts.Contracts.TapRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapResponse>) responseObserver);
          break;
        case METHODID_DOUBLE_TAP:
          serviceImpl.doubleTap((pl.leancode.automatorserver.contracts.Contracts.TapRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapResponse>) responseObserver);
          break;
        case METHODID_ENTER_TEXT:
          serviceImpl.enterText((pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.EnterTextResponse>) responseObserver);
          break;
        case METHODID_SWIPE:
          serviceImpl.swipe((pl.leancode.automatorserver.contracts.Contracts.SwipeRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.SwipeResponse>) responseObserver);
          break;
        case METHODID_HANDLE_PERMISSION_DIALOG:
          serviceImpl.handlePermissionDialog((pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.HandlePermissionResponse>) responseObserver);
          break;
        case METHODID_SET_LOCATION_ACCURACY:
          serviceImpl.setLocationAccuracy((pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyResponse>) responseObserver);
          break;
        case METHODID_TAP_ON_NOTIFICATION:
          serviceImpl.tapOnNotification((pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationRequest) request,
              (io.grpc.stub.StreamObserver<pl.leancode.automatorserver.contracts.Contracts.TapOnNotificationResponse>) responseObserver);
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
              .addMethod(getOpenNotificationsMethod())
              .addMethod(getOpenQuickSettingsMethod())
              .addMethod(getEnableDarkModeMethod())
              .addMethod(getDisableDarkModeMethod())
              .addMethod(getEnableWiFiMethod())
              .addMethod(getDisableWiFiMethod())
              .addMethod(getEnableCellularMethod())
              .addMethod(getDisableCellularMethod())
              .addMethod(getGetNativeWidgetsMethod())
              .addMethod(getGetNotificationsMethod())
              .addMethod(getTapMethod())
              .addMethod(getDoubleTapMethod())
              .addMethod(getEnterTextMethod())
              .addMethod(getSwipeMethod())
              .addMethod(getHandlePermissionDialogMethod())
              .addMethod(getSetLocationAccuracyMethod())
              .addMethod(getTapOnNotificationMethod())
              .build();
        }
      }
    }
    return result;
  }
}
