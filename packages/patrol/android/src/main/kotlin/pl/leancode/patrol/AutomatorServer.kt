package pl.leancode.patrol

import pl.leancode.patrol.contracts.Contracts.ConfigureRequest
import pl.leancode.patrol.contracts.Contracts.DarkModeRequest
import pl.leancode.patrol.contracts.Contracts.EnterTextRequest
import pl.leancode.patrol.contracts.Contracts.GetNativeUITreeRequest
import pl.leancode.patrol.contracts.Contracts.GetNativeUITreeRespone
import pl.leancode.patrol.contracts.Contracts.GetNativeViewsRequest
import pl.leancode.patrol.contracts.Contracts.GetNativeViewsResponse
import pl.leancode.patrol.contracts.Contracts.GetNotificationsRequest
import pl.leancode.patrol.contracts.Contracts.GetNotificationsResponse
import pl.leancode.patrol.contracts.Contracts.HandlePermissionRequest
import pl.leancode.patrol.contracts.Contracts.HandlePermissionRequestCode
import pl.leancode.patrol.contracts.Contracts.OpenAppRequest
import pl.leancode.patrol.contracts.Contracts.OpenQuickSettingsRequest
import pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleRequest
import pl.leancode.patrol.contracts.Contracts.PermissionDialogVisibleResponse
import pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest
import pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequestLocationAccuracy
import pl.leancode.patrol.contracts.Contracts.SwipeRequest
import pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest
import pl.leancode.patrol.contracts.Contracts.TapRequest
import pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest
import pl.leancode.patrol.contracts.NativeAutomatorServer

class AutomatorServer(private val automation: Automator) : NativeAutomatorServer() {

    override fun initialize() {
        automation.initialize()
    }

    override fun configure(request: ConfigureRequest) {
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

    override fun openApp(request: OpenAppRequest) {
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

    override fun openQuickSettings(request: OpenQuickSettingsRequest) {
        automation.openQuickSettings()
    }

    override fun getNativeUITree(request: GetNativeUITreeRequest): GetNativeUITreeRespone {
        val trees = automation.getNativeUITrees()
        return GetNativeUITreeRespone(trees)
    }

    override fun enableDarkMode(request: DarkModeRequest) {
        automation.enableDarkMode()
    }

    override fun disableDarkMode(request: DarkModeRequest) {
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

    override fun getNativeViews(request: GetNativeViewsRequest): GetNativeViewsResponse {
        val views = automation.getNativeViews(request.selector.toBySelector())
        return GetNativeViewsResponse(
            nativeViews = views
        )
    }

    override fun getNotifications(request: GetNotificationsRequest): GetNotificationsResponse {
        val notifs = automation.getNotifications()
        return GetNotificationsResponse(notifs)
    }

    override fun tap(request: TapRequest) {
        automation.tap(
            uiSelector = request.selector.toUiSelector(),
            bySelector = request.selector.toBySelector(),
            index = request.selector.instance?.toInt() ?: 0
        )
    }

    override fun doubleTap(request: TapRequest) {
        automation.doubleTap(
            uiSelector = request.selector.toUiSelector(),
            bySelector = request.selector.toBySelector(),
            index = request.selector.instance?.toInt() ?: 0
        )
    }

    override fun enterText(request: EnterTextRequest) {
        if (request.index != null) {
            automation.enterText(
                text = request.data,
                index = request.index.toInt(),
                keyboardBehavior = request.keyboardBehavior
            )
        } else if (request.selector != null) {
            automation.enterText(
                text = request.data,
                uiSelector = request.selector.toUiSelector(),
                bySelector = request.selector.toBySelector(),
                index = request.selector.instance?.toInt() ?: 0,
                keyboardBehavior = request.keyboardBehavior
            )
        } else {
            throw PatrolException("enterText(): neither index nor selector are set")
        }
    }

    override fun swipe(request: SwipeRequest) {
        automation.swipe(
            startX = request.startX.toFloat(),
            startY = request.startY.toFloat(),
            endX = request.endX.toFloat(),
            endY = request.endY.toFloat(),
            steps = request.steps.toInt()
        )
    }

    override fun waitUntilVisible(request: WaitUntilVisibleRequest) {
        automation.waitUntilVisible(
            uiSelector = request.selector.toUiSelector(),
            bySelector = request.selector.toBySelector(),
            index = request.selector.instance?.toInt() ?: 0
        )
    }

    override fun isPermissionDialogVisible(request: PermissionDialogVisibleRequest): PermissionDialogVisibleResponse {
        val visible = automation.isPermissionDialogVisible(timeout = request.timeoutMillis)
        return PermissionDialogVisibleResponse(visible)
    }

    override fun handlePermissionDialog(request: HandlePermissionRequest) {
        when (request.code) {
            HandlePermissionRequestCode.whileUsing -> automation.allowPermissionWhileUsingApp()
            HandlePermissionRequestCode.onlyThisTime -> automation.allowPermissionOnce()
            HandlePermissionRequestCode.denied -> automation.denyPermission()
        }
    }

    override fun setLocationAccuracy(request: SetLocationAccuracyRequest) {
        when (request.locationAccuracy) {
            SetLocationAccuracyRequestLocationAccuracy.coarse -> automation.selectCoarseLocation()
            SetLocationAccuracyRequestLocationAccuracy.fine -> automation.selectFineLocation()
        }
    }

    override fun debug() {
        // iOS only
    }

    override fun tapOnNotification(request: TapOnNotificationRequest) {
        if (request.index != null) {
            automation.tapOnNotification(request.index.toInt())
        } else if (request.selector != null) {
            automation.tapOnNotification(request.selector.toUiSelector())
        } else {
            throw PatrolException("tapOnNotification(): neither index nor selector are set")
        }
    }

    override fun markPatrolAppServiceReady() {
        PatrolServer.appReady.open()
    }
}
