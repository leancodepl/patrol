///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import com.google.gson.Gson
import org.http4k.core.Response
import org.http4k.core.Method.POST
import org.http4k.routing.bind
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.routes

abstract class NativeAutomatorServer {
    abstract fun initialize()
    abstract fun configure(request: Contracts.ConfigureRequest)
    abstract fun pressHome()
    abstract fun pressBack()
    abstract fun pressRecentApps()
    abstract fun doublePressRecentApps()
    abstract fun openApp(request: Contracts.OpenAppRequest)
    abstract fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest)
    abstract fun openUrl(request: Contracts.OpenUrlRequest)
    abstract fun getNativeUITree(request: Contracts.GetNativeUITreeRequest): Contracts.GetNativeUITreeRespone
    abstract fun getNativeViews(request: Contracts.GetNativeViewsRequest): Contracts.GetNativeViewsResponse
    abstract fun tap(request: Contracts.TapRequest)
    abstract fun doubleTap(request: Contracts.TapRequest)
    abstract fun tapAt(request: Contracts.TapAtRequest)
    abstract fun enterText(request: Contracts.EnterTextRequest)
    abstract fun swipe(request: Contracts.SwipeRequest)
    abstract fun waitUntilVisible(request: Contracts.WaitUntilVisibleRequest)
    abstract fun pressVolumeUp()
    abstract fun pressVolumeDown()
    abstract fun enableAirplaneMode()
    abstract fun disableAirplaneMode()
    abstract fun enableWiFi()
    abstract fun disableWiFi()
    abstract fun enableCellular()
    abstract fun disableCellular()
    abstract fun enableBluetooth()
    abstract fun disableBluetooth()
    abstract fun enableDarkMode(request: Contracts.DarkModeRequest)
    abstract fun disableDarkMode(request: Contracts.DarkModeRequest)
    abstract fun enableLocation()
    abstract fun disableLocation()
    abstract fun openNotifications()
    abstract fun closeNotifications()
    abstract fun closeHeadsUpNotification()
    abstract fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse
    abstract fun tapOnNotification(request: Contracts.TapOnNotificationRequest)
    abstract fun isPermissionDialogVisible(request: Contracts.PermissionDialogVisibleRequest): Contracts.PermissionDialogVisibleResponse
    abstract fun handlePermissionDialog(request: Contracts.HandlePermissionRequest)
    abstract fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest)
    abstract fun debug()
    abstract fun markPatrolAppServiceReady(request: Contracts.MarkAppAppServiceReadyRequest)

    val router = routes(
      "initialize" bind POST to {
        initialize()
        Response(OK)
      },
      "configure" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.ConfigureRequest::class.java)
        configure(body)
        Response(OK)
      },
      "pressHome" bind POST to {
        pressHome()
        Response(OK)
      },
      "pressBack" bind POST to {
        pressBack()
        Response(OK)
      },
      "pressRecentApps" bind POST to {
        pressRecentApps()
        Response(OK)
      },
      "doublePressRecentApps" bind POST to {
        doublePressRecentApps()
        Response(OK)
      },
      "openApp" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.OpenAppRequest::class.java)
        openApp(body)
        Response(OK)
      },
      "openQuickSettings" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.OpenQuickSettingsRequest::class.java)
        openQuickSettings(body)
        Response(OK)
      },
      "openUrl" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.OpenUrlRequest::class.java)
        openUrl(body)
        Response(OK)
      },
      "getNativeUITree" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.GetNativeUITreeRequest::class.java)
        val response = getNativeUITree(body)
        Response(OK).body(json.toJson(response))
      },
      "getNativeViews" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.GetNativeViewsRequest::class.java)
        val response = getNativeViews(body)
        Response(OK).body(json.toJson(response))
      },
      "tap" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.TapRequest::class.java)
        tap(body)
        Response(OK)
      },
      "doubleTap" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.TapRequest::class.java)
        doubleTap(body)
        Response(OK)
      },
      "tapAt" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.TapAtRequest::class.java)
        tapAt(body)
        Response(OK)
      },
      "enterText" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.EnterTextRequest::class.java)
        enterText(body)
        Response(OK)
      },
      "swipe" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.SwipeRequest::class.java)
        swipe(body)
        Response(OK)
      },
      "waitUntilVisible" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.WaitUntilVisibleRequest::class.java)
        waitUntilVisible(body)
        Response(OK)
      },
      "pressVolumeUp" bind POST to {
        pressVolumeUp()
        Response(OK)
      },
      "pressVolumeDown" bind POST to {
        pressVolumeDown()
        Response(OK)
      },
      "enableAirplaneMode" bind POST to {
        enableAirplaneMode()
        Response(OK)
      },
      "disableAirplaneMode" bind POST to {
        disableAirplaneMode()
        Response(OK)
      },
      "enableWiFi" bind POST to {
        enableWiFi()
        Response(OK)
      },
      "disableWiFi" bind POST to {
        disableWiFi()
        Response(OK)
      },
      "enableCellular" bind POST to {
        enableCellular()
        Response(OK)
      },
      "disableCellular" bind POST to {
        disableCellular()
        Response(OK)
      },
      "enableBluetooth" bind POST to {
        enableBluetooth()
        Response(OK)
      },
      "disableBluetooth" bind POST to {
        disableBluetooth()
        Response(OK)
      },
      "enableDarkMode" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.DarkModeRequest::class.java)
        enableDarkMode(body)
        Response(OK)
      },
      "disableDarkMode" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.DarkModeRequest::class.java)
        disableDarkMode(body)
        Response(OK)
      },
      "enableLocation" bind POST to {
        enableLocation()
        Response(OK)
      },
      "disableLocation" bind POST to {
        disableLocation()
        Response(OK)
      },
      "openNotifications" bind POST to {
        openNotifications()
        Response(OK)
      },
      "closeNotifications" bind POST to {
        closeNotifications()
        Response(OK)
      },
      "closeHeadsUpNotification" bind POST to {
        closeHeadsUpNotification()
        Response(OK)
      },
      "getNotifications" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.GetNotificationsRequest::class.java)
        val response = getNotifications(body)
        Response(OK).body(json.toJson(response))
      },
      "tapOnNotification" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.TapOnNotificationRequest::class.java)
        tapOnNotification(body)
        Response(OK)
      },
      "isPermissionDialogVisible" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.PermissionDialogVisibleRequest::class.java)
        val response = isPermissionDialogVisible(body)
        Response(OK).body(json.toJson(response))
      },
      "handlePermissionDialog" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.HandlePermissionRequest::class.java)
        handlePermissionDialog(body)
        Response(OK)
      },
      "setLocationAccuracy" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.SetLocationAccuracyRequest::class.java)
        setLocationAccuracy(body)
        Response(OK)
      },
      "debug" bind POST to {
        debug()
        Response(OK)
      },
      "markPatrolAppServiceReady" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.MarkAppAppServiceReadyRequest::class.java)
        markPatrolAppServiceReady(body)
        Response(OK)
      }
    )

    private val json = Gson()
}

