package pl.leancode.automatorserver

import android.os.SystemClock
import android.widget.Button
import android.widget.EditText
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.Configurator
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiSelector
import kotlinx.serialization.Serializable

@Serializable
data class NativeWidget(
    val className: String?,
    val text: String?,
    val contentDescription: String?,
    val focused: Boolean?,
    val enabled: Boolean?,
) {
    companion object {
        fun fromUiObject(obj: UiObject2): NativeWidget {
            return NativeWidget(
                className = obj.className,
                text = obj.text,
                contentDescription = obj.contentDescription,
                focused = obj.isFocused,
                enabled = obj.isEnabled,
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

    private fun getDevice(): UiDevice {
        return UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    }

    private fun executeShellCommand(cmd: String) {
        val device = getDevice()
        device.executeShellCommand(cmd)
        delay()
    }

    private fun delay() = SystemClock.sleep(1000)

    fun pressBack() {
        val device = getDevice()
        Logger.d("Before press back")
        device.pressBack()
        Logger.d("After press back")
        delay()
    }

    fun pressHome() {
        val device = getDevice()
        Logger.d("Before press home")
        device.pressHome()
        delay()
        Logger.d("After press home")
    }

    fun pressRecentApps() {
        val device = getDevice()
        Logger.d("Before press recent apps")
        device.pressRecentApps()
        delay()
        Logger.d("After press recent apps")
    }

    fun pressDoubleRecentApps() {
        val device = getDevice()
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
        val device = getDevice()

        if (query.isEmpty()) {
            Logger.i("Query is empty")
            return arrayListOf()
        }

        var selector = By.clazz(query.clazz())

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

        return device.findObjects(selector).map { NativeWidget.fromUiObject(it) }
    }

    fun tap(index: Int) {
        val device = getDevice()

        val selector = UiSelector().className(Button::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
    }

    fun enterText(index: Int, text: String) {
        val device = getDevice()

        val selector = UiSelector().className(EditText::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
        uiObject.text = text
    }

    fun openNotifications() {
        val device = getDevice()

        Logger.d("Before open notifications")
        device.openNotification()
        Logger.d("After open notifications")
        delay()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}
