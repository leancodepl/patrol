import type { ActionParams, GetNativeViewsRequest } from "../contracts"

/**
 * Dumps the DOM of the page under test as a tree, for the Patrol DevTools
 * extension's inspector.
 *
 * On web the DOM is the equivalent of the native view hierarchy: Playwright
 * selectors (`getByRole`, `getByLabel`, `getByText`, `getByTestId`) resolve
 * against it, and with semantics enabled Flutter renders `<flt-semantics>`
 * elements carrying the roles and labels those selectors match. So this is the
 * tree you need to see when a web selector doesn't find what you expect.
 */
export async function getNativeViews({ pageManager }: ActionParams<GetNativeViewsRequest>) {
  const roots = await pageManager.activePage.evaluate(() => {
    // Structural/metadata elements carry nothing a selector could match.
    const skippedTags = new Set(["SCRIPT", "STYLE", "TEMPLATE", "NOSCRIPT", "LINK", "META", "BASE"])

    function ownText(element: Element): string | null {
      let text = ""
      for (const node of Array.from(element.childNodes)) {
        if (node.nodeType === Node.TEXT_NODE) {
          text += node.textContent ?? ""
        }
      }
      text = text.trim()
      return text.length === 0 ? null : text
    }

    function attr(element: Element, name: string): string | null {
      const value = element.getAttribute(name)
      return value === null || value.length === 0 ? null : value
    }

    function walk(element: Element): unknown {
      const children = Array.from(element.children)
        .filter(child => !skippedTags.has(child.tagName))
        .map(walk)

      const rect = element.getBoundingClientRect()
      const style = window.getComputedStyle(element)
      const isVisible =
        style.display !== "none" &&
        style.visibility !== "hidden" &&
        style.opacity !== "0" &&
        (rect.width > 0 || rect.height > 0)

      return {
        tagName: element.tagName,
        id: attr(element, "id"),
        role: attr(element, "role"),
        ariaLabel: attr(element, "aria-label"),
        testId: attr(element, "data-testid"),
        text: ownText(element),
        isEnabled: !("disabled" in element && (element as { disabled?: boolean }).disabled),
        isFocused: element === document.activeElement,
        isVisible,
        bounds: { x: rect.x, y: rect.y, width: rect.width, height: rect.height },
        childCount: children.length,
        children,
      }
    }

    const body = document.body
    return body === null ? [] : [walk(body)]
  })

  return { roots }
}
