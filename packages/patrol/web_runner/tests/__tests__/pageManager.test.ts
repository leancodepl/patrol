import { test, expect } from "@playwright/test"
import { EventEmitter } from "events"
import { PageManager } from "../pageManager"

// ---------------------------------------------------------------------------
// Lightweight mocks for Playwright's Page and BrowserContext.
// These use Node's EventEmitter so we can simulate 'close', 'crash', and
// 'page' events without spinning up a real browser.
// ---------------------------------------------------------------------------

function createMockPage(): MockPage {
  const emitter = new EventEmitter()
  return Object.assign(emitter, {
    on: emitter.on.bind(emitter),
    off: emitter.off.bind(emitter),
    once: emitter.once.bind(emitter),
    removeListener: emitter.removeListener.bind(emitter),
    isClosed: () => false,
  }) as MockPage
}

type MockPage = EventEmitter & {
  on: EventEmitter["on"]
  off: EventEmitter["off"]
  once: EventEmitter["once"]
  removeListener: EventEmitter["removeListener"]
  isClosed: () => boolean
}

function createMockContext(): MockContext {
  const emitter = new EventEmitter()
  return Object.assign(emitter, {
    on: emitter.on.bind(emitter),
    off: emitter.off.bind(emitter),
    once: emitter.once.bind(emitter),
    removeListener: emitter.removeListener.bind(emitter),
  }) as MockContext
}

type MockContext = EventEmitter & {
  on: EventEmitter["on"]
  off: EventEmitter["off"]
  once: EventEmitter["once"]
  removeListener: EventEmitter["removeListener"]
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test.describe("PageManager", () => {
  test("initial state: constructor registers the initial page as tab_0, sets it as active, count = 1", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    expect(manager.activeId).toBe("tab_0")
    expect(manager.count).toBe(1)
    expect(manager.ids).toEqual(["tab_0"])
  })

  test("resolve() with no args returns the active page", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const resolved = manager.resolve()
    expect(resolved).toBe(initialPage)
  })

  test("resolve() with a valid tabId returns the correct page", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const resolved = manager.resolve("tab_0")
    expect(resolved).toBe(initialPage)
  })

  test("resolve() with an invalid tabId throws an error", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    expect(() => manager.resolve("nonexistent")).toThrow()
  })

  test("activeId setter: switching to a valid tab updates activeId", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    // Simulate a new page opening
    const secondPage = createMockPage()
    context.emit("page", secondPage)

    manager.activeId = "tab_1"
    expect(manager.activeId).toBe("tab_1")
  })

  test("activeId setter with invalid ID throws an error", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    expect(() => {
      manager.activeId = "nonexistent"
    }).toThrow()
  })

  test("auto-registration: new page from context event is registered as tab_1 with incremented count", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    expect(manager.count).toBe(2)
    expect(manager.ids).toContain("tab_1")
    expect(manager.resolve("tab_1")).toBe(secondPage)
  })

  test("page close cleanup: when a page closes, it is removed from the registry", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)
    expect(manager.count).toBe(2)

    // Simulate the second page closing
    secondPage.emit("close")

    expect(manager.count).toBe(1)
    expect(manager.ids).not.toContain("tab_1")
  })

  test("page crash cleanup: when a page crashes, it is removed from the registry", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)
    expect(manager.count).toBe(2)

    // Simulate the second page crashing
    secondPage.emit("crash")

    expect(manager.count).toBe(1)
    expect(manager.ids).not.toContain("tab_1")
  })

  test("closing active tab: if the active tab closes, active switches to tab_0 (initial page)", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    // Switch to the second tab, then close it
    manager.activeId = "tab_1"
    expect(manager.activeId).toBe("tab_1")

    secondPage.emit("close")

    expect(manager.activeId).toBe("tab_0")
  })

  test("stable IDs: closing tab_1 when tab_2 exists does not change tab_2 ID", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    const thirdPage = createMockPage()
    context.emit("page", thirdPage)

    expect(manager.count).toBe(3)
    expect(manager.ids).toEqual(expect.arrayContaining(["tab_0", "tab_1", "tab_2"]))

    // Close tab_1 — tab_2 must keep its ID
    secondPage.emit("close")

    expect(manager.count).toBe(2)
    expect(manager.ids).toContain("tab_0")
    expect(manager.ids).toContain("tab_2")
    expect(manager.ids).not.toContain("tab_1")
    expect(manager.resolve("tab_2")).toBe(thirdPage)
  })

  test("ids: returns all currently tracked tab IDs", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    expect(manager.ids).toEqual(["tab_0"])

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    const thirdPage = createMockPage()
    context.emit("page", thirdPage)

    expect(manager.ids).toEqual(expect.arrayContaining(["tab_0", "tab_1", "tab_2"]))
    expect(manager.ids).toHaveLength(3)
  })

  test("idOf: returns the ID for a given Page instance", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(manager.idOf(initialPage as any)).toBe("tab_0")

    const secondPage = createMockPage()
    context.emit("page", secondPage)

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(manager.idOf(secondPage as any)).toBe("tab_1")
  })

  test("idOf: returns undefined for an untracked Page instance", () => {
    const context = createMockContext()
    const initialPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    const manager = new PageManager(context as any, initialPage as any)

    const unknownPage = createMockPage()

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    expect(manager.idOf(unknownPage as any)).toBeUndefined()
  })
})
