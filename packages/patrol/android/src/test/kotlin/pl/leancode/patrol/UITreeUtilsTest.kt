package pl.leancode.patrol

import android.view.accessibility.AccessibilityNodeInfo
import io.mockk.every
import io.mockk.mockk
import org.junit.Test
import kotlin.test.assertEquals

class UITreeUtilsTest {
    private fun node(
        text: String,
        visibleToUser: Boolean,
        children: List<AccessibilityNodeInfo> = emptyList(),
    ): AccessibilityNodeInfo {
        val node = mockk<AccessibilityNodeInfo>(relaxed = true)
        every { node.text } returns text
        every { node.isVisibleToUser } returns visibleToUser
        every { node.childCount } returns children.size
        children.forEachIndexed { i, child -> every { node.getChild(i) } returns child }
        return node
    }

    // root -> [A (visible), B (invisible) -> [C (visible)]]
    private fun tree(): AccessibilityNodeInfo {
        val grandchild = node("C", visibleToUser = true)
        val invisibleChild = node("B", visibleToUser = false, children = listOf(grandchild))
        val visibleChild = node("A", visibleToUser = true)
        return node("root", visibleToUser = true, children = listOf(visibleChild, invisibleChild))
    }

    @Test
    fun `drops invisible nodes and their subtrees by default`() {
        val view = fromUiAccessibilityNodeInfo(tree(), includeInvisibleNodes = false)

        assertEquals(listOf("A"), view.children.map { it.text })
    }

    @Test
    fun `keeps invisible nodes and their subtrees when includeInvisibleNodes is set`() {
        val view = fromUiAccessibilityNodeInfo(tree(), includeInvisibleNodes = true)

        assertEquals(listOf("A", "B"), view.children.map { it.text })
        assertEquals(listOf("C"), view.children[1].children.map { it.text })
    }
}
