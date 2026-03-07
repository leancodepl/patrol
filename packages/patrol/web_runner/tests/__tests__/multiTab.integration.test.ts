import { test, expect, BrowserContext } from "@playwright/test"
import { PageManager } from "../pageManager"
import { openNewTab } from "../actions/openNewTab"
import { closeTab } from "../actions/closeTab"
import { switchToTab } from "../actions/switchToTab"
import { getTabs } from "../actions/getTabs"
import { getCurrentTab } from "../actions/getCurrentTab"
import { handlePatrolPlatformAction } from "../patrolPlatformHandler"

// Local HTML content served via route interception — no network access needed.
const TEST_PAGE_HTML = `<!DOCTYPE html>
<html><head><title>Test Page</title></head>
<body><h1>Test Page</h1><p>Local content for integration tests.</p></body></html>`

const TEST_PAGE_2_HTML = `<!DOCTYPE html>
<html><head><title>Second Page</title></head>
<body><h1>Second Page</h1><p>Another local page.</p></body></html>`

const POPUP_TARGET_HTML = `<!DOCTYPE html>
<html><head><title>Popup Target</title></head>
<body><h1>Popup Target</h1><p>Opened via window.open().</p></body></html>`

/**
 * Intercept all requests to https://test.local/** and serve local HTML.
 * This lets us exercise the full openNewTab code path (newPage + goto)
 * without any real network access.
 */
async function interceptTestRoutes(context: BrowserContext) {
  await context.route("https://test.local/page1", (route) => {
    route.fulfill({ contentType: "text/html", body: TEST_PAGE_HTML })
  })
  await context.route("https://test.local/page2", (route) => {
    route.fulfill({ contentType: "text/html", body: TEST_PAGE_2_HTML })
  })
  await context.route("https://test.local/popup-target", (route) => {
    route.fulfill({ contentType: "text/html", body: POPUP_TARGET_HTML })
  })
}

test("open a new tab, switch to it, interact, and switch back", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Open a new tab to locally-served page
  const tabId = await openNewTab(page, { url: "https://test.local/page1" }, pageManager, context)
  expect(tabId).toBe("tab_1")

  // Verify 2 tabs exist
  const tabsResult = await getTabs(page, {} as Record<string, never>, pageManager)
  expect(tabsResult.tabs).toHaveLength(2)
  expect(tabsResult.tabs).toContain("tab_0")
  expect(tabsResult.tabs).toContain("tab_1")

  // Switch to the new tab
  await switchToTab(page, { tabId: "tab_1" }, pageManager)

  // Verify active tab is tab_1
  const currentTab = await getCurrentTab(page, {} as Record<string, never>, pageManager)
  expect(currentTab).toBe("tab_1")

  // Verify the new tab loaded the local page
  const newPage = pageManager.resolve("tab_1")
  await newPage.waitForLoadState("domcontentloaded")
  const heading = await newPage.locator("h1").textContent()
  expect(heading).toContain("Test Page")

  // Switch back to tab_0 and verify
  await switchToTab(page, { tabId: "tab_0" }, pageManager)
  const backToTab = await getCurrentTab(page, {} as Record<string, never>, pageManager)
  expect(backToTab).toBe("tab_0")

  await context.close()
})

test("close a tab and verify cleanup", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Open 2 new tabs
  await openNewTab(page, { url: "https://test.local/page1" }, pageManager, context)
  await openNewTab(page, { url: "https://test.local/page2" }, pageManager, context)

  // Verify 3 tabs total
  const before = await getTabs(page, {} as Record<string, never>, pageManager)
  expect(before.tabs).toHaveLength(3)
  expect(before.tabs).toEqual(expect.arrayContaining(["tab_0", "tab_1", "tab_2"]))

  // Close tab_1
  await closeTab(page, { tabId: "tab_1" }, pageManager)

  // Verify 2 remain with stable IDs (tab_0 and tab_2)
  const after = await getTabs(page, {} as Record<string, never>, pageManager)
  expect(after.tabs).toHaveLength(2)
  expect(after.tabs).toContain("tab_0")
  expect(after.tabs).toContain("tab_2")
  expect(after.tabs).not.toContain("tab_1")

  // Verify resolving tab_1 throws
  expect(() => pageManager.resolve("tab_1")).toThrow(/No page found for tab ID "tab_1"/)

  await context.close()
})

test("dispatch via handlePatrolPlatformAction routes correctly", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Dispatch openNewTab through the handler
  const tabId = await handlePatrolPlatformAction(pageManager, {
    action: "openNewTab",
    params: { url: "https://test.local/page1" },
  })

  // Verify it returned a tab ID and the tab was registered
  expect(tabId).toBe("tab_1")
  expect(pageManager.count).toBe(2)
  expect(pageManager.ids).toContain("tab_1")

  // Verify the new tab actually loaded the page
  const newPage = pageManager.resolve("tab_1")
  await newPage.waitForLoadState("domcontentloaded")
  const heading = await newPage.locator("h1").textContent()
  expect(heading).toContain("Test Page")

  await context.close()
})

test("tabs persist correct content after switching", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Open tab_1 to locally-served page
  await openNewTab(page, { url: "https://test.local/page1" }, pageManager, context)

  // Switch to tab_1 and read the page title
  await switchToTab(page, { tabId: "tab_1" }, pageManager)
  const tab1Page = pageManager.resolve("tab_1")
  await tab1Page.waitForLoadState("domcontentloaded")
  const title = await tab1Page.title()
  expect(title).toContain("Test Page")

  // Switch back to tab_0 and verify its URL is still about:blank
  await switchToTab(page, { tabId: "tab_0" }, pageManager)
  const tab0Page = pageManager.resolve("tab_0")
  expect(tab0Page.url()).toBe("about:blank")

  // Switch to tab_1 again and verify content is still there
  await switchToTab(page, { tabId: "tab_1" }, pageManager)
  const tab1PageAgain = pageManager.resolve("tab_1")
  const headingText = await tab1PageAgain.locator("h1").textContent()
  expect(headingText).toContain("Test Page")

  await context.close()
})

test("PageManager auto-registers popup from window.open", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Set initial page content with a button that opens a popup to a routed URL
  await page.setContent('<button onclick="window.open(\'https://test.local/popup-target\')">Open</button>')

  // Click the button and wait for the popup to appear
  const [popup] = await Promise.all([
    context.waitForEvent("page"),
    page.locator("button").click(),
  ])

  // Wait for the popup to finish loading
  await popup.waitForLoadState("domcontentloaded")

  // Verify PageManager has 2 tabs
  expect(pageManager.count).toBe(2)

  // Verify the popup page loaded the local content
  const popupId = pageManager.idOf(popup)
  expect(popupId).toBeDefined()
  const popupPage = pageManager.resolve(popupId!)
  const heading = await popupPage.locator("h1").textContent()
  expect(heading).toContain("Popup Target")

  await context.close()
})
