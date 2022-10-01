package pl.leancode.automatorserver.contracts

import io.grpc.CallOptions
import io.grpc.CallOptions.DEFAULT
import io.grpc.Channel
import io.grpc.Metadata
import io.grpc.MethodDescriptor
import io.grpc.ServerServiceDefinition
import io.grpc.ServerServiceDefinition.builder
import io.grpc.ServiceDescriptor
import io.grpc.Status
import io.grpc.Status.UNIMPLEMENTED
import io.grpc.StatusException
import io.grpc.kotlin.AbstractCoroutineServerImpl
import io.grpc.kotlin.AbstractCoroutineStub
import io.grpc.kotlin.ClientCalls
import io.grpc.kotlin.ClientCalls.unaryRpc
import io.grpc.kotlin.ServerCalls
import io.grpc.kotlin.ServerCalls.unaryServerMethodDefinition
import io.grpc.kotlin.StubFor
import kotlin.String
import kotlin.coroutines.CoroutineContext
import kotlin.coroutines.EmptyCoroutineContext
import kotlin.jvm.JvmOverloads
import kotlin.jvm.JvmStatic
import pl.leancode.automatorserver.contracts.NativeAutomatorGrpc.getServiceDescriptor

/**
 * Holder for Kotlin coroutine-based client and server APIs for patrol.NativeAutomator.
 */
public object NativeAutomatorGrpcKt {
  public const val SERVICE_NAME: String = NativeAutomatorGrpc.SERVICE_NAME

  @JvmStatic
  public val serviceDescriptor: ServiceDescriptor
    get() = NativeAutomatorGrpc.getServiceDescriptor()

  public val pressHomeMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getPressHomeMethod()

  public val pressBackMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getPressBackMethod()

  public val pressRecentAppsMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getPressRecentAppsMethod()

  public val doublePressRecentAppsMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDoublePressRecentAppsMethod()

  public val openAppMethod: MethodDescriptor<Contracts.OpenAppRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getOpenAppMethod()

  public val openQuickSettingsMethod:
      MethodDescriptor<Contracts.OpenQuickSettingsRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getOpenQuickSettingsMethod()

  public val enableAirplaneModeMethod:
      MethodDescriptor<Contracts.AirplaneModeRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getEnableAirplaneModeMethod()

  public val disableAirplaneModeMethod:
      MethodDescriptor<Contracts.AirplaneModeRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDisableAirplaneModeMethod()

  public val enableWiFiMethod: MethodDescriptor<Contracts.WiFiRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getEnableWiFiMethod()

  public val disableWiFiMethod: MethodDescriptor<Contracts.WiFiRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDisableWiFiMethod()

  public val enableCellularMethod: MethodDescriptor<Contracts.CellularRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getEnableCellularMethod()

  public val disableCellularMethod: MethodDescriptor<Contracts.CellularRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDisableCellularMethod()

  public val enableBluetoothMethod: MethodDescriptor<Contracts.BluetoothRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getEnableBluetoothMethod()

  public val disableBluetoothMethod: MethodDescriptor<Contracts.BluetoothRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDisableBluetoothMethod()

  public val enableDarkModeMethod: MethodDescriptor<Contracts.DarkModeRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getEnableDarkModeMethod()

  public val disableDarkModeMethod: MethodDescriptor<Contracts.DarkModeRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDisableDarkModeMethod()

  public val getNativeWidgetsMethod:
      MethodDescriptor<Contracts.GetNativeWidgetsRequest, Contracts.GetNativeWidgetsResponse>
    @JvmStatic
    get() = NativeAutomatorGrpc.getGetNativeWidgetsMethod()

  public val tapMethod: MethodDescriptor<Contracts.TapRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getTapMethod()

  public val doubleTapMethod: MethodDescriptor<Contracts.TapRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDoubleTapMethod()

  public val enterTextMethod: MethodDescriptor<Contracts.EnterTextRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getEnterTextMethod()

  public val swipeMethod: MethodDescriptor<Contracts.SwipeRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getSwipeMethod()

  public val openNotificationsMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getOpenNotificationsMethod()

  public val closeNotificationsMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getCloseNotificationsMethod()

  public val getNotificationsMethod:
      MethodDescriptor<Contracts.GetNotificationsRequest, Contracts.GetNotificationsResponse>
    @JvmStatic
    get() = NativeAutomatorGrpc.getGetNotificationsMethod()

  public val tapOnNotificationMethod:
      MethodDescriptor<Contracts.TapOnNotificationRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getTapOnNotificationMethod()

  public val handlePermissionDialogMethod:
      MethodDescriptor<Contracts.HandlePermissionRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getHandlePermissionDialogMethod()

  public val setLocationAccuracyMethod:
      MethodDescriptor<Contracts.SetLocationAccuracyRequest, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getSetLocationAccuracyMethod()

  public val debugMethod: MethodDescriptor<Contracts.Empty, Contracts.Empty>
    @JvmStatic
    get() = NativeAutomatorGrpc.getDebugMethod()

  /**
   * A stub for issuing RPCs to a(n) patrol.NativeAutomator service as suspending coroutines.
   */
  @StubFor(NativeAutomatorGrpc::class)
  public class NativeAutomatorCoroutineStub @JvmOverloads constructor(
    channel: Channel,
    callOptions: CallOptions = DEFAULT,
  ) : AbstractCoroutineStub<NativeAutomatorCoroutineStub>(channel, callOptions) {
    public override fun build(channel: Channel, callOptions: CallOptions):
        NativeAutomatorCoroutineStub = NativeAutomatorCoroutineStub(channel, callOptions)

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun pressHome(request: Contracts.Empty, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getPressHomeMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun pressBack(request: Contracts.Empty, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getPressBackMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun pressRecentApps(request: Contracts.Empty, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getPressRecentAppsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun doublePressRecentApps(request: Contracts.Empty, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDoublePressRecentAppsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun openApp(request: Contracts.OpenAppRequest, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getOpenAppMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest,
        headers: Metadata = Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getOpenQuickSettingsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun enableAirplaneMode(request: Contracts.AirplaneModeRequest, headers: Metadata
        = Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getEnableAirplaneModeMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun disableAirplaneMode(request: Contracts.AirplaneModeRequest, headers: Metadata
        = Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDisableAirplaneModeMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun enableWiFi(request: Contracts.WiFiRequest, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getEnableWiFiMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun disableWiFi(request: Contracts.WiFiRequest, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDisableWiFiMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun enableCellular(request: Contracts.CellularRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getEnableCellularMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun disableCellular(request: Contracts.CellularRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDisableCellularMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun enableBluetooth(request: Contracts.BluetoothRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getEnableBluetoothMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun disableBluetooth(request: Contracts.BluetoothRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDisableBluetoothMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun enableDarkMode(request: Contracts.DarkModeRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getEnableDarkModeMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun disableDarkMode(request: Contracts.DarkModeRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDisableDarkModeMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun getNativeWidgets(request: Contracts.GetNativeWidgetsRequest,
        headers: Metadata = Metadata()): Contracts.GetNativeWidgetsResponse = unaryRpc(
      channel,
      NativeAutomatorGrpc.getGetNativeWidgetsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun tap(request: Contracts.TapRequest, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getTapMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun doubleTap(request: Contracts.TapRequest, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDoubleTapMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun enterText(request: Contracts.EnterTextRequest, headers: Metadata =
        Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getEnterTextMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun swipe(request: Contracts.SwipeRequest, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getSwipeMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun openNotifications(request: Contracts.Empty, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getOpenNotificationsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun closeNotifications(request: Contracts.Empty, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getCloseNotificationsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun getNotifications(request: Contracts.GetNotificationsRequest,
        headers: Metadata = Metadata()): Contracts.GetNotificationsResponse = unaryRpc(
      channel,
      NativeAutomatorGrpc.getGetNotificationsMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun tapOnNotification(request: Contracts.TapOnNotificationRequest,
        headers: Metadata = Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getTapOnNotificationMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun handlePermissionDialog(request: Contracts.HandlePermissionRequest,
        headers: Metadata = Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getHandlePermissionDialogMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest,
        headers: Metadata = Metadata()): Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getSetLocationAccuracyMethod(),
      request,
      callOptions,
      headers
    )

    /**
     * Executes this RPC and returns the response message, suspending until the RPC completes
     * with [`Status.OK`][Status].  If the RPC completes with another status, a corresponding
     * [StatusException] is thrown.  If this coroutine is cancelled, the RPC is also cancelled
     * with the corresponding exception as a cause.
     *
     * @param request The request message to send to the server.
     *
     * @param headers Metadata to attach to the request.  Most users will not need this.
     *
     * @return The single response from the server.
     */
    public suspend fun debug(request: Contracts.Empty, headers: Metadata = Metadata()):
        Contracts.Empty = unaryRpc(
      channel,
      NativeAutomatorGrpc.getDebugMethod(),
      request,
      callOptions,
      headers
    )
  }

  /**
   * Skeletal implementation of the patrol.NativeAutomator service based on Kotlin coroutines.
   */
  public abstract class NativeAutomatorCoroutineImplBase(
    coroutineContext: CoroutineContext = EmptyCoroutineContext,
  ) : AbstractCoroutineServerImpl(coroutineContext) {
    /**
     * Returns the response to an RPC for patrol.NativeAutomator.pressHome.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun pressHome(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.pressHome is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.pressBack.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun pressBack(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.pressBack is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.pressRecentApps.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun pressRecentApps(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.pressRecentApps is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.doublePressRecentApps.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun doublePressRecentApps(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.doublePressRecentApps is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.openApp.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun openApp(request: Contracts.OpenAppRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.openApp is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.openQuickSettings.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest):
        Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.openQuickSettings is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.enableAirplaneMode.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun enableAirplaneMode(request: Contracts.AirplaneModeRequest):
        Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.enableAirplaneMode is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.disableAirplaneMode.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun disableAirplaneMode(request: Contracts.AirplaneModeRequest):
        Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.disableAirplaneMode is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.enableWiFi.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun enableWiFi(request: Contracts.WiFiRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.enableWiFi is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.disableWiFi.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun disableWiFi(request: Contracts.WiFiRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.disableWiFi is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.enableCellular.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun enableCellular(request: Contracts.CellularRequest): Contracts.Empty =
        throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.enableCellular is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.disableCellular.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun disableCellular(request: Contracts.CellularRequest): Contracts.Empty =
        throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.disableCellular is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.enableBluetooth.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun enableBluetooth(request: Contracts.BluetoothRequest): Contracts.Empty =
        throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.enableBluetooth is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.disableBluetooth.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun disableBluetooth(request: Contracts.BluetoothRequest): Contracts.Empty =
        throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.disableBluetooth is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.enableDarkMode.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun enableDarkMode(request: Contracts.DarkModeRequest): Contracts.Empty =
        throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.enableDarkMode is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.disableDarkMode.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun disableDarkMode(request: Contracts.DarkModeRequest): Contracts.Empty =
        throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.disableDarkMode is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.getNativeWidgets.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun getNativeWidgets(request: Contracts.GetNativeWidgetsRequest):
        Contracts.GetNativeWidgetsResponse = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.getNativeWidgets is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.tap.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun tap(request: Contracts.TapRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.tap is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.doubleTap.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun doubleTap(request: Contracts.TapRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.doubleTap is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.enterText.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun enterText(request: Contracts.EnterTextRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.enterText is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.swipe.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun swipe(request: Contracts.SwipeRequest): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.swipe is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.openNotifications.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun openNotifications(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.openNotifications is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.closeNotifications.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun closeNotifications(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.closeNotifications is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.getNotifications.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun getNotifications(request: Contracts.GetNotificationsRequest):
        Contracts.GetNotificationsResponse = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.getNotifications is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.tapOnNotification.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun tapOnNotification(request: Contracts.TapOnNotificationRequest):
        Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.tapOnNotification is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.handlePermissionDialog.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun handlePermissionDialog(request: Contracts.HandlePermissionRequest):
        Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.handlePermissionDialog is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.setLocationAccuracy.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest):
        Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.setLocationAccuracy is unimplemented"))

    /**
     * Returns the response to an RPC for patrol.NativeAutomator.debug.
     *
     * If this method fails with a [StatusException], the RPC will fail with the corresponding
     * [Status].  If this method fails with a [java.util.concurrent.CancellationException], the RPC
     * will fail
     * with status `Status.CANCELLED`.  If this method fails for any other reason, the RPC will
     * fail with `Status.UNKNOWN` with the exception as a cause.
     *
     * @param request The request from the client.
     */
    public open suspend fun debug(request: Contracts.Empty): Contracts.Empty = throw
        StatusException(UNIMPLEMENTED.withDescription("Method patrol.NativeAutomator.debug is unimplemented"))

    public final override fun bindService(): ServerServiceDefinition =
        builder(getServiceDescriptor())
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getPressHomeMethod(),
      implementation = ::pressHome
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getPressBackMethod(),
      implementation = ::pressBack
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getPressRecentAppsMethod(),
      implementation = ::pressRecentApps
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDoublePressRecentAppsMethod(),
      implementation = ::doublePressRecentApps
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getOpenAppMethod(),
      implementation = ::openApp
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getOpenQuickSettingsMethod(),
      implementation = ::openQuickSettings
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getEnableAirplaneModeMethod(),
      implementation = ::enableAirplaneMode
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDisableAirplaneModeMethod(),
      implementation = ::disableAirplaneMode
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getEnableWiFiMethod(),
      implementation = ::enableWiFi
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDisableWiFiMethod(),
      implementation = ::disableWiFi
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getEnableCellularMethod(),
      implementation = ::enableCellular
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDisableCellularMethod(),
      implementation = ::disableCellular
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getEnableBluetoothMethod(),
      implementation = ::enableBluetooth
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDisableBluetoothMethod(),
      implementation = ::disableBluetooth
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getEnableDarkModeMethod(),
      implementation = ::enableDarkMode
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDisableDarkModeMethod(),
      implementation = ::disableDarkMode
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getGetNativeWidgetsMethod(),
      implementation = ::getNativeWidgets
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getTapMethod(),
      implementation = ::tap
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDoubleTapMethod(),
      implementation = ::doubleTap
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getEnterTextMethod(),
      implementation = ::enterText
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getSwipeMethod(),
      implementation = ::swipe
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getOpenNotificationsMethod(),
      implementation = ::openNotifications
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getCloseNotificationsMethod(),
      implementation = ::closeNotifications
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getGetNotificationsMethod(),
      implementation = ::getNotifications
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getTapOnNotificationMethod(),
      implementation = ::tapOnNotification
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getHandlePermissionDialogMethod(),
      implementation = ::handlePermissionDialog
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getSetLocationAccuracyMethod(),
      implementation = ::setLocationAccuracy
    ))
      .addMethod(unaryServerMethodDefinition(
      context = this.context,
      descriptor = NativeAutomatorGrpc.getDebugMethod(),
      implementation = ::debug
    )).build()
  }
}
