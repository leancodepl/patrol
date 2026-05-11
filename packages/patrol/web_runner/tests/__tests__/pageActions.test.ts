import { test, expect } from "@playwright/test"
import { EventEmitter } from "events"
import { PageManager } from "../pageManager"

// --- Imports from action files that DO NOT EXIST yet (RED phase) -----------
import { openNewPage } from "../actions/openNewPage"
import { closePage } from "../actions/closePage"
import { switchToPage } from "../actions/switchToPage"
import { getPages } from "../actions/getPages"
import { getCurrentPage } from "../actions/getCurrentPage"
import { waitForPopup } from "../actions/waitForPopup"

// ---------------------------------------------------------------------------
// Lightweight mocks for Playwright's Page and BrowserContext.
// Extended from the pattern in pageManager.test.ts with goto, close, and
// newPage capabilities needed by the page management actions.
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
      return new Promise(resolve => {
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

test.describe("openNewPage", () => {
  test("creates a new page via context.newPage()", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const pageId = await openNewPage({
      pageManager: manager,
      params: { url: "https://example.com" },
    })

    // A new page should have been registered in the manager
    expect(manager.count).toBe(2)
    expect(pageId).toBeDefined()
    expect(typeof pageId).toBe("string")
  })

  test("navigates the new page to the given URL", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const pageId = await openNewPage({
      pageManager: manager,
      params: { url: "https://example.com/test" },
    })

    // The newly created page should have navigated to the URL
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const newPage = manager.resolve(pageId) as any as MockPage
    expect(newPage.url()).toBe("https://example.com/test")
  })

  test("returns the page ID assigned by PageManager", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const pageId = await openNewPage({
      pageManager: manager,
      params: { url: "https://example.com" },
    })

    // page_0 is the initial page, so new page should be page_1
    expect(pageId).toBe("page_1")
    expect(manager.ids).toContain(pageId)
  })
})

test.describe("closePage", () => {
  test("resolves the page from pageManager and closes it", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    // Add a second page to close
    const secondPage = createMockPage()
    context.emit("page", secondPage)
    expect(manager.count).toBe(2)

    await closePage({
      pageManager: manager,
      params: { pageId: "page_1" },
    })

    // The page should be removed from the manager (via the close event)
    expect(manager.count).toBe(1)
    expect(manager.ids).not.toContain("page_1")
  })

  test("calls page.close() on the resolved page", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    await closePage({
      pageManager: manager,
      params: { pageId: "page_1" },
    })

    expect(secondPage.isClosed()).toBe(true)
  })

  test("throws if pageId does not exist", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    await expect(
      closePage({
        pageManager: manager,
        params: { pageId: "nonexistent" },
      }),
    ).rejects.toThrow()
  })

  test("throws when trying to close page_0", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    await expect(
      closePage({
        pageManager: manager,
        params: { pageId: "page_0" },
      }),
    ).rejects.toThrow("Cannot close the initial Flutter page")
  })
})

test.describe("switchToPage", () => {
  test("sets pageManager.activeId to the given pageId", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    await switchToPage({
      pageManager: manager,
      params: { pageId: "page_1" },
    })

    expect(manager.activeId).toBe("page_1")
  })

  test("throws if pageId does not exist", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    await expect(
      switchToPage({
        pageManager: manager,
        params: { pageId: "nonexistent" },
      }),
    ).rejects.toThrow()
  })
})

test.describe("getPages", () => {
  test("returns all page IDs from pageManager.ids", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    const thirdPage = createMockPage()
    context.emit("page", thirdPage)

    const result = await getPages({
      pageManager: manager,
      params: {},
    })

    expect(result.pages).toEqual(expect.arrayContaining(["page_0", "page_1", "page_2"]))
    expect(result.pages).toHaveLength(3)
  })

  test("returns the active page ID from pageManager.activeId", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)
    manager.activeId = "page_1"

    const result = await getPages({
      pageManager: manager,
      params: {},
    })

    expect(result.activePageId).toBe("page_1")
  })
})

test.describe("getCurrentPage", () => {
  test("returns pageManager.activeId (default is page_0)", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const result = await getCurrentPage({
      pageManager: manager,
      params: {},
    })

    expect(result).toBe("page_0")
  })

  test("returns the updated activeId after switching pages", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)
    manager.activeId = "page_1"

    const result = await getCurrentPage({
      pageManager: manager,
      params: {},
    })

    expect(result).toBe("page_1")
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

    const pageId = await waitForPopup({
      pageManager: manager,

      params: {
        triggerAction: "tap",
        triggerParams: { selector: { text: "Open popup" } },
      },
    })

    expect(pageId).toBeDefined()
    expect(typeof pageId).toBe("string")
  })

  test("returns the page ID of the newly appeared popup page", async () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const popupPage = createMockPage()
    setTimeout(() => {
      context.emit("page", popupPage)
    }, 10)

    const pageId = await waitForPopup({
      pageManager: manager,
      params: {
        triggerAction: "tap",
        triggerParams: { selector: { text: "Open popup" } },
      },
    })

    // The popup should be registered and the returned ID should resolve to it
    expect(manager.ids).toContain(pageId)
    expect(manager.resolve(pageId)).toBe(popupPage)
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

    const pageId = await waitForPopup({
      pageManager: manager,
      params: {
        triggerAction: "tap",
        triggerParams: { selector: { text: "Open popup" } },
      },
    })

    expect(manager.count).toBe(countBefore + 1)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(manager.idOf(popupPage as any)).toBe(pageId)
  })
})
