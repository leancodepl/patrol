package pl.leancode.automatorserver

import android.os.SystemClock
import android.widget.Button
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiSelector
import androidx.test.uiautomator.Until
import junit.framework.TestCase.assertTrue
import kotlinx.serialization.Serializable

@Serializable
data class NativeWidget(
    val className: String?,
    val text: String?,
    val contentDescription: String?,
    val focused: Boolean?,
    val enabled: Boolean?,
    val childCount: Int?,
    val resourceName: String?,
    val applicationPackage: String?,
    val children: List<NativeWidget>?,
) {
    companion object {
        fun fromUiObject(obj: UiObject2): NativeWidget {
            return NativeWidget(
                className = obj.className,
                text = obj.text,
                contentDescription = obj.contentDescription,
                focused = obj.isFocused,
                enabled = obj.isEnabled,
                childCount = obj.childCount,
                resourceName = obj.resourceName,
                applicationPackage = obj.applicationPackage,
                children = obj.children?.map { fromUiObject(it) },
            )
        }
    }
}

class UIAutomatorInstrumentation {
    fun configure() {
        val configurator = Configurator.getInstance()
        configurator.waitForSelectorTimeout = 2000
        Logger.i("Android UiAutomator configuration:")
        Logger.i("\twaitForSelectorTimeout: ${configurator.waitForSelectorTimeout} ms")
        Logger.i("\twaitForIdleTimeout: ${configurator.waitForIdleTimeout} ms")
        Logger.i("\tkeyInjectionDelay: ${configurator.keyInjectionDelay} ms")
        Logger.i("\tactionAcknowledgmentTimeout: ${configurator.actionAcknowledgmentTimeout} ms")
        Logger.i("\tscrollAcknowledgmentTimeout: ${configurator.scrollAcknowledgmentTimeout} ms")
        Logger.i("\ttoolType: ${configurator.toolType}")
        Logger.i("\tuiAutomationFlags: ${configurator.uiAutomationFlags}")
    }

    private fun getUiDevice(): UiDevice {
        return UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    }

    private fun executeShellCommand(cmd: String) {
        val device = getUiDevice()
        device.executeShellCommand(cmd)
        delay()
    }

    private fun delay() = SystemClock.sleep(1000)

    fun pressBack() {
        val device = getUiDevice()
        Logger.d("Before press back")
        device.pressBack()
        Logger.d("After press back")
        delay()
    }

    fun pressHome() {
        val device = getUiDevice()
        Logger.d("Before press home")
        device.pressHome()
        delay()
        Logger.d("After press home")
    }

    fun pressRecentApps() {
        val device = getUiDevice()
        Logger.d("Before press recent apps")
        device.pressRecentApps()
        delay()
        Logger.d("After press recent apps")
    }

    fun pressDoubleRecentApps() {
        val device = getUiDevice()
        Logger.d("Before press double recent apps")
        device.pressRecentApps()
        delay()
        device.pressRecentApps()
        delay()
        Logger.d("After press double recent apps")
    }

    fun enableDarkMode() = executeShellCommand("cmd uimode night yes")

    fun disableDarkMode() = executeShellCommand("cmd uimode night no")

    fun disableWifi() = executeShellCommand("svc wifi disable")

    fun enableWifi() = executeShellCommand("svc wifi enable")

    fun disableCelluar() = executeShellCommand("svc data disable")

    fun enableCelluar() = executeShellCommand("svc data enable")

    fun enableBluetooth() = executeShellCommand("svc bluetooth enable")

    fun disableBluetooth() = executeShellCommand("svc bluetooth disable")

    fun getNativeWidgets(query: WidgetsQuery): List<NativeWidget> {
        val device = getUiDevice()

        if (query.isEmpty()) {
            Logger.i("Query is empty")
            return arrayListOf()
        }

        var selector = if (query.fullyQualifiedName != null) {
            Logger.i("Selector for fully qualified name ${query.fullyQualifiedName}")
            By.clazz(query.fullyQualifiedName)
        } else {
            By.clazz(query.clazz())
        }

        selector = selector.apply {
            query.enabled?.let {
                enabled(it)
            }

            query.focused?.let {
                focused(it)
            }

            query.text?.let {
                text(it)
            }

            query.textContains?.let {
                textContains(it)
            }

            query.contentDescription?.let {
                desc(it)
            }
        }

        return device.findObjects(selector).map {
            NativeWidget.fromUiObject(it)
        }
    }

    fun tap(index: Int) {
        val device = getUiDevice()

        val selector = UiSelector().className(Button::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
    }

    fun enterText(index: Int, text: String) {
        val device = getUiDevice()

        val selector = UiSelector().className(EditText::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
        uiObject.text = text
    }

    fun openNotifications() {
        val device = getUiDevice()

        Logger.d("Before open notifications")
        device.openNotification()
        Logger.d("After open notifications")
        delay()
    }

    fun tapOnNotification() {
        val device = getUiDevice()
        device.wait(Until.hasObject(By.pkg("com.android.systemui")), 2000)

        val notificationStackScroller = UiSelector()
            .packageName("com.android.systemui")
            .resourceId("com.android.systemui:id/notification_stack_scroller")
        val notificationStackScrollerUiObject: UiObject = device.findObject(notificationStackScroller)
        assertTrue(notificationStackScrollerUiObject.exists())

        val notiSelectorUiObject = notificationStackScrollerUiObject.getChild(UiSelector().index(0))
        assertTrue(notiSelectorUiObject.exists())

        notiSelectorUiObject.click()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}
