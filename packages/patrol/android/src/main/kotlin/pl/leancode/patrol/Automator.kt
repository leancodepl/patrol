package pl.leancode.patrol

import android.app.Instrumentation
import android.app.UiAutomation
import android.content.Context
import android.content.Context.LOCATION_SERVICE
import android.content.Intent
import android.location.Location
import android.location.LocationManager
import android.location.provider.ProviderProperties
import android.net.Uri
import android.os.Build
import android.os.SystemClock
import android.provider.Settings
import android.view.KeyEvent.KEYCODE_VOLUME_DOWN
import android.view.KeyEvent.KEYCODE_VOLUME_UP
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.BySelector
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiObjectNotFoundException
import androidx.test.uiautomator.UiSelector
import pl.leancode.patrol.contracts.Contracts.AndroidNativeView
import pl.leancode.patrol.contracts.Contracts.AndroidSelector
import pl.leancode.patrol.contracts.Contracts.KeyboardBehavior
import pl.leancode.patrol.contracts.Contracts.NativeView
import pl.leancode.patrol.contracts.Contracts.Notification
import pl.leancode.patrol.contracts.Contracts.Point2D
import pl.leancode.patrol.contracts.Contracts.Rectangle
import pl.leancode.patrol.contracts.Contracts.Selector
import kotlin.math.roundToInt

private fun fromUiObject2(obj: UiObject2): NativeView {
    return NativeView(
        className = obj.className,
        text = obj.text,
        contentDescription = obj.contentDescription,
        focused = obj.isFocused,
        enabled = obj.isEnabled,
        childCount = obj.childCount.toLong(),
        resourceName = obj.resourceName,
        applicationPackage = obj.applicationPackage,
        children = obj.children?.map { fromUiObject2(it) } ?: listOf()
    )
}

private fun fromUiObject2V2(obj: UiObject2): AndroidNativeView {
    val bounds = obj.visibleBounds
    val center = obj.visibleCenter

    return AndroidNativeView(
        className = obj.className,
        text = obj.text,
        contentDescription = obj.contentDescription,
        isFocused = obj.isFocused,
        isEnabled = obj.isEnabled,
        childCount = obj.childCount.toLong(),
        resourceName = obj.resourceName,
        applicationPackage = obj.applicationPackage,
        isCheckable = obj.isCheckable,
        isChecked = obj.isChecked,
        isClickable = obj.isClickable,
        isFocusable = obj.isFocusable,
        isLongClickable = obj.isLongClickable,
        isScrollable = obj.isScrollable,
        isSelected = obj.isSelected,
        visibleBounds = Rectangle(
            minX = bounds.left.toDouble(),
            minY = bounds.top.toDouble(),
            maxX = bounds.right.toDouble(),
            maxY = bounds.top.toDouble()
        ),
        visibleCenter = Point2D(
            x = center.x.toDouble(),
            y = center.y.toDouble()
        ),
        children = obj.children?.map { fromUiObject2V2(it) } ?: listOf()
    )
}

class Automator private constructor() {
    private var timeoutMillis: Long = 10_000

    private lateinit var instrumentation: Instrumentation
    private lateinit var configurator: Configurator
    private lateinit var uiDevice: UiDevice
    private lateinit var targetContext: Context
    private lateinit var uiAutomation: UiAutomation

    fun initialize() {
        if (!this::instrumentation.isInitialized) {
            instrumentation = InstrumentationRegistry.getInstrumentation()
        }
        if (!this::targetContext.isInitialized) {
            targetContext = instrumentation.targetContext
        }
        if (!this::configurator.isInitialized) {
            configurator = Configurator.getInstance()
        }
        if (!this::uiDevice.isInitialized) {
            uiDevice = UiDevice.getInstance(instrumentation)
        }
        if (!this::uiAutomation.isInitialized) {
            uiAutomation = instrumentation.uiAutomation
        }
    }

    fun configure(waitForSelectorTimeout: Long) {
        timeoutMillis = waitForSelectorTimeout
        configurator.waitForSelectorTimeout = waitForSelectorTimeout
        configurator.waitForIdleTimeout = 5000
        configurator.keyInjectionDelay = 50

        configurator.uiAutomationFlags = UiAutomation.FLAG_DONT_SUPPRESS_ACCESSIBILITY_SERVICES

        Logger.i("Timeout: $timeoutMillis ms")
        Logger.i("Android UiAutomator configuration:")
        Logger.i("\twaitForSelectorTimeout: ${configurator.waitForSelectorTimeout} ms")
        Logger.i("\twaitForIdleTimeout: ${configurator.waitForIdleTimeout} ms")
        Logger.i("\tkeyInjectionDelay: ${configurator.keyInjectionDelay} ms")
        Logger.i("\tactionAcknowledgmentTimeout: ${configurator.actionAcknowledgmentTimeout} ms")
        Logger.i("\tscrollAcknowledgmentTimeout: ${configurator.scrollAcknowledgmentTimeout} ms")
        Logger.i("\ttoolType: ${configurator.toolType}")
        Logger.i("\tuiAutomationFlags: ${configurator.uiAutomationFlags}")
    }

    private fun executeShellCommand(cmd: String) {
        uiDevice.executeShellCommand(cmd)
        delay()
    }

    private fun delay(ms: Long = 1000) = SystemClock.sleep(ms)

    fun openApp(packageName: String) {
        val intent = targetContext.packageManager!!.getLaunchIntentForPackage(packageName)
            ?: throw Exception("intent for launching package \"$packageName\" is null. Make sure you have android.permission.QUERY_ALL_PACKAGES in AndroidManifest.xml")
        // intent?.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK) // clear out any previous task, i.e., make sure it starts on the initial screen
        targetContext.startActivity(intent) // starts the app
        delay()
    }

    fun openUrl(urlString: String) {
        Logger.d("openUrl($urlString)")
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(urlString))
        intent.addCategory(Intent.CATEGORY_BROWSABLE)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        targetContext.startActivity(intent)
        delay()
    }

    fun pressBack() {
        Logger.d("pressBack()")
        uiDevice.pressBack()
        delay()
    }

    fun pressHome() {
        Logger.d("pressHome()")
        uiDevice.pressHome()
        delay()
    }

    fun pressRecentApps() {
        Logger.d("pressRecentApps()")
        uiDevice.pressRecentApps()
        delay()
    }

    fun pressDoubleRecentApps() {
        Logger.d("pressDoubleRecentApps()")

        uiDevice.pressRecentApps()
        delay()
        uiDevice.pressRecentApps()
        delay()
    }

    fun enableDarkMode() = executeShellCommand("cmd uimode night yes")

    fun disableDarkMode() = executeShellCommand("cmd uimode night no")

    fun enableAirplaneMode() {
        val enabled = isAirplaneModeOn()
        if (enabled) {
            Logger.d("Airplane mode already enabled")
            return
        }
        Logger.d("Enabling airplane mode")
        toggleAirplaneMode()
    }

    fun disableAirplaneMode() {
        val enabled = isAirplaneModeOn()
        if (!enabled) {
            Logger.d("Airplane mode already disabled")
            return
        }
        Logger.d("Disabling airplane mode")
        toggleAirplaneMode()
    }

    fun disableCellular() = executeShellCommand("svc data disable")

    fun enableCellular() = executeShellCommand("svc data enable")

    fun disableWifi() = executeShellCommand("svc wifi disable")

    fun enableWifi() = executeShellCommand("svc wifi enable")

    fun enableBluetooth() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            executeShellCommand("svc bluetooth enable")
        } else {
            throw PatrolException("enableBluetooth method is not available in Android lower than 12")
        }
    }

    fun disableBluetooth() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            executeShellCommand("svc bluetooth disable")
        } else {
            throw PatrolException("disableBluetooth method is not available in Android lower than 12")
        }
    }

    fun enableLocation() {
        val enabled = isLocationEnabled()
        if (enabled) {
            Logger.d("Location already enabled")
            return
        } else {
            toggleLocation()
        }
    }

    fun disableLocation() {
        val enabled = isLocationEnabled()
        if (!enabled) {
            Logger.d("Location already disabled")
            return
        } else {
            toggleLocation()
        }
    }

    private fun isLocationEnabled(): Boolean {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            // This is a new method provided in API 28
            val lm = targetContext.getSystemService(Context.LOCATION_SERVICE) as LocationManager
            lm.isLocationEnabled
        } else {
            // This was deprecated in API 28
            val mode = Settings.Secure.getInt(
                targetContext.contentResolver,
                Settings.Secure.LOCATION_MODE,
                Settings.Secure.LOCATION_MODE_OFF
            )
            mode != Settings.Secure.LOCATION_MODE_OFF
        }
    }

    fun getNativeViews(selector: BySelector): List<NativeView> {
        Logger.d("getNativeViews()")

        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { fromUiObject2(it) }
    }

    fun getNativeViewsV2(selector: BySelector): List<AndroidNativeView> {
        Logger.d("getNativeViewsV2()")

        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { fromUiObject2V2(it) }
    }

    fun getNativeUITrees(): List<NativeView> {
        Logger.d("getNativeUITrees()")

        return getWindowTrees(uiDevice, uiAutomation)
    }

    fun getNativeUITreesV2(): List<AndroidNativeView> {
        Logger.d("getNativeUITreesV2()")

        return getWindowTreesV2(uiDevice, uiAutomation)
    }

    fun tap(uiSelector: UiSelector, bySelector: BySelector, index: Int, timeout: Long? = null) {
        Logger.d("tap(): $uiSelector, $bySelector")

        if (waitForView(bySelector, index, timeout) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }

        val uiObject = uiDevice.findObject(uiSelector)
        Logger.d("Clicking on UIObject with text: ${uiObject.text}")
        uiObject.click()
        delay()
    }

    fun doubleTap(
        uiSelector: UiSelector,
        bySelector: BySelector,
        index: Int,
        timeout: Long? = null,
        delayBetweenTaps: Long? = null
    ) {
        Logger.d("doubleTap(): $uiSelector, $bySelector")

        val uiObject = uiDevice.findObject(uiSelector)

        if (waitForView(bySelector, index, timeout) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }

        Logger.d("Performing double tap on UIObject with text: ${uiObject.text}")

        // Get the bounds of the UI element
        val rect = uiObject.bounds
        // Calculate the center point
        val centerX = rect.centerX()
        val centerY = rect.centerY()

        // Perform double click at the center
        Logger.d("After first click")

        uiDevice.click(centerX, centerY)

        // Customizable Delay between taps
        delay(ms = delayBetweenTaps ?: 300)

        Logger.d("After second click")
        uiDevice.click(centerX, centerY)
    }

    fun tapAt(x: Float, y: Float) {
        Logger.d("tapAt(x: $x, y: $y)")

        if (x !in 0f..1f) {
            throw IllegalArgumentException("x represents a percentage and must be between 0 and 1")
        }

        if (y !in 0f..1f) {
            throw IllegalArgumentException("y represents a percentage and must be between 0 and 1")
        }

        val displayX = (uiDevice.displayWidth * x).roundToInt()
        val displayY = (uiDevice.displayHeight * y).roundToInt()

        Logger.d("Clicking at display location (pixels) [$displayX, $displayY]")

        val successful = uiDevice.click(displayX, displayY)

        if (!successful) {
            throw IllegalArgumentException("Clicking at location [$displayX, $displayY] failed")
        }

        delay()
    }

    fun enterText(
        text: String,
        index: Int,
        keyboardBehavior: KeyboardBehavior,
        timeout: Long? = null,
        dx: Float,
        dy: Float
    ) {
        Logger.d("enterText(text: $text, index: $index)")

        val selector = By.clazz(EditText::class.java)
        if (waitForView(selector, index, timeout) == null) {
            throw UiObjectNotFoundException("$selector")
        }

        Logger.d("entering text \"$text\" to EditText at index $index")

        val uiSelector = UiSelector().className(EditText::class.java).instance(index)
        val uiObject = uiDevice.findObject(uiSelector)

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            val rect = uiObject.visibleBounds
            val x = rect.left + rect.width() * dx
            val y = rect.top + rect.height() * dy
            uiDevice.click(x.toInt(), y.toInt())
        }

        uiObject.text = text

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            pressBack() // Hide keyboard.
        }
    }

    fun enterText(
        text: String,
        uiSelector: UiSelector,
        bySelector: BySelector,
        index: Int,
        keyboardBehavior: KeyboardBehavior,
        timeout: Long? = null,
        dx: Float,
        dy: Float
    ) {
        Logger.d("enterText($text): $uiSelector, $bySelector")

        if (waitForView(bySelector, index, timeout) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }

        var uiObject = uiDevice.findObject(uiSelector)

        val uiObjectClassname = uiObject.getClassName()

        if (uiObjectClassname != EditText::class.java.name) {
            uiObject = uiObject.getChild(UiSelector().className(EditText::class.java))
        }

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            val rect = uiObject.visibleBounds
            val x = rect.left + rect.width() * dx
            val y = rect.top + rect.height() * dy
            uiDevice.click(x.toInt(), y.toInt())
        }

        uiObject.text = text

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            pressBack() // Hide keyboard.
        }
    }

    fun swipe(startX: Float, startY: Float, endX: Float, endY: Float, steps: Int) {
        Logger.d("swipe(startX: $startX, startY: $startY, endX: $endX, endY: $endY, steps: $steps)")

        if (startX !in 0f..1f) {
            throw IllegalArgumentException("startX represents a percentage and must be between 0 and 1")
        }

        if (startY !in 0f..1f) {
            throw IllegalArgumentException("startY represents a percentage and must be between 0 and 1")
        }

        if (endX !in 0f..1f) {
            throw IllegalArgumentException("endX represents a percentage and must be between 0 and 1")
        }

        if (endY !in 0f..1f) {
            throw IllegalArgumentException("endY represents a percentage and must be between 0 and 1")
        }

        val sX = (uiDevice.displayWidth * startX).roundToInt()
        val sY = (uiDevice.displayHeight * startY).roundToInt()
        val eX = (uiDevice.displayWidth * endX).roundToInt()
        val eY = (uiDevice.displayHeight * endY).roundToInt()

        val successful = uiDevice.swipe(sX, sY, eX, eY, steps)

        if (!successful) {
            throw IllegalArgumentException("Swipe failed")
        }

        delay()
    }

    fun waitUntilVisible(
        uiSelector: UiSelector,
        bySelector: BySelector,
        index: Int,
        timeout: Long? = null
    ) {
        Logger.d("waitUntilVisible(): $uiSelector, $bySelector")

        if (waitForView(bySelector, index, timeout) == null) {
            throw UiObjectNotFoundException("$uiSelector")
        }
    }

    fun pressVolumeUp() {
        Logger.d("pressVolumeUp")
        val success = uiDevice.pressKeyCode(KEYCODE_VOLUME_UP)
        if (!success) {
            throw PatrolException("Could not press volume up")
        }
        delay()
    }

    fun pressVolumeDown() {
        Logger.d("pressVolumeDown")
        val success = uiDevice.pressKeyCode(KEYCODE_VOLUME_DOWN)
        if (!success) {
            throw PatrolException("Could not press volume down")
        }
        delay()
    }

    fun openNotifications() {
        Logger.d("openNotifications()")
        val success = uiDevice.openNotification()
        if (!success) {
            throw PatrolException("Could not open notifications")
        }
        delay()
    }

    fun closeNotifications() {
        Logger.d("closeNotifications()")
        val success = uiDevice.pressBack()
        if (!success) {
            throw PatrolException("Could not close notifications")
        }
        delay()
    }

    fun openQuickSettings() {
        Logger.d("openNotifications()")
        val success = uiDevice.openQuickSettings()
        if (!success) {
            throw PatrolException("Could not open quick settings")
        }
        delay()
    }

    fun getNotifications(): List<Notification> {
        Logger.d("getNotifications()")

        val notificationContainers = mutableListOf<UiObject2>()
        val identifiers = listOf(
            "android:id/status_bar_latest_event_content", // notification not bundled
            "com.android.systemui:id/expandableNotificationRow" // notifications bundled
        )

        for (identifier in identifiers) {
            val objects = uiDevice.findObjects(By.res(identifier))
            if (identifier == "com.android.systemui:id/expandableNotificationRow") {
                // the first element is invalid
                objects.removeFirstOrNull()
            }

            Logger.i("Found ${objects.size} notification containers with resourceId \"$identifier\"")
            notificationContainers.addAll(objects)
        }

        Logger.d("Found ${notificationContainers.size} notifications")

        val notifications = mutableListOf<Notification>()
        for (notificationContainer in notificationContainers) {
            val appName = notificationContainer.findObject(By.res("android:id/app_name_text"))?.text

            val content = notificationContainer.findObject(By.res("android:id/text"))?.text
                ?: notificationContainer.findObject(By.res("android:id/big_text"))?.text
                ?: notificationContainer.findObject(By.res("com.android.systemui:id/notification_text"))?.text
            if (content == null) {
                Logger.e("Could not find content text")
            }

            val title = notificationContainer.findObject(By.res("android:id/title"))?.text
                ?: notificationContainer.findObject(By.res("com.android.systemui:id/notification_title"))?.text
            if (title == null) {
                Logger.e("Could not find title text")
            }

            val notification = Notification(
                appName = appName,
                content = content ?: "",
                title = title ?: ""
            )

            notifications.add(notification)
        }

        return notifications
    }

    fun tapOnNotification(index: Int, timeout: Long? = null) {
        Logger.d("tapOnNotification($index)")

        try {
            val query = Selector(
                resourceId = "android:id/status_bar_latest_event_content",
                instance = index.toLong()
            )
            val selector = query.toBySelector()
            if (waitForView(selector, index, timeout) == null) {
                throw UiObjectNotFoundException("$selector")
            }
            val obj = uiDevice.findObject(query.toUiSelector())
            obj.click()
        } catch (err: UiObjectNotFoundException) {
            throw UiObjectNotFoundException("notification at index $index")
        }

        delay()
    }

    fun tapOnNotificationV2(index: Int, timeout: Long? = null) {
        Logger.d("tapOnNotificationV2($index)")

        try {
            val query = AndroidSelector(
                resourceName = "android:id/status_bar_latest_event_content",
                instance = index.toLong()
            )
            val selector = query.toBySelector()
            if (waitForView(selector, index, timeout) == null) {
                throw UiObjectNotFoundException("$selector")
            }
            val obj = uiDevice.findObject(query.toUiSelector())
            obj.click()
        } catch (err: UiObjectNotFoundException) {
            throw UiObjectNotFoundException("notification at index $index")
        }

        delay()
    }

    fun tapOnNotification(selector: UiSelector, bySelector: BySelector, timeout: Long? = null) {
        Logger.d("tapOnNotification()")

        if (waitForView(bySelector, 0, timeout) == null) {
            throw UiObjectNotFoundException("$bySelector")
        }
        val obj = uiDevice.findObject(selector)
        obj.click()

        delay()
    }

    fun isPermissionDialogVisible(timeout: Long): Boolean {
        val identifiers = arrayOf(
            // while using
            "com.android.packageinstaller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_foreground_only_button",
            // once
            "com.android.packageinstaller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_button",
            "com.android.permissioncontroller:id/permission_allow_one_time_button",
            // deny
            "com.android.packageinstaller:id/permission_deny_button",
            "com.android.permissioncontroller:id/permission_deny_button",
            "com.android.permissioncontroller:id/permission_deny_and_dont_ask_again_button"
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeout)
        return uiObject != null
    }

    fun allowPermissionWhileUsingApp() {
        val identifiers = arrayOf(
            "com.android.packageinstaller:id/permission_allow_button", // API <= 28
            "com.android.permissioncontroller:id/permission_allow_button", // API 29
            "com.android.permissioncontroller:id/permission_allow_foreground_only_button" // API >= 30 + API 29 (only for location permission)
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to allow permission while using")

        uiObject.click()
    }

    fun allowPermissionOnce() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            // One-time permissions are available only on API 30 (R) and above.
            // See: https://developer.android.com/training/permissions/requesting#one-time
            allowPermissionWhileUsingApp()
            return
        }

        val identifiers = arrayOf(
            "com.android.permissioncontroller:id/permission_allow_one_time_button" // API >= 30
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to allow permission once")

        uiObject.click()
    }

    fun denyPermission() {
        val identifiers = arrayOf(
            "com.android.packageinstaller:id/permission_deny_button", // API <= 28
            "com.android.permissioncontroller:id/permission_deny_button", // API >= 29 (first invocation)
            "com.android.permissioncontroller:id/permission_deny_and_dont_ask_again_button" // API >= 29 (second invocation)
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to deny permission")

        uiObject.click()
    }

    fun selectFineLocation() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            Logger.i("Ignoring selectFineLocation() since it's not available on ${Build.VERSION.SDK_INT}")
            return
        }

        val resourceId =
            "com.android.permissioncontroller:id/permission_location_accuracy_radio_fine"

        val uiObject = waitForUiObjectByResourceId(resourceId, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to select fine location")

        uiObject.click()
    }

    fun selectCoarseLocation() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            Logger.i("Ignoring selectFineLocation() since it's not available on ${Build.VERSION.SDK_INT}")
            return
        }

        val resourceId =
            "com.android.permissioncontroller:id/permission_location_accuracy_radio_coarse"

        val uiObject = waitForUiObjectByResourceId(resourceId, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to select coarse location")

        uiObject.click()
    }

    fun setMockLocation(latitude: Double, longitude: Double, packageName: String) {
        executeShellCommand("appops set $packageName android:mock_location allow")
        val locationManager = targetContext.getSystemService(LOCATION_SERVICE) as LocationManager

        val mockLocationProvider = LocationManager.GPS_PROVIDER
        locationManager.addTestProvider(
            mockLocationProvider,
            false,
            false,
            false,
            false,
            true,
            true,
            true,
            ProviderProperties.POWER_USAGE_LOW,
            ProviderProperties.ACCURACY_FINE
        )

        locationManager.setTestProviderEnabled(mockLocationProvider, true)
        val mockLocation = Location(mockLocationProvider)
        mockLocation.latitude = latitude
        mockLocation.longitude = longitude
        mockLocation.altitude = 0.0
        mockLocation.accuracy = 1.0f
        mockLocation.time = System.currentTimeMillis()
        mockLocation.elapsedRealtimeNanos = System.nanoTime()
        locationManager.setTestProviderLocation(mockLocationProvider, mockLocation)
    }

    /**
     * Returns true if [bySelector] found a view at [index] within [timeoutMillis], false otherwise.
     */
    private fun waitForView(bySelector: BySelector, index: Int, timeout: Long? = null): UiObject2? {
        val startTime = System.currentTimeMillis()
        while (System.currentTimeMillis() - startTime < (timeout ?: timeoutMillis)) {
            val objects = uiDevice.findObjects(bySelector)
            if (objects.size > index && objects[index] != null) {
                return objects[index]
            }

            delay(ms = 500)
        }

        return null
    }

    private fun waitForUiObjectByResourceId(vararg identifiers: String, timeout: Long): UiObject? {
        val startTime = System.currentTimeMillis()
        while (System.currentTimeMillis() - startTime < timeout) {
            for (ident in identifiers) {
                val bySelector = By.res(ident)
                if (uiDevice.findObjects(bySelector).isNotEmpty()) {
                    return uiDevice.findObject(UiSelector().resourceId(ident))
                }
            }

            delay(ms = 500)
        }

        return null
    }

    private fun isAirplaneModeOn(): Boolean {
        return Settings.System.getInt(
            targetContext.contentResolver,
            Settings.Global.AIRPLANE_MODE_ON,
            0
        ) != 0
    }

    private fun toggleAirplaneMode() {
        val intent = Intent(Settings.ACTION_AIRPLANE_MODE_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        targetContext.startActivity(intent)

        var uiSelector = UiSelector()
        uiSelector = uiSelector.text("Airplane mode")
        val uiObject = uiDevice.findObject(uiSelector)
        if (uiObject != null) {
            uiObject.click()
            pressBack()
            delay()
        } else {
            throw PatrolException("Could not find airplane mode toggle")
        }
    }

    private fun toggleLocation() {
        val intent = Intent(Settings.ACTION_LOCATION_SOURCE_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        targetContext.startActivity(intent)

        var uiSelector = UiSelector()
        uiSelector = uiSelector.text("Use location")
        val uiObject = uiDevice.findObject(uiSelector)
        if (uiObject != null) {
            uiObject.click()
            pressBack()
            delay()
        } else {
            throw PatrolException("Could not find location toggle")
        }
    }

    companion object {
        val instance = Automator()
    }
}
