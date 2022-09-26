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
import pl.leancode.automatorserver.contracts.empty
import pl.leancode.automatorserver.contracts.getNativeWidgetsResponse
import pl.leancode.automatorserver.contracts.getNotificationsResponse

typealias Empty = Contracts.Empty

class NativeAutomatorServer : NativeAutomatorGrpcKt.NativeAutomatorCoroutineImplBase() {
    private val automation = PatrolAutomator.instance

    override suspend fun pressHome(request: Empty): Empty {
        automation.pressHome()
        return empty { }
    }

    override suspend fun pressBack(request: Empty): Empty {
        automation.pressBack()
        return empty { }
    }

    override suspend fun pressRecentApps(request: Empty): Empty {
        automation.pressRecentApps()
        return empty { }
    }

    override suspend fun doublePressRecentApps(request: Empty): Empty {
        automation.pressDoubleRecentApps()
        return empty { }
    }

    override suspend fun openApp(request: Contracts.OpenAppRequest): Empty {
        automation.openApp(request.appId)
        return empty { }
    }

    override suspend fun openNotifications(request: Empty): Empty {
        automation.openNotifications()
        return empty { }
    }

    override suspend fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest): Empty {
        automation.openQuickSettings()
        return empty { }
    }

    override suspend fun enableDarkMode(request: Contracts.DarkModeRequest): Empty {
        automation.enableDarkMode()
        return empty { }
    }

    override suspend fun disableDarkMode(request: Contracts.DarkModeRequest): Empty {
        automation.disableDarkMode()
        return empty { }
    }

    override suspend fun enableWiFi(request: Contracts.WiFiRequest): Empty {
        automation.enableWifi()
        return empty { }
    }

    override suspend fun disableWiFi(request: Contracts.WiFiRequest): Empty {
        automation.disableWifi()
        return empty { }
    }

    override suspend fun enableCellular(request: Contracts.CellularRequest): Empty {
        automation.enableCellular()
        return empty { }
    }

    override suspend fun disableCellular(request: Contracts.CellularRequest): Empty {
        automation.disableCellular()
        return empty { }
    }

    override suspend fun getNativeWidgets(request: Contracts.GetNativeWidgetsRequest): Contracts.GetNativeWidgetsResponse {
        val widgets = automation.getNativeWidgets(request.selector.toBySelector())
        return getNativeWidgetsResponse { nativeWidgets.addAll(widgets) }
    }

    override suspend fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse {
        val notifs = automation.getNotifications()
        return getNotificationsResponse { notifications.addAll(notifs) }
    }

    override suspend fun tap(request: Contracts.TapRequest): Empty {
        automation.tap(selector = request.selector.toUiSelector())
        return empty { }
    }

    override suspend fun doubleTap(request: Contracts.TapRequest): Empty {
        automation.doubleTap(selector = request.selector.toUiSelector())
        return empty { }
    }

    override suspend fun enterText(request: Contracts.EnterTextRequest): Empty {
        when (request.findByCase) {
            INDEX -> automation.enterText(text = request.data, index = request.index)
            SELECTOR -> automation.enterText(text = request.data, selector = request.selector.toUiSelector())
            else -> throw PatrolException("enterText(): neither index nor selector are set")
        }

        return empty { }
    }

    override suspend fun swipe(request: Contracts.SwipeRequest): Empty {
        automation.swipe(
            startX = request.startX,
            startY = request.startY,
            endX = request.endX,
            endY = request.endY,
            steps = request.steps
        )
        return empty { }
    }

    override suspend fun handlePermissionDialog(request: Contracts.HandlePermissionRequest): Empty {
        when (request.code) {
            WHILE_USING -> automation.allowPermissionWhileUsingApp()
            ONLY_THIS_TIME -> automation.allowPermissionOnce()
            DENIED -> automation.denyPermission()
            else -> throw PatrolException("handlePermissionDialog(): bad permission code")
        }
        return empty { }
    }

    override suspend fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest): Empty {
        when (request.locationAccuracy) {
            COARSE -> automation.selectCoarseLocation()
            FINE -> automation.selectFineLocation()
            else -> throw PatrolException("setLocationAccuracy(): bad location accuracy")
        }
        return empty { }
    }

    override suspend fun tapOnNotification(request: Contracts.TapOnNotificationRequest): Empty {
        when (request.findByCase) {
            Contracts.TapOnNotificationRequest.FindByCase.INDEX -> automation.tapOnNotification(request.index)
            Contracts.TapOnNotificationRequest.FindByCase.SELECTOR -> automation.tapOnNotification(request.selector.toUiSelector())
            else -> throw PatrolException("tapOnNotification(): neither index nor selector are set")
        }
        return empty { }
    }
}
