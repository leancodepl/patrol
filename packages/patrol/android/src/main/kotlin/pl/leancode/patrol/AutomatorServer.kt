package pl.leancode.patrol

import pl.leancode.patrol.contracts.Contracts
import pl.leancode.patrol.contracts.NativeAutomatorServer

class AutomatorServer(private val automation: Automator) : NativeAutomatorServer() {

    override fun initialize() {
        automation.initialize()
    }

    override fun configure(request: Contracts.ConfigureRequest) {
        automation.configure(waitForSelectorTimeout = request.findTimeoutMillis)
    }

    override fun pressHome() {
        automation.pressHome()
    }

    override fun pressBack() {
        automation.pressBack()
    }

    override fun pressRecentApps() {
        automation.pressRecentApps()
    }

    override fun doublePressRecentApps() {
        automation.pressDoubleRecentApps()
    }

    override fun openApp(request: Contracts.OpenAppRequest) {
        automation.openApp(request.appId)
    }

    override fun openNotifications() {
        automation.openNotifications()
    }

    override fun closeNotifications() {
        automation.closeNotifications()
    }

    override fun closeHeadsUpNotification() {
        // iOS only
    }

    override fun openQuickSettings(request: Contracts.OpenQuickSettingsRequest) {
        automation.openQuickSettings()
    }

    override fun enableDarkMode(request: Contracts.DarkModeRequest) {
        automation.enableDarkMode()
    }

    override fun disableDarkMode(request: Contracts.DarkModeRequest) {
        automation.disableDarkMode()
    }

    override fun enableAirplaneMode() {
        automation.enableAirplaneMode()
    }

    override fun disableAirplaneMode() {
        automation.disableAirplaneMode()
    }

    override fun enableCellular() {
        automation.enableCellular()
    }

    override fun disableCellular() {
        automation.disableCellular()
    }

    override fun enableWiFi() {
        automation.enableWifi()
    }

    override fun disableWiFi() {
        automation.disableWifi()
    }

    override fun enableBluetooth() {
        automation.enableBluetooth()
    }

    override fun disableBluetooth() {
        automation.disableBluetooth()
    }

    override fun getNativeViews(request: Contracts.GetNativeViewsRequest): Contracts.GetNativeViewsResponse {
        val views = automation.getNativeViews(request.selector.toBySelector())
        return Contracts.GetNativeViewsResponse(
            nativeViews = views
        )
    }

    override fun getNotifications(request: Contracts.GetNotificationsRequest): Contracts.GetNotificationsResponse {
        val notifs = automation.getNotifications()
        return Contracts.GetNotificationsResponse(notifs)
    }

    override fun tap(request: Contracts.TapRequest) {
        automation.tap(
            uiSelector = request.selector.toUiSelector(),
            bySelector = request.selector.toBySelector(),
            index = request.selector.instance?.toInt() ?: 0
        )
    }

    override fun doubleTap(request: Contracts.TapRequest) {
        automation.doubleTap(
            uiSelector = request.selector.toUiSelector(),
            bySelector = request.selector.toBySelector(),
            index = request.selector.instance?.toInt() ?: 0
        )
    }

    override fun enterText(request: Contracts.EnterTextRequest) {
        if (request.index != null) {
            automation.enterText(
                text = request.data,
                index = request.index!!.toInt(),
                showKeyboard = request.showKeyboard
            )
        } else if (request.selector != null) {
            automation.enterText(
                text = request.data,
                uiSelector = request.selector.toUiSelector(),
                bySelector = request.selector.toBySelector(),
                index = request.selector.instance?.toInt() ?: 0,
                showKeyboard = request.showKeyboard
            )
        } else {
            throw PatrolException("enterText(): neither index nor selector are set")
        }
    }

    override fun swipe(request: Contracts.SwipeRequest) {
        automation.swipe(
            startX = request.startX.toFloat(),
            startY = request.startY.toFloat(),
            endX = request.endX.toFloat(),
            endY = request.endY.toFloat(),
            steps = request.steps.toInt()
        )
    }

    override fun waitUntilVisible(request: Contracts.WaitUntilVisibleRequest) {
        automation.waitUntilVisible(
            uiSelector = request.selector.toUiSelector(),
            bySelector = request.selector.toBySelector(),
            index = request.selector.instance?.toInt() ?: 0
        )
    }

    override fun isPermissionDialogVisible(request: Contracts.PermissionDialogVisibleRequest): Contracts.PermissionDialogVisibleResponse {
        val visible = automation.isPermissionDialogVisible(timeout = request.timeoutMillis)
        return Contracts.PermissionDialogVisibleResponse(visible)
    }

    override fun handlePermissionDialog(request: Contracts.HandlePermissionRequest) {
        when (request.code) {
            Contracts.HandlePermissionRequestCode.whileUsing
            -> automation.allowPermissionWhileUsingApp()

            Contracts.HandlePermissionRequestCode.onlyThisTime
            -> automation.allowPermissionOnce()

            Contracts.HandlePermissionRequestCode.denied
            -> automation.denyPermission()
        }
    }

    override fun setLocationAccuracy(request: Contracts.SetLocationAccuracyRequest) {
        when (request.locationAccuracy) {
            Contracts.SetLocationAccuracyRequestLocationAccuracy.coarse
            -> automation.selectCoarseLocation()

            Contracts.SetLocationAccuracyRequestLocationAccuracy.fine
            -> automation.selectFineLocation()
        }
    }

    override fun debug() {
        // iOS only
    }

    override fun tapOnNotification(request: Contracts.TapOnNotificationRequest) {
        if (request.index != null) {
            automation.tapOnNotification(
                request.index.toInt()
            )
        } else if (request.selector != null) {
            automation.tapOnNotification(
                request.selector.toUiSelector()
            )
        } else {
            throw PatrolException("tapOnNotification(): neither index nor selector are set")
        }
    }

    override fun markPatrolAppServiceReady() {
        PatrolServer.appReady.set(true)
    }
}
