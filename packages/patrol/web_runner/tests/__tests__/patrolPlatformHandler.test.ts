import { test, expect } from "@playwright/test"
import { EventEmitter } from "events"
import { exposePatrolPlatformHandler, handlePatrolPlatformAction } from "../patrolPlatformHandler"
import { PageManager } from "../pageManager"
import type { PatrolNativeRequest } from "../contracts"

// ---------------------------------------------------------------------------
// Lightweight mocks — same EventEmitter pattern as pageManager.test.ts
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
    exposeBinding: (async () => {}) as MockContext["exposeBinding"],
  }) as MockContext
}

type MockContext = EventEmitter & {
  on: EventEmitter["on"]
  off: EventEmitter["off"]
  once: EventEmitter["once"]
  removeListener: EventEmitter["removeListener"]
  exposeBinding: (name: string, callback: (...args: unknown[]) => unknown) => Promise<void>
}

// ---------------------------------------------------------------------------
// Helper: build a PageManager with mock objects
// ---------------------------------------------------------------------------

function buildPageManager() {
  const context = createMockContext()
  const initialPage = createMockPage()

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const manager = new PageManager(context as any, initialPage as any)

  return { context, initialPage, manager }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

test.describe("patrolPlatformHandler", () => {
  // -------------------------------------------------------------------------
  // 1. exposePatrolPlatformHandler calls context.exposeBinding
  // -------------------------------------------------------------------------

  test("exposePatrolPlatformHandler calls context.exposeBinding with '__patrol__platformHandler'", async () => {
    const { context, manager } = buildPageManager()

    let boundName: string | undefined
    let boundCallback: ((...args: unknown[]) => unknown) | undefined

    context.exposeBinding = async (name: string, callback: (...args: unknown[]) => unknown) => {
      boundName = name
      boundCallback = callback
    }

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    await exposePatrolPlatformHandler(context as any, manager)

    expect(boundName).toBe("__patrol__platformHandler")
    expect(typeof boundCallback).toBe("function")
  })

  // -------------------------------------------------------------------------
  // 2. handlePatrolPlatformAction dispatches to the correct action
  // -------------------------------------------------------------------------

  test("handlePatrolPlatformAction dispatches to the correct action with the active page", async () => {
    const { initialPage, manager } = buildPageManager()

    // Replace enableDarkMode with a spy so we can verify the page and params
    const actionsModule = await import("../actions")
    const originalAction = actionsModule.actions.enableDarkMode

    let receivedPage: unknown
    let receivedParams: unknown

      // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ;(actionsModule.actions as any).enableDarkMode = async (page: unknown, params: unknown) => {
      receivedPage = page
      receivedParams = params
    }

    const request: PatrolNativeRequest = {
      action: "enableDarkMode",
      params: {},
    }

    try {
      // For the RED phase: this will fail because handlePatrolPlatformAction
      // currently takes (page: Page, request) instead of (pageManager, request).
      await handlePatrolPlatformAction(manager, request)
    } finally {
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ;(actionsModule.actions as any).enableDarkMode = originalAction
    }

    // The handler should resolve the active page from PageManager and pass it
    // to the action function
    expect(receivedPage).toBe(initialPage)
    expect(receivedParams).toEqual({})
  })

  // -------------------------------------------------------------------------
  // 3. handlePatrolPlatformAction throws for unknown action
  // -------------------------------------------------------------------------

  test("handlePatrolPlatformAction throws for an unknown action", async () => {
    const { manager } = buildPageManager()

    const request = {
      action: "unknown-placeholder-nonexistent",
      params: {},
    } as PatrolNativeRequest

    await expect(handlePatrolPlatformAction(manager, request)).rejects.toThrow(/not found/i)
  })

  // -------------------------------------------------------------------------
  // 4. handlePatrolPlatformAction strips pageId from params before passing
  //    to the action function
  // -------------------------------------------------------------------------

  test("handlePatrolPlatformAction strips pageId from params before passing to the action", async () => {
    const { context, manager } = buildPageManager()

    // Add a second page so page_1 is valid
    const secondPage = createMockPage()
    context.emit("page", secondPage)

    let capturedParams: unknown

    // Replace enableDarkMode with a spy that captures the params it receives.
    // This lets us verify that pageId (a routing concern) is stripped before
    // the action function sees the params.
    const actionsModule = await import("../actions")
    const originalAction = actionsModule.actions.enableDarkMode

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    ;(actionsModule.actions as any).enableDarkMode = async (_page: unknown, params: unknown) => {
      capturedParams = params
    }

    const request: PatrolNativeRequest = {
      action: "enableDarkMode",
      params: { _routeToPage: "page_1" },
    }

    try {
      await handlePatrolPlatformAction(manager, request)
    } finally {
      // Restore original action
      // eslint-disable-next-line @typescript-eslint/no-explicit-any
      ;(actionsModule.actions as any).enableDarkMode = originalAction
    }

    // pageId is a routing concern — it must NOT leak into action params
    expect(capturedParams).toBeDefined()
    expect(capturedParams).not.toHaveProperty("pageId")
  })
})
