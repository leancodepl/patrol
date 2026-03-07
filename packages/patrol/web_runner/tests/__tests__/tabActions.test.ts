import { test, expect } from "@playwright/test"
import { EventEmitter } from "events"
import { PageManager } from "../pageManager"

// --- Imports from action files that DO NOT EXIST yet (RED phase) -----------
import { openNewTab } from "../actions/openNewTab"
import { closeTab } from "../actions/closeTab"
import { switchToTab } from "../actions/switchToTab"
import { getTabs } from "../actions/getTabs"
import { getCurrentTab } from "../actions/getCurrentTab"
import { waitForPopup } from "../actions/waitForPopup"

// ---------------------------------------------------------------------------
// Lightweight mocks for Playwright's Page and BrowserContext.
// Extended from the pattern in pageManager.test.ts with goto, close, and
// newPage capabilities needed by the tab management actions.
// ---------------------------------------------------------------------------

type MockPage = EventEmitter & {
  on: EventEmitter["on"]
  off: EventEmitter["off"]
  once: EventEmitter["once"]
  removeListener: EventEmitter["removeListener"]
  isClosed: () => boolean
  goto: (url: string) => Promise<void>
  close: () => Promise<void>
  bringToFront: () => Promise<void>
  url: () => string
}

type MockContext = EventEmitter & {
  on: EventEmitter["on"]
  off: EventEmitter["off"]
  once: EventEmitter["once"]
  removeListener: EventEmitter["removeListener"]
  newPage: () => Promise<MockPage>
  waitForEvent: (event: string) => Promise<MockPage>
}

function createMockPage(): MockPage {
  const emitter = new EventEmitter()
  let currentUrl = "about:blank"
  let closed = false

  const page = Object.assign(emitter, {
    on: emitter.on.bind(emitter),
    off: emitter.off.bind(emitter),
    once: emitter.once.bind(emitter),
    removeListener: emitter.removeListener.bind(emitter),
    isClosed: () => closed,
    goto: async (url: string) => {
      currentUrl = url
    },
    close: async () => {
      closed = true
      emitter.emit("close")
    },
    bringToFront: async () => {},
    url: () => currentUrl,
  }) as MockPage

  return page
}

function createMockContext(): MockContext {
  const emitter = new EventEmitter()

  const context = Object.assign(emitter, {
    on: emitter.on.bind(emitter),
    off: emitter.off.bind(emitter),
    once: emitter.once.bind(emitter),
    removeListener: emitter.removeListener.bind(emitter),
    newPage: async (): Promise<MockPage> => {
      const page = createMockPage()
      // Simulate Playwright behavior: context emits 'page' when a new page is created
      emitter.emit("page", page)
      return page
    },
    waitForEvent: (event: string): Promise<MockPage> => {
      return new Promise((resolve) => {
        emitter.once(event, (page: MockPage) => {
          resolve(page)
        })
      })
    },
  }) as MockContext

  return context
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test.describe("openNewTab", () => {
  test("creates a new page via context.newPage()", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const tabId = await openNewTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      { url: "https://example.com" },
      manager,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      context as any,
    )

    // A new page should have been registered in the manager
    expect(manager.count).toBe(2)
    expect(tabId).toBeDefined()
    expect(typeof tabId).toBe("string")
  })

  test("navigates the new page to the given URL", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const tabId = await openNewTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      { url: "https://example.com/test" },
      manager,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      context as any,
    )

    // The newly created page should have navigated to the URL
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const newPage = manager.resolve(tabId) as any as MockPage
    expect(newPage.url()).toBe("https://example.com/test")
  })

  test("returns the tab ID assigned by PageManager", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const tabId = await openNewTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      { url: "https://example.com" },
      manager,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      context as any,
    )

    // tab_0 is the initial page, so new tab should be tab_1
    expect(tabId).toBe("tab_1")
    expect(manager.ids).toContain(tabId)
  })
})

test.describe("closeTab", () => {
  test("resolves the page from pageManager and closes it", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    // Add a second page to close
    const secondPage = createMockPage()
    context.emit("page", secondPage)
    expect(manager.count).toBe(2)

    await closeTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      { tabId: "tab_1" },
      manager,
    )

    // The page should be removed from the manager (via the close event)
    expect(manager.count).toBe(1)
    expect(manager.ids).not.toContain("tab_1")
  })

  test("calls page.close() on the resolved page", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    await closeTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      { tabId: "tab_1" },
      manager,
    )

    expect(secondPage.isClosed()).toBe(true)
  })

  test("throws if tabId does not exist", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    await expect(
      closeTab(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        initialPage as any,
        { tabId: "nonexistent" },
        manager,
      ),
    ).rejects.toThrow()
  })

  test("throws when trying to close tab_0", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    await expect(
      closeTab(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        initialPage as any,
        { tabId: "tab_0" },
        manager,
      ),
    ).rejects.toThrow("Cannot close the initial Flutter tab")
  })
})

test.describe("switchToTab", () => {
  test("sets pageManager.activeId to the given tabId", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    await switchToTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      { tabId: "tab_1" },
      manager,
    )

    expect(manager.activeId).toBe("tab_1")
  })

  test("throws if tabId does not exist", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    await expect(
      switchToTab(
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        initialPage as any,
        { tabId: "nonexistent" },
        manager,
      ),
    ).rejects.toThrow()
  })
})

test.describe("getTabs", () => {
  test("returns all tab IDs from pageManager.ids", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    const thirdPage = createMockPage()
    context.emit("page", thirdPage)

    const result = await getTabs(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {} as Record<string, never>,
      manager,
    )

    expect(result.tabs).toEqual(expect.arrayContaining(["tab_0", "tab_1", "tab_2"]))
    expect(result.tabs).toHaveLength(3)
  })

  test("returns the active tab ID from pageManager.activeId", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)
    manager.activeId = "tab_1"

    const result = await getTabs(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {} as Record<string, never>,
      manager,
    )

    expect(result.activeTabId).toBe("tab_1")
  })
})

test.describe("getCurrentTab", () => {
  test("returns pageManager.activeId (default is tab_0)", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const result = await getCurrentTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {} as Record<string, never>,
      manager,
    )

    expect(result).toBe("tab_0")
  })

  test("returns the updated activeId after switching tabs", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)
    manager.activeId = "tab_1"

    const result = await getCurrentTab(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {} as Record<string, never>,
      manager,
    )

    expect(result).toBe("tab_1")
  })
})

test.describe("waitForPopup", () => {
  test("sets up context.waitForEvent('page') before executing the trigger action", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    // Simulate a popup appearing during the trigger action.
    // We schedule the popup emission so that waitForPopup can catch it.
    const popupPage = createMockPage()
    setTimeout(() => {
      context.emit("page", popupPage)
    }, 10)

    const tabId = await waitForPopup(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {
        triggerAction: "tap",
        triggerParams: { selector: { text: "Open popup" } },
      },
      manager,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      context as any,
    )

    expect(tabId).toBeDefined()
    expect(typeof tabId).toBe("string")
  })

  test("returns the tab ID of the newly appeared popup page", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const popupPage = createMockPage()
    setTimeout(() => {
      context.emit("page", popupPage)
    }, 10)

    const tabId = await waitForPopup(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {
        triggerAction: "tap",
        triggerParams: { selector: { text: "Open popup" } },
      },
      manager,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      context as any,
    )

    // The popup should be registered and the returned ID should resolve to it
    expect(manager.ids).toContain(tabId)
    expect(manager.resolve(tabId)).toBe(popupPage)
  })

  test("the popup page is registered in the PageManager", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const popupPage = createMockPage()
    setTimeout(() => {
      context.emit("page", popupPage)
    }, 10)

    const countBefore = manager.count

    const tabId = await waitForPopup(
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      initialPage as any,
      {
        triggerAction: "tap",
        triggerParams: { selector: { text: "Open popup" } },
      },
      manager,
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      context as any,
    )

    expect(manager.count).toBe(countBefore + 1)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(manager.idOf(popupPage as any)).toBe(tabId)
  })
})
