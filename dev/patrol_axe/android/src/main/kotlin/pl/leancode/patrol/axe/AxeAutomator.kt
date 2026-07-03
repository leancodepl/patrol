package pl.leancode.patrol.axe

import android.app.Instrumentation
import androidx.test.platform.app.InstrumentationRegistry
import androidx.test.uiautomator.By
import androidx.test.uiautomator.UiDevice
import androidx.test.uiautomator.Until
import com.deque.mobile.devtools.AxeDevTools
import pl.leancode.patrol.Logger

class AxeAutomator {
    private lateinit var axe: AxeDevTools

    private val instrumentation: Instrumentation
        get() = InstrumentationRegistry.getInstrumentation()

    private val uiDevice: UiDevice
        get() = UiDevice.getInstance(instrumentation)

    private val targetContext
        get() = instrumentation.targetContext

    fun initSession(dequeApiKey: String, dequeProjectId: String) {
        axe = AxeDevTools()

        uiDevice.wait(Until.hasObject(By.pkg(targetContext.packageName).depth(0)), 5000)
        axe.startSession(dequeApiKey, dequeProjectId)
        axe.setInstrumentation(instrumentation)
        Logger.i("patrol_axe: axe session initialized")
    }

    fun scan(uploadToDashboard: Boolean, tags: Set<String>, scanName: String?) {
        uiDevice.wait(Until.hasObject(By.pkg(targetContext.packageName).depth(0)), 5000)
        Logger.i("patrol_axe: axe scan started, tags: $tags, scanName: $scanName")

        if (scanName != null) {
            axe.setScanName(scanName)
        }
        if (tags.isNotEmpty()) {
            axe.tagScanAs(tags)
        }

        val scanHandler = axe.scan()
        if (uploadToDashboard) {
            scanHandler?.uploadToDashboard()
        }
    }

    fun ignoreRules(rulesToIgnore: List<String>) {
        axe.ignoreRules(rulesToIgnore)
    }

    fun ignoreByViewIdResourceName(viewIdResourceName: String, ruleList: List<String>) {
        axe.ignoreByViewIdResourceName(viewIdResourceName, ruleList)
    }

    fun ignoreExperimental() {
        axe.ignoreExperimental()
    }
}
