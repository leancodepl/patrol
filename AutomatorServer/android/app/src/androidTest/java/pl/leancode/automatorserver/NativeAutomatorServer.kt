package pl.leancode.automatorserver

import pl.leancode.automatorserver.contracts.Contracts
import pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest.FindByCase.INDEX
import pl.leancode.automatorserver.contracts.Contracts.EnterTextRequest.FindByCase.SELECTOR
import pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.Code.DENIED
import pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.Code.ONLY_THIS_TIME
import pl.leancode.automatorserver.contracts.Contracts.HandlePermissionRequest.Code.WHILE_USING
import pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest.LocationAccuracy.COARSE
import pl.leancode.automatorserver.contracts.Contracts.SetLocationAccuracyRequest.LocationAccuracy.FINE
import pl.leancode.automatorserver.contracts.NativeAutomatorGrpcKt
import pl.leancode.automatorserver.contracts.cellularResponse
import pl.leancode.automatorserver.contracts.darkModeResponse
import pl.leancode.automatorserver.contracts.doublePressRecentAppsResponse
import pl.leancode.automatorserver.contracts.enterTextResponse
import pl.leancode.automatorserver.contracts.getNativeWidgetsResponse
import pl.leancode.automatorserver.contracts.getNotificationsResponse
import pl.leancode.automatorserver.contracts.handlePermissionResponse
import pl.leancode.automatorserver.contracts.openAppResponse
import pl.leancode.automatorserver.contracts.openNotificationsResponse
import pl.leancode.automatorserver.contracts.openQuickSettingsResponse
import pl.leancode.automatorserver.contracts.pressBackResponse
import pl.leancode.automatorserver.contracts.pressHomeResponse
import pl.leancode.automatorserver.contracts.pressRecentAppsResponse
import pl.leancode.automatorserver.contracts.setLocationAccuracyResponse
import pl.leancode.automatorserver.contracts.swipeResponse
import pl.leancode.automatorserver.contracts.tapOnNotificationResponse
import pl.leancode.automatorserver.contracts.tapResponse
import pl.leancode.automatorserver.contracts.wiFiResponse

class NativeAutomatorServer : NativeAutomatorGrpcKt.NativeAutomatorCoroutineImplBase() {
    private val automation = PatrolAutomator.instance

    override suspend fun pressHome(request: Contracts.PressHomeRequest): Contracts.PressHomeResponse {
        automation.pressHome()
        return pressHomeResponse { }
    }

    override suspend fun pressBack(request: Contracts.PressBackRequest): Contracts.PressBackResponse {
        automation.pressBack()
        return pressBackResponse { }
    }

    override suspend fun pressRecentApps(request: Contracts.PressRecentAppsRequest): Contracts.PressRecentAppsResponse {
        automation.pressRecentApps()
        return pressRecentAppsResponse {}
    }

    override suspend fun doublePressRecentApps(request: Contracts.DoublePressRecentAppsRequest): Contracts.DoublePressRecentAppsResponse {
        automation.pressDoubleRecentApps()
        return doublePressRecentAppsResponse {}
    }

    override suspend fun openApp(request: Contracts.OpenAppRequest): Contracts.OpenAppResponse {
        automation.openApp(request.appId)
        return openAppResponse { }
    }

    override suspend fun openNotifications(request: Contracts.OpenNotificationsRequest): Contracts.OpenNotificationsResponse {
        automation.openNotifications()
        return openNotificationsResponse { }
    }

    override suspend fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest): Contracts.OpenQuickSettingsResponse {
        automation.openQuickSettings()
        return openQuickSettingsResponse {}
    }

    override suspend fun enableDarkMode(request: Contracts.DarkModeRequest): Contracts.DarkModeResponse {
        automation.enableDarkMode()
        return darkModeResponse { }
    }

    override suspend fun disableDarkMode(request: Contracts.DarkModeRequest): Contracts.DarkModeResponse {
        automation.disableDarkMode()
        return darkModeResponse { }
    }

    override suspend fun enableWiFi(request: Contracts.WiFiRequest): Contracts.WiFiResponse {
        automation.enableWifi()
        return wiFiResponse { }
    }

    override suspend fun disableWiFi(request: Contracts.WiFiRequest): Contracts.WiFiResponse {
        automation.disableWifi()
        return wiFiResponse { }
    }

    override suspend fun enableCellular(request: Contracts.CellularRequest): Contracts.CellularResponse {
        automation.enableCellular()
        return cellularResponse { }
    }

    override suspend fun disableCellular(request: Contracts.CellularRequest): Contracts.CellularResponse {
        automation.disableCellular()
        return cellularResponse { }
    }

    override suspend fun getNativeWidgets(request: Contracts.GetNativeWidgetsRequest): Contracts.GetNativeWidgetsResponse {
        val widgets = automation.getNativeWidgets(request.selector.toBySelector())
        return getNativeWidgetsResponse { nativeWidgets.addAll(widgets) }
    }

    override suspend fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse {
        val notifs = automation.getNotifications()
        return getNotificationsResponse { notifications.addAll(notifs) }
    }

    override suspend fun tap(request: Contracts.TapRequest): Contracts.TapResponse {
        automation.tap(selector = request.selector.toUiSelector())
        return tapResponse { }
    }

    override suspend fun doubleTap(request: Contracts.TapRequest): Contracts.TapResponse {
        automation.doubleTap(selector = request.selector.toUiSelector())
        return tapResponse {}
    }

    override suspend fun enterText(request: Contracts.EnterTextRequest): Contracts.EnterTextResponse {
        when (request.findByCase) {
            INDEX -> automation.enterText(text = request.data, index = request.index)
            SELECTOR -> automation.enterText(text = request.data, selector = request.selector.toUiSelector())
            else -> throw PatrolException("enterText(): neither index nor selector are set")
        }

        return enterTextResponse { }
    }

    override suspend fun swipe(request: Contracts.SwipeRequest): Contracts.SwipeResponse {
        automation.swipe(
            startX = request.startX,
            startY = request.startY,
            endX = request.endX,
            endY = request.endY,
            steps = request.steps
        )
        return swipeResponse { }
    }

    override suspend fun handlePermissionDialog(request: Contracts.HandlePermissionRequest): Contracts.HandlePermissionResponse {
        when (request.code) {
            WHILE_USING -> automation.allowPermissionWhileUsingApp()
            ONLY_THIS_TIME -> automation.allowPermissionOnce()
            DENIED -> automation.denyPermission()
            else -> throw PatrolException("handlePermissionDialog(): bad permission code")
        }
        return handlePermissionResponse {}
    }

    override suspend fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest): Contracts.SetLocationAccuracyResponse {
        when (request.locationAccuracy) {
            COARSE -> automation.selectCoarseLocation()
            FINE -> automation.selectFineLocation()
            else -> throw PatrolException("setLocationAccuracy(): bad location accuracy")
        }
        return setLocationAccuracyResponse { }
    }

    override suspend fun tapOnNotification(request: Contracts.TapOnNotificationRequest): Contracts.TapOnNotificationResponse {
        when (request.findByCase) {
            Contracts.TapOnNotificationRequest.FindByCase.INDEX -> automation.tapOnNotification(request.index)
            Contracts.TapOnNotificationRequest.FindByCase.SELECTOR -> automation.tapOnNotification(request.selector.toUiSelector())
            else -> throw PatrolException("tapOnNotification(): neither index nor selector are set")
        }
        return tapOnNotificationResponse { }
    }
}
