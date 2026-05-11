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
import { tap } from "../actions/tap"
import { WebSelector } from "../contracts"

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

  let pageRef: any = null
  function mockLocator() {
    const locator = {
      click: async () => {},
      and: (other: any) => locator,
      contentFrame: () => pageRef,
    }
    return locator
  }

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
    // Minimal Playwright-like selector helpers used by parseWebSelector
    getByTestId: (_: string) => mockLocator(),
    getByRole: (_: string) => mockLocator(),
    getByLabel: (_: string) => mockLocator(),
    getByPlaceholder: (_: string) => mockLocator(),
    getByText: (_: string) => mockLocator(),
    getByAltText: (_: string) => mockLocator(),
    getByTitle: (_: string) => mockLocator(),
    locator: (_: string) => mockLocator(),
  }) as MockPage

  pageRef = page

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

/** Build a full WebSelector with only the specified fields set; all others null. */
function selector(overrides: Partial<WebSelector>): WebSelector {
  return {
    role: null,
    label: null,
    placeholder: null,
    text: null,
    altText: null,
    title: null,
    testId: null,
    cssOrXpath: null,
    ...overrides,
  }
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
    ).rejects.toThrow("Cannot close the main Flutter page")
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

    const pageIdPromise = waitForPopup({
      pageManager: manager,
      params: {},
    })

    await tap({
      pageManager: manager,
      params: {
        selector: selector({ text: "Open popup" }),
        iframeSelector: null,
      },
    })

    const pageId = await pageIdPromise

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

    const pageIdPromise = waitForPopup({
      pageManager: manager,
      params: {},
    })

    await tap({
      pageManager: manager,
      params: {
        selector: selector({ text: "Open popup" }),
        iframeSelector: null,
      },
    })

    const pageId = await pageIdPromise

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

    const pageIdPromise = waitForPopup({
      pageManager: manager,
      params: {},
    })

    await tap({
      pageManager: manager,
      params: {
        selector: selector({ text: "Open popup" }),
        iframeSelector: null,
      },
    })

    const pageId = await pageIdPromise

    expect(manager.count).toBe(countBefore + 1)
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(manager.idOf(popupPage as any)).toBe(pageId)
  })
})
