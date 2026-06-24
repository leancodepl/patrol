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
import android.widget.AutoCompleteTextView
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
import pl.leancode.patrol.contracts.Contracts.Notification
import pl.leancode.patrol.contracts.Contracts.Point2D
import pl.leancode.patrol.contracts.Contracts.Rectangle
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.PrintWriter
import java.net.Socket
import java.util.concurrent.Executors
import java.util.concurrent.ScheduledExecutorService
import java.util.concurrent.TimeUnit
import kotlin.math.roundToInt
import pl.leancode.patrol.R.string as s

private fun fromUiObject2(obj: UiObject2): AndroidNativeView {
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
        children = obj.children?.map { fromUiObject2(it) } ?: listOf()
    )
}

class Automator private constructor() {
    private var timeoutMillis: Long = 10_000

    private lateinit var instrumentation: Instrumentation
    private lateinit var configurator: Configurator
    private lateinit var uiDevice: UiDevice
    private lateinit var targetContext: Context
    private lateinit var uiAutomation: UiAutomation

    private var mockLocationExecutor: ScheduledExecutorService? = null
    private var mockLocationTask: java.util.concurrent.ScheduledFuture<*>? = null

    @Volatile private var currentLatitude: Double = 0.0

    @Volatile private var currentLongitude: Double = 0.0

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

    fun getNativeViews(selector: BySelector): List<AndroidNativeView> {
        Logger.d("getNativeViewsV2()")

        val uiObjects2 = uiDevice.findObjects(selector)
        return uiObjects2.map { fromUiObject2(it) }
    }

    fun getNativeUITrees(): List<AndroidNativeView> {
        Logger.d("getNativeUITrees()")

        return getWindowTrees(uiDevice, uiAutomation)
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

        uiObject.setText(text)

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
        val uiObjectClassName = uiObject.getClassName()

        val supportedClassNames = setOf(
            EditText::class.java.name,
            AutoCompleteTextView::class.java.name
        )

        if (uiObjectClassName !in supportedClassNames) {
            var hasSupportedChild = false
            for (supportedClassName in supportedClassNames) {
                try {
                    uiObject = uiObject.getChild(UiSelector().className(supportedClassName))
                    hasSupportedChild = true
                    break
                } catch (e: UiObjectNotFoundException) {
                    // skip and try next
                }
            }

            if (!hasSupportedChild) {
                throw UiObjectNotFoundException("Could not find any supported child for $uiSelector")
            }
        }

        if (keyboardBehavior == KeyboardBehavior.showAndDismiss) {
            val rect = uiObject.visibleBounds
            val x = rect.left + rect.width() * dx
            val y = rect.top + rect.height() * dy
            uiDevice.click(x.toInt(), y.toInt())
        }

        uiObject.setText(text)

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

    fun sendKeyboardEnter() {
        Logger.d("sendKeyboardEnter()")
        val success = uiDevice.pressEnter()
        if (!success) {
            throw PatrolException("Could not send keyboard enter")
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
        Logger.d("tapOnNotificationV2($index)")

        try {
            val queryForBySelector = AndroidSelector(
                resourceName = "android:id/status_bar_latest_event_content"
            )
            val selector = queryForBySelector.toBySelector()
            if (waitForView(selector, index, timeout) == null) {
                throw UiObjectNotFoundException("$selector")
            }
            val queryForUiSelector = AndroidSelector(
                resourceName = "android:id/status_bar_latest_event_content",
                instance = index.toLong()
            )
            val obj = uiDevice.findObject(queryForUiSelector.toUiSelector())
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
            "com.android.permissioncontroller:id/permission_allow_foreground_only_button", // API >= 30 + API 29 (only for location permission)
            "com.android.permissioncontroller:id/permission_allow_all_button" // for gallery permission
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
            "com.android.permissioncontroller:id/permission_allow_one_time_button", // API >= 30
            "com.android.permissioncontroller:id/permission_allow_button" // only for files & gallery permission
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to allow permission once")

        uiObject.click()
    }

    fun denyPermission() {
        val identifiers = arrayOf(
            "com.android.packageinstaller:id/permission_deny_button", // API <= 28
            "com.android.permissioncontroller:id/permission_deny_button", // API >= 29 (first invocation)
            "com.android.permissioncontroller:id/permission_deny_and_dont_ask_again_button", // API >= 29 (second invocation)
            "android:id/button2" // for battery permission
        )

        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to deny permission")

        uiObject.click()
    }

    fun allowPermission() {
        val resourceId = "android:id/button1"
        val uiObject = waitForUiObjectByResourceId(resourceId, timeout = timeoutMillis)
            ?: throw UiObjectNotFoundException("button to allow permission")
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
        currentLatitude = latitude
        currentLongitude = longitude

        executeShellCommand("appops set $packageName android:mock_location allow")
        val locationManager = targetContext.getSystemService(LOCATION_SERVICE) as LocationManager

        val mockLocationProvider = LocationManager.GPS_PROVIDER

        try {
            locationManager.removeTestProvider(mockLocationProvider)
            Logger.d("Removed existing test provider")
        } catch (e: Exception) {
            Logger.d("No existing test provider to remove")
        }

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

        // Cancel any existing scheduled task
        mockLocationTask?.cancel(false)

        if (mockLocationExecutor == null) {
            mockLocationExecutor = Executors.newSingleThreadScheduledExecutor()
        }

        mockLocationTask = mockLocationExecutor?.scheduleAtFixedRate({
            try {
                val mockLocation = Location(mockLocationProvider)
                mockLocation.latitude = currentLatitude
                mockLocation.longitude = currentLongitude
                mockLocation.altitude = 0.0
                mockLocation.accuracy = 1.0f
                mockLocation.time = System.currentTimeMillis()
                mockLocation.elapsedRealtimeNanos = SystemClock.elapsedRealtimeNanos()

                locationManager.setTestProviderLocation(mockLocationProvider, mockLocation)
            } catch (e: Exception) {
                Logger.e("Error updating mock location: ${e.message}")
            }
        }, 0, 500, TimeUnit.MILLISECONDS)
    }

    fun stopMockLocation() {
        mockLocationTask?.cancel(false)
        mockLocationTask = null
        mockLocationExecutor?.shutdown()
        mockLocationExecutor = null

        try {
            val locationManager = targetContext.getSystemService(LOCATION_SERVICE) as LocationManager
            locationManager.removeTestProvider(LocationManager.GPS_PROVIDER)
            Logger.d("Mock location stopped and provider removed")
        } catch (e: Exception) {
            Logger.e("Error stopping mock location: ${e.message}")
        }
    }

    fun takeCameraPhoto(shutterButtonUiSelector: UiSelector, shutterButtonBySelector: BySelector, doneButtonUiSelector: UiSelector, doneButtonBySelector: BySelector, timeout: Long? = null) {
        if (isPermissionDialogVisible(timeout = AutomatorConstants.PERMISSION_DIALOG_WAIT_TIMEOUT)) {
            allowPermissionWhileUsingApp()
        }
        tap(shutterButtonUiSelector, shutterButtonBySelector, 0, timeout)

        // Try to tap done button, if not visible try Google Camera shutter button fallback
        val doneButton = waitForView(doneButtonBySelector, 0, timeout)
        if (doneButton != null) {
            Logger.d("Done button found, tapping it")
            doneButton.click()
            delay()
        } else {
            Logger.d("Done button not visible, trying fallback: Google Camera shutter button")
            val fallbackBySelector = By.res(AutomatorConstants.GOOGLE_CAMERA_SHUTTER_BUTTON_RES_ID)
            val fallbackButton = waitForView(fallbackBySelector, 0, timeout)
            if (fallbackButton != null) {
                Logger.d("Fallback button found, tapping it")
                fallbackButton.click()
                delay()
            } else {
                Logger.e("Neither done button nor fallback button found")
                throw PatrolException("takeCameraPhoto(): neither done button nor Google Camera shutter button found")
            }
        }
    }

    fun pickImageFromGallery(imageUiSelector: UiSelector, imageBySelector: BySelector, subMenuUiSelector: UiSelector?, subMenuBySelector: BySelector?, actionMenuUiSelector: UiSelector?, actionMenuBySelector: BySelector?, instance: Int, timeout: Long? = null) {
        if (subMenuBySelector != null && subMenuUiSelector != null) {
            tap(subMenuUiSelector, subMenuBySelector, 0)
        }
        tap(imageUiSelector, imageBySelector, instance.toInt())
        if (actionMenuBySelector != null && actionMenuUiSelector != null) {
            tap(actionMenuUiSelector, actionMenuBySelector, 0)
        }
    }

    fun pickMultipleImagesFromGallery(imageUiSelector: UiSelector, imageBySelector: BySelector, subMenuUiSelector: UiSelector?, subMenuBySelector: BySelector?, actionMenuUiSelector: UiSelector, actionMenuBySelector: BySelector, imageIndexes: List<Long>, timeout: Long? = null) {
        // For API level 33 and below, we need to change type of the list
        // to be able to select multiple images with taps instead of long press
        if (subMenuBySelector != null && subMenuUiSelector != null) {
            tap(subMenuUiSelector, subMenuBySelector, 0, timeout)
        }

        // Tap on multiple images
        for (i in imageIndexes) {
            val image = i.toInt()
            val imageUiSelectorWithInstance = imageUiSelector.instance(image)
            tap(imageUiSelectorWithInstance, imageBySelector, image, timeout)
        }

        tap(actionMenuUiSelector, actionMenuBySelector, 0, timeout)
    }

    fun isBiometricPromptVisible(timeout: Long): Boolean {
        Logger.d("isBiometricPromptVisible()")
        val identifiers = arrayOf(
            AutomatorConstants.BIOMETRIC_SCROLLVIEW_RES_ID,
            AutomatorConstants.BIOMETRIC_NEGATIVE_BUTTON_RES_ID,
            AutomatorConstants.BIOMETRIC_ICON_RES_ID,
        )
        val uiObject = waitForUiObjectByResourceId(*identifiers, timeout = timeout)
        return uiObject != null
    }

    fun performBiometricAuthentication(success: Boolean) {
        Logger.d("performBiometricAuthentication(success: $success)")

        if (success) {
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

            if (isEmulator) {
                simulateFingerprintSuccessOnEmulator()
            } else {
                throw PatrolException(
                    "performBiometricAuthentication(success: true) is only supported on Android emulators. " +
                    "On real devices, use success: false to cancel the biometric prompt instead."
                )
            }
        } else {
            clickBiometricCancelButton()
        }
    }

    fun enrollBiometricOnEmulator(pin: String) {
        Logger.d("enrollBiometricOnEmulator(pin=***)")

        // Wake the device if sleeping and dismiss any keyguard.
        uiDevice.wakeUp()
        delay(500)

        // Clear any existing screen lock (which also removes enrolled fingerprints, since
        // Android ties biometrics to the screen lock). Clearing converts the keyguard to a
        // swipe-only lock so wm dismiss-keyguard can bypass it in the next step.
        uiDevice.executeShellCommand("locksettings clear --old $pin")
        delay(500)

        // Dismiss while the keyguard is non-secure (swipe-only), before we set the PIN.
        // This leaves the device unlocked so the fingerprint enrollment activity can
        // launch without triggering a "Confirm your screen lock" prompt.
        uiDevice.executeShellCommand("wm dismiss-keyguard")
        delay(500)

        // Now set the PIN from an already-unlocked state — the active session stays open.
        uiDevice.executeShellCommand("locksettings set-pin $pin")
        delay(1000)

        // Launch the fingerprint enrollment flow directly via Settings intent.
        val intent = Intent("android.settings.FINGERPRINT_ENROLL").apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        targetContext.startActivity(intent)
        // On cold Settings starts (first test in a session), the enrollment activity can take
        // longer than 2 seconds to render its first screen. 4 seconds covers cold-start latency
        // on Google Play API 36 emulators.
        delay(4000)

        // Navigate through all pre-enrollment screens (intro/consent/PIN confirmation).
        // Different Android versions and OEM skins show these in different orders, so we
        // loop and handle each screen type as it appears rather than assuming a fixed order.
        // "MORE" must come before "I agree" — Pixel Imprint shows a scrollable terms screen
        // where "MORE" scrolls to reveal the "I agree" button at the bottom.
        // textMatches uses case-insensitive regex so "I agree", "I AGREE", etc. all match.
        val navButtons = listOf("I agree", "Agree", "Continue", "Next", "Start", "OK", "Add fingerprint", "MORE")
        var consecutiveMisses = 0
        for (navAttempt in 1..15) {
            val pinEntry = uiDevice.findObject(UiSelector().className("android.widget.EditText"))
            if (pinEntry.exists()) {
                consecutiveMisses = 0
                Logger.d("enrollBiometricOnEmulator: PIN confirmation screen (attempt $navAttempt)")
                pinEntry.setText(pin)
                delay(300)
                uiDevice.pressEnter()
                delay(2000)
                continue
            }

            var clicked = false
            for (buttonText in navButtons) {
                val btn = uiDevice.findObject(
                    UiSelector().textMatches("(?i)${Regex.escape(buttonText)}")
                )
                if (btn.exists()) {
                    consecutiveMisses = 0
                    Logger.d("enrollBiometricOnEmulator: tapping '$buttonText' (attempt $navAttempt)")
                    btn.click()
                    delay(3000)
                    clicked = true
                    break
                }
            }

            if (!clicked) {
                consecutiveMisses++
                Logger.d("enrollBiometricOnEmulator: no nav button found (attempt $navAttempt, miss $consecutiveMisses/3)")
                if (consecutiveMisses >= 3) {
                    Logger.d("enrollBiometricOnEmulator: 3 consecutive misses — confirmed on placement screen")
                    break
                }
                // Screen may still be loading — wait before retrying.
                delay(2000)
            }
        }

        // Signal patrol_cli to send host-side finger touches via `adb emu finger touch 1`.
        // Fingerprint enrollment on Google Play API 36 emulators does not respond to
        // finger touch events sent via the in-device telnet console — only the ADB
        // transport path (used by `adb emu`) actually advances the HAL enrollment counter.
        // patrol_cli detects this flag file and sends the touches from the host machine.
        uiDevice.executeShellCommand("touch /data/local/tmp/patrol_biometric_ready")
        Logger.d("enrollBiometricOnEmulator: wrote ready flag — waiting for patrol_cli finger touches")

        val deadline = System.currentTimeMillis() + 60_000
        var enrolled = false
        while (System.currentTimeMillis() < deadline) {
            delay(500)
            if (uiDevice.findObject(UiSelector().textMatches("(?i)done")).exists()) {
                enrolled = true
                Logger.d("enrollBiometricOnEmulator: 'Done' button appeared, enrollment complete")
                break
            }
        }

        if (!enrolled) {
            throw PatrolException(
                "enrollBiometricOnEmulator: 'Done' button not found after 60 seconds. " +
                "Ensure patrol_cli can run 'adb -s <device> emu finger touch 1' — " +
                "this requires an Android emulator and patrol_cli to be running the test."
            )
        }

        val doneBtn = uiDevice.findObject(UiSelector().textMatches("(?i)done"))
        Logger.d("enrollBiometricOnEmulator: tapping 'Done' to finish enrollment")
        doneBtn.click()
        delay(1000)
        // Android automatically returns focus to the test app after the enrollment task finishes.
        // Do NOT press back here — it would navigate away from the test app and destroy its activity.
    }

    private fun simulateFingerprintSuccessOnEmulator(fingerprintId: Int = 1) {
        // Wait for the BiometricPrompt dialog to be visible before triggering the fingerprint.
        if (!isBiometricPromptVisible(timeoutMillis)) {
            throw PatrolException(
                "BiometricPrompt did not appear within ${timeoutMillis}ms. " +
                "Make sure biometric authentication has been requested before calling this method."
            )
        }

        // Determine the emulator console port from the device serial (e.g. "emulator-5554" → 5554).
        val consolePort = getEmulatorConsolePort()
        Logger.d("simulateFingerprintSuccessOnEmulator: connecting to 10.0.2.2:$consolePort")

        val socket = try {
            Socket().also {
                it.bind(java.net.InetSocketAddress(java.net.InetAddress.getByName("0.0.0.0"), 0))
                it.connect(java.net.InetSocketAddress("10.0.2.2", consolePort), 5000)
                it.soTimeout = 5000
            }
        } catch (e: Exception) {
            throw PatrolException(
                "simulateFingerprintSuccessOnEmulator() failed to connect to emulator console " +
                "at 10.0.2.2:$consolePort: ${e.message}. " +
                "Ensure the test is running on an Android emulator."
            )
        }

        val writer = PrintWriter(socket.getOutputStream(), true)
        val reader = BufferedReader(InputStreamReader(socket.getInputStream()))

        try {
            val greeting = readConsoleUntilPrompt(reader)
            Logger.d("simulateFingerprintSuccessOnEmulator: greeting: $greeting")

            // Try finger touch immediately; some emulators allow it without auth.
            writer.println("finger touch $fingerprintId")
            val firstResponse = readConsoleUntilPrompt(reader)
            Logger.d("simulateFingerprintSuccessOnEmulator: first finger touch response: '$firstResponse'")

            val needsAuth = firstResponse.contains("not authenticated", ignoreCase = true) ||
                firstResponse.contains("KO: missing authentication", ignoreCase = true) ||
                (greeting.contains("Authentication required", ignoreCase = true) &&
                    !firstResponse.trimEnd().endsWith("OK"))

            if (needsAuth) {
                val authToken = readEmulatorAuthToken()
                    ?: throw PatrolException(
                        "simulateFingerprintSuccessOnEmulator() failed: emulator console requires " +
                        "authentication but no token was found. " +
                        "Push the auth token to the device with one of:\n" +
                        "  adb push ~/.emulator_console_auth_token /data/local/tmp/.emulator_console_auth_token\n" +
                        "  adb push ~/.emulator_console_auth_token /sdcard/.emulator_console_auth_token"
                    )

                writer.println("auth $authToken")
                val authResponse = readConsoleUntilPrompt(reader)
                Logger.d("simulateFingerprintSuccessOnEmulator: auth response: '$authResponse'")

                if (!authResponse.trimEnd().endsWith("OK")) {
                    throw PatrolException(
                        "simulateFingerprintSuccessOnEmulator() failed: emulator console rejected the auth token."
                    )
                }

                writer.println("finger touch $fingerprintId")
                val retryResponse = readConsoleUntilPrompt(reader)
                Logger.d("simulateFingerprintSuccessOnEmulator: retry finger touch response: '$retryResponse'")

                if (!retryResponse.trimEnd().endsWith("OK")) {
                    throw PatrolException(
                        "simulateFingerprintSuccessOnEmulator() failed: emulator rejected " +
                        "'finger touch $fingerprintId': '$retryResponse'. " +
                        "Make sure fingerprint ID $fingerprintId is enrolled in Settings > Security > Fingerprint."
                    )
                }
            } else if (!firstResponse.trimEnd().endsWith("OK")) {
                throw PatrolException(
                    "simulateFingerprintSuccessOnEmulator() failed: emulator rejected " +
                    "'finger touch $fingerprintId': '$firstResponse'. " +
                    "Make sure fingerprint ID $fingerprintId is enrolled in Settings > Security > Fingerprint."
                )
            }
        } catch (e: PatrolException) {
            throw e
        } catch (e: Exception) {
            throw PatrolException("simulateFingerprintSuccessOnEmulator() failed: ${e.message}")
        } finally {
            socket.close()
        }

        delay()
    }

    private fun getEmulatorConsolePort(): Int {
        val serial = uiDevice.executeShellCommand("getprop ro.serialno").trim()
        return if (serial.startsWith("emulator-")) {
            serial.substringAfter("emulator-").toIntOrNull() ?: 5554
        } else {
            5554
        }
    }

    private fun readEmulatorAuthToken(): String? {
        val candidates = listOf(
            "/data/local/tmp/.emulator_console_auth_token",
            "/sdcard/.emulator_console_auth_token",
        )
        for (path in candidates) {
            val token = try {
                uiDevice.executeShellCommand("cat $path 2>/dev/null").trim()
            } catch (e: Exception) {
                ""
            }
            if (token.isNotEmpty()) {
                Logger.d("readEmulatorAuthToken: found token at $path")
                return token
            }
        }
        return null
    }

    private fun readConsoleUntilPrompt(reader: BufferedReader, timeoutMs: Long = 5000): String {
        val sb = StringBuilder()
        val startTime = System.currentTimeMillis()

        while (System.currentTimeMillis() - startTime < timeoutMs) {
            if (reader.ready()) {
                val line = reader.readLine() ?: break
                sb.appendLine(line)
                if (line == "OK" || line.startsWith("KO")) break
            } else {
                Thread.sleep(100)
            }
        }

        return sb.toString()
    }

    private fun clickBiometricCancelButton() {
        // Wait for the dialog to appear before trying to interact with it.
        if (!isBiometricPromptVisible(timeoutMillis)) {
            throw PatrolException(
                "BiometricPrompt did not appear within ${timeoutMillis}ms. " +
                "Make sure biometric authentication has been requested before calling this method."
            )
        }

        // Try the well-known resource ID first (works on older API levels).
        val uiObject = waitForUiObjectByResourceId(
            AutomatorConstants.BIOMETRIC_NEGATIVE_BUTTON_RES_ID,
            timeout = 2_000,
        )
        if (uiObject != null) {
            Logger.d("clickBiometricCancelButton: clicking by resource ID")
            uiObject.click()
            delay()
            return
        }

        // Fallback: find by text (case-insensitive to handle "CANCEL" on API 36).
        val cancelPatterns = listOf("Cancel", "CANCEL", "Cancel authentication")
        for (text in cancelPatterns) {
            val obj = uiDevice.findObject(UiSelector().text(text))
            if (obj.exists()) {
                Logger.d("clickBiometricCancelButton: clicking by text '$text'")
                obj.click()
                delay()
                return
            }
        }
        val cancelByRegex = uiDevice.findObject(UiSelector().textMatches("(?i)cancel.*"))
        if (cancelByRegex.exists()) {
            Logger.d("clickBiometricCancelButton: clicking by cancel pattern")
            cancelByRegex.click()
            delay()
            return
        }

        // Final fallback: press Back to dismiss the dialog.
        // BiometricPrompt fires onAuthenticationError(ERROR_USER_CANCELED) on Back press,
        // which is equivalent to the user tapping Cancel.
        Logger.d("clickBiometricCancelButton: pressing Back to dismiss biometric dialog")
        uiDevice.pressBack()
        delay()
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
        uiSelector = uiSelector.text(Localization.getLocalizedString(targetContext, s.airplane_mode))
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
        uiSelector = uiSelector.text(
            Localization.getLocalizedString(
                targetContext,
                s.use_location
            )
        )
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
