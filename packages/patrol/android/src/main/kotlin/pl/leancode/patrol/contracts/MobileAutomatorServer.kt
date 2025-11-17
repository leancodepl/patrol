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
import org.http4k.routing.RoutingHttpHandler
import org.http4k.routing.routes

interface MobileAutomatorServer {
    fun configure(request: Contracts.ConfigureRequest)
    fun pressHome()
    fun pressRecentApps()
    fun openApp(request: Contracts.OpenAppRequest)
    fun openPlatformApp(request: Contracts.OpenPlatformAppRequest)
    fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest)
    fun openUrl(request: Contracts.OpenUrlRequest)
    fun pressVolumeUp()
    fun pressVolumeDown()
    fun enableAirplaneMode()
    fun disableAirplaneMode()
    fun enableWiFi()
    fun disableWiFi()
    fun enableCellular()
    fun disableCellular()
    fun enableBluetooth()
    fun disableBluetooth()
    fun enableDarkMode(request: Contracts.DarkModeRequest)
    fun disableDarkMode(request: Contracts.DarkModeRequest)
    fun openNotifications()
    fun closeNotifications()
    fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse
    fun isPermissionDialogVisible(request: Contracts.PermissionDialogVisibleRequest): Contracts.PermissionDialogVisibleResponse
    fun handlePermissionDialog(request: Contracts.HandlePermissionRequest)
    fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest)
    fun setMockLocation(request: Contracts.SetMockLocationRequest)
    fun markPatrolAppServiceReady()
    fun isVirtualDevice(): Contracts.IsVirtualDeviceResponse
    fun getOsVersion(): Contracts.GetOsVersionResponse
}

private val json = Gson()

fun getMobileAutomatorRoutes(server: MobileAutomatorServer): RoutingHttpHandler = routes(
    "configure" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.ConfigureRequest::class.java)
      server.configure(body)
      Response(OK)
    },
    "pressHome" bind POST to {
      server.pressHome()
      Response(OK)
    },
    "pressRecentApps" bind POST to {
      server.pressRecentApps()
      Response(OK)
    },
    "openApp" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.OpenAppRequest::class.java)
      server.openApp(body)
      Response(OK)
    },
    "openPlatformApp" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.OpenPlatformAppRequest::class.java)
      server.openPlatformApp(body)
      Response(OK)
    },
    "openQuickSettings" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.OpenQuickSettingsRequest::class.java)
      server.openQuickSettings(body)
      Response(OK)
    },
    "openUrl" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.OpenUrlRequest::class.java)
      server.openUrl(body)
      Response(OK)
    },
    "pressVolumeUp" bind POST to {
      server.pressVolumeUp()
      Response(OK)
    },
    "pressVolumeDown" bind POST to {
      server.pressVolumeDown()
      Response(OK)
    },
    "enableAirplaneMode" bind POST to {
      server.enableAirplaneMode()
      Response(OK)
    },
    "disableAirplaneMode" bind POST to {
      server.disableAirplaneMode()
      Response(OK)
    },
    "enableWiFi" bind POST to {
      server.enableWiFi()
      Response(OK)
    },
    "disableWiFi" bind POST to {
      server.disableWiFi()
      Response(OK)
    },
    "enableCellular" bind POST to {
      server.enableCellular()
      Response(OK)
    },
    "disableCellular" bind POST to {
      server.disableCellular()
      Response(OK)
    },
    "enableBluetooth" bind POST to {
      server.enableBluetooth()
      Response(OK)
    },
    "disableBluetooth" bind POST to {
      server.disableBluetooth()
      Response(OK)
    },
    "enableDarkMode" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.DarkModeRequest::class.java)
      server.enableDarkMode(body)
      Response(OK)
    },
    "disableDarkMode" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.DarkModeRequest::class.java)
      server.disableDarkMode(body)
      Response(OK)
    },
    "openNotifications" bind POST to {
      server.openNotifications()
      Response(OK)
    },
    "closeNotifications" bind POST to {
      server.closeNotifications()
      Response(OK)
    },
    "getNotifications" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.GetNotificationsRequest::class.java)
      val response = server.getNotifications(body)
      Response(OK).body(json.toJson(response))
    },
    "isPermissionDialogVisible" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.PermissionDialogVisibleRequest::class.java)
      val response = server.isPermissionDialogVisible(body)
      Response(OK).body(json.toJson(response))
    },
    "handlePermissionDialog" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.HandlePermissionRequest::class.java)
      server.handlePermissionDialog(body)
      Response(OK)
    },
    "setLocationAccuracy" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.SetLocationAccuracyRequest::class.java)
      server.setLocationAccuracy(body)
      Response(OK)
    },
    "setMockLocation" bind POST to {
      val body = json.fromJson(it.bodyString(), Contracts.SetMockLocationRequest::class.java)
      server.setMockLocation(body)
      Response(OK)
    },
    "markPatrolAppServiceReady" bind POST to {
      server.markPatrolAppServiceReady()
      Response(OK)
    },
    "isVirtualDevice" bind POST to {
      val response = server.isVirtualDevice()
      Response(OK).body(json.toJson(response))
    },
    "getOsVersion" bind POST to {
      val response = server.getOsVersion()
      Response(OK).body(json.toJson(response))
    }
)

