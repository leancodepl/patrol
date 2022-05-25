package pl.leancode.automatorserver

import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.UiDevice

class UIAutomatorInstrumentation {
    fun pressHome() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        device.pressHome()
    }

    fun pressRecentApps() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        device.pressRecentApps()
    }

    fun pressDoubleRecentApps() {
        val device = UiDevice.getInstance(InstrumentationRegistry.getInstrumentation())
        device.pressRecentApps()
        device.pressRecentApps()
    }

    companion object {
        val instance = UIAutomatorInstrumentation()
    }
}