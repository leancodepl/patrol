///
//  Generated code. Do not modify.
//  source: schema.dart
//

package pl.leancode.patrol.contracts;

import org.http4k.core.Response
import org.http4k.core.Method.POST
import org.http4k.routing.bind
import org.http4k.core.Status.Companion.OK
import org.http4k.routing.routes
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

abstract class NativeAutomatorServer {
    abstract fun initialize()
    abstract fun configure(request: Contracts.ConfigureRequest)
    abstract fun pressHome()
    abstract fun pressBack()
    abstract fun pressRecentApps()
    abstract fun doublePressRecentApps()
    abstract fun openApp(request: Contracts.OpenAppRequest)
    abstract fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest)
    abstract fun getNativeViews(request: Contracts.GetNativeViewsRequest): Contracts.GetNativeViewsResponse
    abstract fun tap(request: Contracts.TapRequest)
    abstract fun doubleTap(request: Contracts.TapRequest)
    abstract fun enterText(request: Contracts.EnterTextRequest)
    abstract fun swipe(request: Contracts.SwipeRequest)
    abstract fun waitUntilVisible(request: Contracts.WaitUntilVisibleRequest)
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
    abstract fun openNotifications()
    abstract fun closeNotifications()
    abstract fun closeHeadsUpNotification()
    abstract fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse
    abstract fun tapOnNotification(request: Contracts.TapOnNotificationRequest)
    abstract fun isPermissionDialogVisible(request: Contracts.PermissionDialogVisibleRequest): Contracts.PermissionDialogVisibleResponse
    abstract fun handlePermissionDialog(request: Contracts.HandlePermissionRequest)
    abstract fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest)
    abstract fun debug()
    abstract fun markPatrolAppServiceReady()

    val router = routes(
      "initialize" bind POST to {
        initialize()
        Response(OK)
      },
      "configure" bind POST to {
        val body = json.decodeFromString<Contracts.ConfigureRequest>(it.bodyString())
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
        val body = json.decodeFromString<Contracts.OpenAppRequest>(it.bodyString())
        openApp(body)
        Response(OK)
      },
      "openQuickSettings" bind POST to {
        val body = json.decodeFromString<Contracts.OpenQuickSettingsRequest>(it.bodyString())
        openQuickSettings(body)
        Response(OK)
      },
      "getNativeViews" bind POST to {
        val body = json.decodeFromString<Contracts.GetNativeViewsRequest>(it.bodyString())
        val response = getNativeViews(body)
        Response(OK).body(json.encodeToString(response))
      },
      "tap" bind POST to {
        val body = json.decodeFromString<Contracts.TapRequest>(it.bodyString())
        tap(body)
        Response(OK)
      },
      "doubleTap" bind POST to {
        val body = json.decodeFromString<Contracts.TapRequest>(it.bodyString())
        doubleTap(body)
        Response(OK)
      },
      "enterText" bind POST to {
        val body = json.decodeFromString<Contracts.EnterTextRequest>(it.bodyString())
        enterText(body)
        Response(OK)
      },
      "swipe" bind POST to {
        val body = json.decodeFromString<Contracts.SwipeRequest>(it.bodyString())
        swipe(body)
        Response(OK)
      },
      "waitUntilVisible" bind POST to {
        val body = json.decodeFromString<Contracts.WaitUntilVisibleRequest>(it.bodyString())
        waitUntilVisible(body)
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
        val body = json.decodeFromString<Contracts.DarkModeRequest>(it.bodyString())
        enableDarkMode(body)
        Response(OK)
      },
      "disableDarkMode" bind POST to {
        val body = json.decodeFromString<Contracts.DarkModeRequest>(it.bodyString())
        disableDarkMode(body)
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
        val body = json.decodeFromString<Contracts.GetNotificationsRequest>(it.bodyString())
        val response = getNotifications(body)
        Response(OK).body(json.encodeToString(response))
      },
      "tapOnNotification" bind POST to {
        val body = json.decodeFromString<Contracts.TapOnNotificationRequest>(it.bodyString())
        tapOnNotification(body)
        Response(OK)
      },
      "isPermissionDialogVisible" bind POST to {
        val body = json.decodeFromString<Contracts.PermissionDialogVisibleRequest>(it.bodyString())
        val response = isPermissionDialogVisible(body)
        Response(OK).body(json.encodeToString(response))
      },
      "handlePermissionDialog" bind POST to {
        val body = json.decodeFromString<Contracts.HandlePermissionRequest>(it.bodyString())
        handlePermissionDialog(body)
        Response(OK)
      },
      "setLocationAccuracy" bind POST to {
        val body = json.decodeFromString<Contracts.SetLocationAccuracyRequest>(it.bodyString())
        setLocationAccuracy(body)
        Response(OK)
      },
      "debug" bind POST to {
        debug()
        Response(OK)
      },
      "markPatrolAppServiceReady" bind POST to {
        markPatrolAppServiceReady()
        Response(OK)
      }
    )

    private val json = Json { ignoreUnknownKeys = true }
}

