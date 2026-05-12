import { test, expect, BrowserContext } from "@playwright/test"
import { PageManager } from "../pageManager"
import { openNewPage } from "../actions/openNewPage"
import { closePage } from "../actions/closePage"
import { switchToPage } from "../actions/switchToPage"
import { getPages } from "../actions/getPages"
import { getCurrentPage } from "../actions/getCurrentPage"
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
 * This lets us exercise the full openNewPage code path (newPage + goto)
 * without any real network access.
 */
async function interceptTestRoutes(context: BrowserContext) {
  await context.route("https://test.local/page1", route => {
    route.fulfill({ contentType: "text/html", body: TEST_PAGE_HTML })
  })
  await context.route("https://test.local/page2", route => {
    route.fulfill({ contentType: "text/html", body: TEST_PAGE_2_HTML })
  })
  await context.route("https://test.local/popup-target", route => {
    route.fulfill({ contentType: "text/html", body: POPUP_TARGET_HTML })
  })
}

test("open a new page, switch to it, interact, and switch back", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Open a new page to locally-served content
  const pageId = await openNewPage({ pageManager, params: { url: "https://test.local/page1" } })
  expect(pageId).toBe("page_1")

  // Verify 2 pages exist
  const pagesResult = await getPages({ pageManager, params: {} })
  expect(pagesResult.pages).toHaveLength(2)
  expect(pagesResult.pages).toContain("page_0")
  expect(pagesResult.pages).toContain("page_1")

  // Switch to the new page
  await switchToPage({ pageManager, params: { pageId: "page_1" } })

  // Verify active page is page_1
  const currentPage = await getCurrentPage({ pageManager, params: {} })
  expect(currentPage).toBe("page_1")

  // Verify the new page loaded the local page
  const newPage = pageManager.resolve("page_1")
  await newPage.waitForLoadState("domcontentloaded")
  const heading = await newPage.locator("h1").textContent()
  expect(heading).toContain("Test Page")

  // Switch back to page_0 and verify
  await switchToPage({ pageManager, params: { pageId: "page_0" } })
  const backToPage = await getCurrentPage({ pageManager, params: {} })
  expect(backToPage).toBe("page_0")

  await context.close()
})

test("close a page and verify cleanup", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Open 2 new pages
  await openNewPage({ pageManager, params: { url: "https://test.local/page1" } })
  await openNewPage({ pageManager, params: { url: "https://test.local/page2" } })

  // Verify 3 pages total
  const before = await getPages({ pageManager, params: {} })
  expect(before.pages).toHaveLength(3)
  expect(before.pages).toEqual(expect.arrayContaining(["page_0", "page_1", "page_2"]))

  // Close page_1
  await closePage({ pageManager, params: { pageId: "page_1" } })

  // Verify 2 remain with stable IDs (page_0 and page_2)
  const after = await getPages({ pageManager, params: {} })
  expect(after.pages).toHaveLength(2)
  expect(after.pages).toContain("page_0")
  expect(after.pages).toContain("page_2")
  expect(after.pages).not.toContain("page_1")

  // Verify resolving page_1 throws
  expect(() => pageManager.resolve("page_1")).toThrow(/No page found for page ID "page_1"/)

  await context.close()
})

test("dispatch via handlePatrolPlatformAction routes correctly", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Dispatch openNewPage through the handler
  const pageId = await handlePatrolPlatformAction(pageManager, {
    action: "openNewPage",
    params: { url: "https://test.local/page1" },
  })

  // Verify it returned a page ID and the page was registered
  expect(pageId).toBe("page_1")
  expect(pageManager.count).toBe(2)
  expect(pageManager.ids).toContain("page_1")

  // Verify the new page actually loaded the page
  const newPage = pageManager.resolve("page_1")
  await newPage.waitForLoadState("domcontentloaded")
  const heading = await newPage.locator("h1").textContent()
  expect(heading).toContain("Test Page")

  await context.close()
})

test("pages persist correct content after switching", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Open page_1 to locally-served page
  await openNewPage({ pageManager, params: { url: "https://test.local/page1" } })

  // Switch to page_1 and read the page title
  await switchToPage({ pageManager, params: { pageId: "page_1" } })
  const page1 = pageManager.resolve("page_1")
  await page1.waitForLoadState("domcontentloaded")
  const title = await page1.title()
  expect(title).toContain("Test Page")

  // Switch back to page_0 and verify its URL is still about:blank
  await switchToPage({ pageManager, params: { pageId: "page_0" } })
  const page0 = pageManager.resolve("page_0")
  expect(page0.url()).toBe("about:blank")

  // Switch to page_1 again and verify content is still there
  await switchToPage({ pageManager, params: { pageId: "page_1" } })
  const page1Again = pageManager.resolve("page_1")
  const headingText = await page1Again.locator("h1").textContent()
  expect(headingText).toContain("Test Page")

  await context.close()
})

test("PageManager auto-registers popup from window.open", async ({ browser }) => {
  const context = await browser.newContext()
  await interceptTestRoutes(context)
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Set initial page content with a button that opens a popup to a routed URL
  await page.setContent("<button onclick=\"window.open('https://test.local/popup-target')\">Open</button>")

  // Click the button and wait for the popup to appear
  const [popup] = await Promise.all([context.waitForEvent("page"), page.locator("button").click()])

  // Wait for the popup to finish loading
  await popup.waitForLoadState("domcontentloaded")

  // Verify PageManager has 2 pages
  expect(pageManager.count).toBe(2)

  // Verify the popup page loaded the local content
  const popupId = pageManager.idOf(popup)
  expect(popupId).toBeDefined()
  const popupPage = pageManager.resolve(popupId!)
  const heading = await popupPage.locator("h1").textContent()
  expect(heading).toContain("Popup Target")

  await context.close()
})
