package pl.leancode.patrol

import android.app.UiAutomation
import android.graphics.Rect
import android.os.Build
import android.view.accessibility.AccessibilityNodeInfo
import androidx.test.uiautomator.UiDevice
import pl.leancode.patrol.contracts.Contracts.AndroidNativeView
import pl.leancode.patrol.contracts.Contracts.NativeView
import pl.leancode.patrol.contracts.Contracts.Point2D
import pl.leancode.patrol.contracts.Contracts.Rectangle

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
    val apiLevelActual = (
        Build.VERSION.SDK_INT +
            if ("REL" == Build.VERSION.CODENAME) 0 else 1
        )
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
        className = obj.className?.toString(),
        text = obj.text?.toString(),
        contentDescription = obj.contentDescription?.toString(),
        focused = obj.isFocused,
        enabled = obj.isEnabled,
        childCount = obj.childCount.toLong(),
        resourceName = obj.viewIdResourceName,
        applicationPackage = obj.packageName?.toString(),
        children = children
    )
}

// This function is similar to AccessibilityNodeInfoDumper.dumpWindowHierarchy()
fun getWindowTreesV2(uiDevice: UiDevice, uiAutomation: UiAutomation): List<AndroidNativeView> {
    val windowRoots = getWindowRootsV2(uiDevice, uiAutomation)
    Logger.i("Found ${windowRoots.size} windowRoots")

    return windowRoots.map { node -> fromUiAccessibilityNodeInfoV2(node) }
}

// This is a private method from uiautomator.UiDevice.java
private fun getWindowRootsV2(uiDevice: UiDevice, uiAutomation: UiAutomation): Array<AccessibilityNodeInfo> {
    uiDevice.waitForIdle()
    val roots = mutableSetOf<AccessibilityNodeInfo>()

    // Start with the active window, which seems to sometimes be missing from the list returned
    // by the UiAutomation.
    val activeRoot: AccessibilityNodeInfo? = uiAutomation.rootInActiveWindow
    if (activeRoot != null) {
        roots.add(activeRoot)
    }

    // Support multi-window searches for API level 21 and up.
    val apiLevelActual = (
        Build.VERSION.SDK_INT +
            if ("REL" == Build.VERSION.CODENAME) 0 else 1
        )
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

private fun fromUiAccessibilityNodeInfoV2(obj: AccessibilityNodeInfo): AndroidNativeView {
    val children = mutableListOf<AndroidNativeView>()

    for (i in 0 until obj.childCount) {
        val child = obj.getChild(i)
        if (child != null && child.isVisibleToUser) {
            children.add(fromUiAccessibilityNodeInfoV2(child))
        }
    }

    var resourceName: String? = null

    try {
        resourceName = obj.viewIdResourceName
    } catch (e: Exception) {
        // ignore
    }

    val visibleBounds = Rect()
    obj.getBoundsInScreen(visibleBounds)

    return AndroidNativeView(
        className = obj.className?.toString(),
        text = obj.text?.toString(),
        contentDescription = obj.contentDescription?.toString(),
        childCount = obj.childCount.toLong(),
        resourceName = resourceName,
        applicationPackage = obj.packageName?.toString(),
        visibleCenter = Point2D(
            x = visibleBounds.centerX().toDouble(),
            y = visibleBounds.centerY().toDouble()
        ),
        visibleBounds = Rectangle(
            minX = visibleBounds.left.toDouble(),
            maxX = visibleBounds.right.toDouble(),
            minY = visibleBounds.top.toDouble(),
            maxY = visibleBounds.bottom.toDouble()
        ),
        isSelected = obj.isSelected,
        isScrollable = obj.isScrollable,
        isLongClickable = obj.isLongClickable,
        isFocusable = obj.isFocusable,
        isClickable = obj.isClickable,
        isChecked = obj.isChecked,
        isCheckable = obj.isCheckable,
        isEnabled = obj.isEnabled,
        isFocused = obj.isFocused,
        children = children
    )
}
