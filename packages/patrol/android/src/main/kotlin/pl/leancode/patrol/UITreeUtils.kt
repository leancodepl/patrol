package pl.leancode.patrol

import android.app.UiAutomation
import android.os.Build
import android.view.accessibility.AccessibilityNodeInfo
import androidx.test.uiautomator.UiDevice
import pl.leancode.patrol.contracts.Contracts.NativeView

// This function is similar to AccessibilityNodeInfoDumper.dumpWindowHierarchy()
fun getWindowTrees(uiDevice: UiDevice, uiAutomation: UiAutomation): List<NativeView> {
    val windowRoots = getWindowRoots(uiDevice, uiAutomation)
    Logger.i("Found ${windowRoots.size} windowRoots")

    return windowRoots.map { node -> fromUiAccessibilityNodeInfo(node) }
}

// This is a private method from uiautomator.UiDevice.java
private fun getWindowRoots(uiDevice: UiDevice, uiAutomation: UiAutomation): Array<AccessibilityNodeInfo> {
    uiDevice.waitForIdle()
    val roots = mutableSetOf<AccessibilityNodeInfo>()

    // Start with the active window, which seems to sometimes be missing from the list returned
    // by the UiAutomation.
    val activeRoot: AccessibilityNodeInfo? = uiAutomation.rootInActiveWindow
    if (activeRoot != null) {
        roots.add(activeRoot)
    }

    // Support multi-window searches for API level 21 and up.
    val apiLevelActual = (Build.VERSION.SDK_INT
            + if ("REL" == Build.VERSION.CODENAME) 0 else 1)
    if (apiLevelActual >= Build.VERSION_CODES.LOLLIPOP) {
        for (window in uiAutomation.windows) {
            val root = window.root
            if (root != null) {
                roots.add(root)
            }
        }
    }
    return roots.toTypedArray()
}

private fun fromUiAccessibilityNodeInfo(obj: AccessibilityNodeInfo): NativeView {
    val children = mutableListOf<NativeView>()

    for (i in 0 until obj.childCount) {
        val child = obj.getChild(i)
        if (child != null && child.isVisibleToUser) {
            children.add(fromUiAccessibilityNodeInfo(child))
        }
    }

    return NativeView(
        className = obj.className?.toString() ?: "",
        text = obj.text?.toString() ?: "",
        contentDescription = obj.contentDescription?.toString() ?: "",
        focused = obj.isFocused,
        enabled = obj.isEnabled,
        childCount = obj.childCount.toLong(),
        resourceName = obj.viewIdResourceName,
        applicationPackage = obj.packageName?.toString() ?: "",
        children = children
    )
}