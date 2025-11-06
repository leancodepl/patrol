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

abstract class MobileAutomatorServer {
    abstract fun configure(request: Contracts.ConfigureRequest)
    abstract fun pressHome()
    abstract fun pressRecentApps()
    abstract fun openApp(request: Contracts.OpenAppRequest)
    abstract fun openPlatformApp(request: Contracts.OpenPlatformAppRequest)
    abstract fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest)
    abstract fun openUrl(request: Contracts.OpenUrlRequest)
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
    abstract fun openNotifications()
    abstract fun closeNotifications()
    abstract fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse
    abstract fun isPermissionDialogVisible(request: Contracts.PermissionDialogVisibleRequest): Contracts.PermissionDialogVisibleResponse
    abstract fun handlePermissionDialog(request: Contracts.HandlePermissionRequest)
    abstract fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest)
    abstract fun setMockLocation(request: Contracts.SetMockLocationRequest)
    abstract fun markPatrolAppServiceReady()
    abstract fun isVirtualDevice(): Contracts.IsVirtualDeviceResponse
    abstract fun getOsVersion(): Contracts.GetOsVersionResponse

    val router = routes(
      "configure" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.ConfigureRequest::class.java)
        configure(body)
        Response(OK)
      },
      "pressHome" bind POST to {
        pressHome()
        Response(OK)
      },
      "pressRecentApps" bind POST to {
        pressRecentApps()
        Response(OK)
      },
      "openApp" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.OpenAppRequest::class.java)
        openApp(body)
        Response(OK)
      },
      "openPlatformApp" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.OpenPlatformAppRequest::class.java)
        openPlatformApp(body)
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
      "openNotifications" bind POST to {
        openNotifications()
        Response(OK)
      },
      "closeNotifications" bind POST to {
        closeNotifications()
        Response(OK)
      },
      "getNotifications" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.GetNotificationsRequest::class.java)
        val response = getNotifications(body)
        Response(OK).body(json.toJson(response))
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
      "setMockLocation" bind POST to {
        val body = json.fromJson(it.bodyString(), Contracts.SetMockLocationRequest::class.java)
        setMockLocation(body)
        Response(OK)
      },
      "markPatrolAppServiceReady" bind POST to {
        markPatrolAppServiceReady()
        Response(OK)
      },
      "isVirtualDevice" bind POST to {
        val response = isVirtualDevice()
        Response(OK).body(json.toJson(response))
      },
      "getOsVersion" bind POST to {
        val response = getOsVersion()
        Response(OK).body(json.toJson(response))
      }
    )

    private val json = Gson()
}

