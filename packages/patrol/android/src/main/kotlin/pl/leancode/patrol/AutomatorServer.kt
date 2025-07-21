package pl.leancode.patrol

import android.os.Build
import pl.leancode.patrol.contracts.Contracts
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
import pl.leancode.patrol.contracts.Contracts.Selector
import pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequest
import pl.leancode.patrol.contracts.Contracts.SetLocationAccuracyRequestLocationAccuracy
import pl.leancode.patrol.contracts.Contracts.SetMockLocationRequest
import pl.leancode.patrol.contracts.Contracts.SwipeRequest
import pl.leancode.patrol.contracts.Contracts.TapOnNotificationRequest
import pl.leancode.patrol.contracts.Contracts.TapRequest
import pl.leancode.patrol.contracts.Contracts.WaitUntilVisibleRequest
import pl.leancode.patrol.contracts.NativeAutomatorServer
import java.util.Locale

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

    override fun openUrl(request: Contracts.OpenUrlRequest) {
        automation.openUrl(request.url)
    }

    override fun getNativeUITree(request: GetNativeUITreeRequest): GetNativeUITreeRespone {
        return if (request.useNativeViewHierarchy) {
            val trees = automation.getNativeUITrees()
            GetNativeUITreeRespone(roots = trees, androidRoots = listOf(), iOSroots = listOf())
        } else {
            val trees = automation.getNativeUITreesV2()
            GetNativeUITreeRespone(roots = listOf(), androidRoots = trees, iOSroots = listOf())
        }
    }

    override fun pressVolumeUp() {
        automation.pressVolumeUp()
    }

    override fun pressVolumeDown() {
        automation.pressVolumeDown()
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

    override fun enableLocation() {
        automation.enableLocation()
    }

    override fun disableLocation() {
        automation.disableLocation()
    }

    override fun getNativeViews(request: GetNativeViewsRequest): GetNativeViewsResponse {
        if (request.selector != null) {
            val views = automation.getNativeViews(request.selector.toBySelector())
            return GetNativeViewsResponse(
                nativeViews = views,
                iosNativeViews = listOf(),
                androidNativeViews = listOf()

            )
        } else if (request.androidSelector != null) {
            val views = automation.getNativeViewsV2(request.androidSelector.toBySelector())
            return GetNativeViewsResponse(
                nativeViews = listOf(),
                androidNativeViews = views,
                iosNativeViews = listOf()
            )
        } else {
            // When both selectors are null, return the full native tree
            val trees = automation.getNativeUITrees()
            val treesV2 = automation.getNativeUITreesV2()
            return GetNativeViewsResponse(
                nativeViews = trees,
                androidNativeViews = treesV2,
                iosNativeViews = listOf()
            )
        }
    }

    override fun getNotifications(request: GetNotificationsRequest): GetNotificationsResponse {
        val notifs = automation.getNotifications()
        return GetNotificationsResponse(notifs)
    }

    override fun tap(request: TapRequest) {
        if (request.selector != null) {
            // Remove instance before creating bySelector, as it's not supported
            var selector2 = request.selector.copy(instance = null)
            val bySelector = selector2.toBySelector()

            automation.tap(
                uiSelector = request.selector.toUiSelector(),
                bySelector = bySelector,
                index = request.selector.instance?.toInt() ?: 0,
                timeout = request.timeoutMillis
            )
        } else if (request.androidSelector != null) {
            // Remove instance before creating bySelector, as it's not supported
            var androidSelector2 = request.androidSelector.copy(instance = null)
            val bySelector = androidSelector2.toBySelector()

            automation.tap(
                uiSelector = request.androidSelector.toUiSelector(),
                bySelector = bySelector,
                index = request.androidSelector.instance?.toInt() ?: 0,
                timeout = request.timeoutMillis
            )
        } else {
            throw PatrolException("tap(): neither selector nor androidSelector are set")
        }
    }

    override fun doubleTap(request: TapRequest) {
        if (request.selector != null) {
            automation.doubleTap(
                uiSelector = request.selector.toUiSelector(),
                bySelector = request.selector.toBySelector(),
                index = request.selector.instance?.toInt() ?: 0,
                timeout = request.timeoutMillis,
                delayBetweenTaps = request.delayBetweenTapsMillis
            )
        } else if (request.androidSelector != null) {
            automation.doubleTap(
                uiSelector = request.androidSelector.toUiSelector(),
                bySelector = request.androidSelector.toBySelector(),
                index = request.androidSelector.instance?.toInt() ?: 0,
                timeout = request.timeoutMillis,
                delayBetweenTaps = request.delayBetweenTapsMillis
            )
        } else {
            throw PatrolException("doubleTap(): neither selector nor androidSelector are set")
        }
    }

    override fun tapAt(request: Contracts.TapAtRequest) {
        automation.tapAt(
            x = request.x.toFloat(),
            y = request.y.toFloat()
        )
    }

    override fun enterText(request: EnterTextRequest) {
        if (request.index != null) {
            automation.enterText(
                text = request.data,
                index = request.index.toInt(),
                keyboardBehavior = request.keyboardBehavior,
                timeout = request.timeoutMillis,
                dx = request.dx?.toFloat() ?: 0.9f,
                dy = request.dy?.toFloat() ?: 0.9f
            )
        } else if (request.selector != null) {
            automation.enterText(
                text = request.data,
                uiSelector = request.selector.toUiSelector(),
                bySelector = request.selector.toBySelector(),
                index = request.selector.instance?.toInt() ?: 0,
                keyboardBehavior = request.keyboardBehavior,
                timeout = request.timeoutMillis,
                dx = request.dx?.toFloat() ?: 0.9f,
                dy = request.dy?.toFloat() ?: 0.9f
            )
        } else if (request.androidSelector != null) {
            automation.enterText(
                text = request.data,
                uiSelector = request.androidSelector.toUiSelector(),
                bySelector = request.androidSelector.toBySelector(),
                index = request.androidSelector.instance?.toInt() ?: 0,
                keyboardBehavior = request.keyboardBehavior,
                timeout = request.timeoutMillis,
                dx = request.dx?.toFloat() ?: 0.9f,
                dy = request.dy?.toFloat() ?: 0.9f
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
        if (request.selector != null) {
            automation.waitUntilVisible(
                uiSelector = request.selector.toUiSelector(),
                bySelector = request.selector.toBySelector(),
                index = request.selector.instance?.toInt() ?: 0,
                timeout = request.timeoutMillis
            )
        } else if (request.androidSelector != null) {
            automation.waitUntilVisible(
                uiSelector = request.androidSelector.toUiSelector(),
                bySelector = request.androidSelector.toBySelector(),
                index = request.androidSelector.instance?.toInt() ?: 0,
                timeout = request.timeoutMillis
            )
        } else {
            throw PatrolException("waitUntilVisible(): neither selector nor androidSelector are set")
        }
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

    override fun takeCameraPhoto(request: Contracts.TakeCameraPhotoRequest) {
        val isEmulator = isVirtualDevice().isVirtualDevice
        if (request.isNative2) {
            val shutterButtonSelector = request.androidShutterButtonSelector ?: Contracts.AndroidSelector(
                resourceName = if (isEmulator) "com.android.camera2:id/shutter_button" else "com.google.android.GoogleCamera:id/shutter_button",
                instance = 0
            )
            val doneButtonSelector = request.androidDoneButtonSelector ?: Contracts.AndroidSelector(
                resourceName = if (isEmulator) "com.android.camera2:id/done_button" else "com.google.android.GoogleCamera:id/done_button",
                instance = 0
            )
            val shutterButtonSelector2 = shutterButtonSelector.copy(instance = null)
            val doneButtonSelector2 = doneButtonSelector.copy(instance = null)
            automation.takeCameraPhoto(
                shutterButtonSelector.toUiSelector(),
                shutterButtonSelector2.toBySelector(),
                doneButtonSelector.toUiSelector(),
                doneButtonSelector2.toBySelector(),
                request.timeoutMillis
            )
        } else {
            val shutterButtonSelector = request.shutterButtonSelector ?: Selector(
                resourceId = if (isEmulator) "com.android.camera2:id/shutter_button" else "com.google.android.GoogleCamera:id/shutter_button",
                instance = 0
            )
            val doneButtonSelector = request.doneButtonSelector ?: Selector(
                resourceId = if (isEmulator) "com.android.camera2:id/done_button" else "com.google.android.GoogleCamera:id/done_button",
                instance = 0
            )
            val shutterButtonSelector2 = shutterButtonSelector.copy(instance = null)
            val doneButtonSelector2 = doneButtonSelector.copy(instance = null)
            automation.takeCameraPhoto(
                shutterButtonSelector.toUiSelector(),
                shutterButtonSelector2.toBySelector(),
                doneButtonSelector.toUiSelector(),
                doneButtonSelector2.toBySelector(),
                request.timeoutMillis
            )
        }
    }

    override fun pickImageFromGallery(request: Contracts.PickImageFromGalleryRequest) {
        val apiLvl = getOsVersion().osVersion
        if (request.isNative2) {
            val androidImageSelector = request.androidImageSelector ?: Contracts.AndroidSelector(
                resourceName = if (apiLvl >= 34) "com.google.android.providers.media.module:id/icon_thumbnail" else "com.google.android.documentsui:id/icon_thumb",
                instance = request.imageIndex ?: 0
            )

            val androidSubMenuSelector = if (apiLvl < 34) {
                Contracts.AndroidSelector(
                    resourceName = "com.google.android.documentsui:id/sub_menu_list",
                    instance = 0
                )
            } else {
                null
            }
            val androidActionMenuSelector = if (apiLvl < 34) {
                Contracts.AndroidSelector(
                    resourceName = "com.google.android.documentsui:id/action_menu_select",
                    instance = 0
                )
            } else {
                null
            }

            // Remove instance before creating bySelector, as it's not supported
            val androidImageSelector2 = androidImageSelector.copy(instance = null)
            val androidSubMenuSelector2 = androidSubMenuSelector?.copy(instance = null)
            val androidActionMenuSelector2 = androidActionMenuSelector?.copy(instance = null)

            automation.pickImageFromGallery(
                androidImageSelector.toUiSelector(),
                androidImageSelector2.toBySelector(),
                androidSubMenuSelector2?.toUiSelector(),
                androidSubMenuSelector2?.toBySelector(),
                androidActionMenuSelector2?.toUiSelector(),
                androidActionMenuSelector2?.toBySelector(),
                androidImageSelector.instance!!.toInt(),
                request.timeoutMillis
            )
        } else {
            val androidImageSelector = request.imageSelector ?: Selector(
                resourceId = if (apiLvl >= 34) "com.google.android.providers.media.module:id/icon_thumbnail" else "com.google.android.documentsui:id/icon_thumb",
                instance = request.imageIndex ?: 0
            )

            val androidSubMenuSelector = if (apiLvl < 34) {
                Selector(
                    resourceId = "com.google.android.documentsui:id/sub_menu_list",
                    instance = 0
                )
            } else {
                null
            }
            val androidActionMenuSelector = if (apiLvl < 34) {
                Selector(
                    resourceId = "com.google.android.documentsui:id/action_menu_select",
                    instance = 0
                )
            } else {
                null
            }

            // Remove instance before creating bySelector, as it's not supported
            val androidImageSelector2 = androidImageSelector.copy(instance = null)
            val androidSubMenuSelector2 = androidSubMenuSelector?.copy(instance = null)
            val androidActionMenuSelector2 = androidActionMenuSelector?.copy(instance = null)

            automation.pickImageFromGallery(
                androidImageSelector.toUiSelector(),
                androidImageSelector2.toBySelector(),
                androidSubMenuSelector2?.toUiSelector(),
                androidSubMenuSelector2?.toBySelector(),
                androidActionMenuSelector2?.toUiSelector(),
                androidActionMenuSelector2?.toBySelector(),
                androidImageSelector.instance!!.toInt(),
                request.timeoutMillis
            )
        }
    }

    override fun pickMultipleImagesFromGallery(request: Contracts.PickMultipleImagesFromGalleryRequest) {
        val apiLvl = getOsVersion().osVersion
        if (request.isNative2) {
            val androidImageSelector = request.androidImageSelector ?: Contracts.AndroidSelector(
                resourceName = if (apiLvl >= 34) "com.google.android.providers.media.module:id/icon_thumbnail" else "com.google.android.documentsui:id/icon",
                instance = 0
            )
            val androidSubMenuSelector = if (apiLvl < 34) {
                Contracts.AndroidSelector(
                    resourceName = "com.google.android.documentsui:id/sub_menu_list",
                    instance = 0
                )
            } else {
                null
            }
            val androidActionMenuSelector = Selector(
                resourceId = if (apiLvl >= 34) "com.google.android.providers.media.module:id/button_add" else "com.google.android.documentsui:id/action_menu_select",
                instance = 0
            )

            // Remove instance before creating bySelector, as it's not supported
            val androidImageSelector2 = androidImageSelector.copy(instance = null)
            val androidSubMenuSelector2 = androidSubMenuSelector?.copy(instance = null)
            val androidActionMenuSelector2 = androidActionMenuSelector.copy(instance = null)

            automation.pickMultipleImagesFromGallery(
                androidImageSelector.toUiSelector(),
                androidImageSelector2.toBySelector(),
                androidSubMenuSelector?.toUiSelector(),
                androidSubMenuSelector2?.toBySelector(),
                androidActionMenuSelector.toUiSelector(),
                androidActionMenuSelector2.toBySelector(),
                request.imageIndexes,
                request.timeoutMillis
            )
        } else {
            val androidImageSelector = request.imageSelector ?: Selector(
                resourceId = if (apiLvl >= 34) "com.google.android.providers.media.module:id/icon_thumbnail" else "com.google.android.documentsui:id/icon_thumb",
                instance = 0
            )

            val androidSubMenuSelector = if (apiLvl < 34) {
                Selector(
                    resourceId = "com.google.android.documentsui:id/sub_menu_list",
                    instance = 0
                )
            } else {
                null
            }
            val androidActionMenuSelector = Selector(
                resourceId = if (apiLvl >= 34) "com.google.android.providers.media.module:id/button_add" else "com.google.android.documentsui:id/action_menu_select",
                instance = 0
            )

            // Remove instance before creating bySelector, as it's not supported
            val androidImageSelector2 = androidImageSelector.copy(instance = null)
            val androidSubMenuSelector2 = androidSubMenuSelector?.copy(instance = null)
            val androidActionMenuSelector2 = androidActionMenuSelector.copy(instance = null)

            automation.pickMultipleImagesFromGallery(
                androidImageSelector.toUiSelector(),
                androidImageSelector2.toBySelector(),
                androidSubMenuSelector?.toUiSelector(),
                androidSubMenuSelector2?.toBySelector(),
                androidActionMenuSelector.toUiSelector(),
                androidActionMenuSelector2.toBySelector(),
                request.imageIndexes,
                request.timeoutMillis
            )
        }
    }

    override fun setMockLocation(request: SetMockLocationRequest) {
        automation.setMockLocation(request.latitude, request.longitude, request.packageName)
    }

    override fun debug() {
        // iOS only
    }

    override fun tapOnNotification(request: TapOnNotificationRequest) {
        if (request.index != null) {
            automation.tapOnNotification(request.index.toInt(), timeout = request.timeoutMillis)
        } else if (request.selector != null) {
            val selector = request.selector
            automation.tapOnNotification(
                selector.toUiSelector(),
                selector.toBySelector(),
                timeout = request.timeoutMillis
            )
        } else if (request.androidSelector != null) {
            val selector = request.androidSelector
            automation.tapOnNotification(
                selector.toUiSelector(),
                selector.toBySelector(),
                timeout = request.timeoutMillis
            )
        } else {
            throw PatrolException("tapOnNotification(): neither index nor selector are set")
        }
    }

    override fun markPatrolAppServiceReady() {
        PatrolServer.appReady.open()
    }

    override fun isVirtualDevice(): Contracts.IsVirtualDeviceResponse {
        val isEmulator = Build.FINGERPRINT.startsWith("generic") ||
            Build.FINGERPRINT.startsWith("unknown") ||
            Build.MODEL.contains("google_sdk") ||
            Build.MODEL.contains("Emulator") ||
            Build.MODEL.contains("Android SDK built for x86") ||
            Build.MODEL.contains("Android SDK built for arm64") ||
            Build.MODEL.contains("sdk_gphone") ||
            Build.MANUFACTURER.contains("Genymotion") ||
            Build.HARDWARE.contains("ranchu") ||
            Build.HARDWARE.contains("goldfish") ||
            Build.PRODUCT.contains("sdk_gphone") ||
            Build.PRODUCT.contains("google_sdk") ||
            Build.PRODUCT.contains("sdk") ||
            (Build.BRAND.startsWith("generic") && Build.DEVICE.startsWith("generic")) ||
            "google_sdk" == Build.PRODUCT

        return Contracts.IsVirtualDeviceResponse(isEmulator)
    }

    override fun getOsVersion(): Contracts.GetOsVersionResponse {
        return Contracts.GetOsVersionResponse(Build.VERSION.SDK_INT.toLong())
    }
}
