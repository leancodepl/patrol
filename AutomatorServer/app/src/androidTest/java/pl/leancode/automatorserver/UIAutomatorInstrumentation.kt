package pl.leancode.automatorserver

import android.os.SystemClock
import android.widget.Button
import android.widget.EditText
import android.widget.TextView
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.UiObject2
import androidx.test.uiautomator.UiSelector
import kotlinx.serialization.Serializable

enum class NativeWidgetClass(`class`: Class<out Any>, name: String) {
    Text(TextView::class.java, "Text"),
    TextField(EditText::class.java, "TextField"),
    Button(Button::class.java, "Button")
}

@Serializable
data class Conditions(
    val `class`: String? = null,
    val enabled: Boolean? = null,
    val focused: Boolean? = null,
    val text: String? = null,
    val textContains: String? = null,
    val contentDescription: String? = null,
) {
    fun isEmpty(): Boolean {
        return (
            `class` == null &&
                enabled == null &&
                focused == null &&
                text == null &&
                textContains == null &&
                contentDescription == null
            )
    }
}

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
    private fun getDevice(): UiDevice {
        return UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
    }

    fun pressBack() {
        val device = getDevice()
        Logger.d("Before press back")
        device.pressBack()
        Logger.d("After press back")
        SystemClock.sleep(1000)
    }

    fun pressHome() {
        val device = getDevice()
        Logger.d("Before press home")
        device.pressHome()
        SystemClock.sleep(1000)
        Logger.d("After press home")
    }

    fun pressRecentApps() {
        val device = getDevice()
        Logger.d("Before press recent apps")
        device.pressRecentApps()
        SystemClock.sleep(1000)
        Logger.d("Before press recent apps")
    }

    fun pressDoubleRecentApps() {
        val device = getDevice()
        Logger.d("Before press double recent apps")
        device.pressRecentApps()
        SystemClock.sleep(1000)
        device.pressRecentApps()
        SystemClock.sleep(1000)
        Logger.d("After press double recent apps")
    }

    fun getNativeWidget(index: Int, conditions: Conditions): NativeWidget {
        return getNativeWidgets(conditions)[index]
    }

    fun getNativeWidgets(conditions: Conditions): List<NativeWidget> {
        val device = getDevice()

        if (conditions.isEmpty()) {
            return arrayListOf()
        }

        var selector = By.clazz(EditText::class.java)

        selector = selector.apply {
            conditions.enabled?.let {
                enabled(it)
            }

            conditions.focused?.let {
                focused(it)
            }

            conditions.text?.let {
                text(it)
            }

            conditions.textContains?.let {
                textContains(it)
            }

            conditions.contentDescription?.let {
                desc(it)
            }
        }

        return device.findObjects(selector).map { NativeWidget.fromUiObject(it) }
    }

    fun setNativeTextField(index: Int, text: String) {
        val device = getDevice()

        val selector = UiSelector().className(EditText::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
        uiObject.text = text
    }

    fun setNativeButton(index: Int) {
        val device = getDevice()

        val selector = UiSelector().className(Button::class.java).instance(index)
        val uiObject = device.findObject(selector)

        uiObject.click()
    }

    fun openNotifications() {
        val device = getDevice()
        device.openNotification()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}
