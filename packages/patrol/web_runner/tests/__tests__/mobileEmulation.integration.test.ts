import { devices, expect, test, type Browser, type BrowserContextOptions } from "@playwright/test"
import { prepareMobileEmulation } from "../mobileEmulation"

const { defaultBrowserType: _pixel, ...pixel7 } = devices["Pixel 7"]
const { defaultBrowserType: _iPhone, ...iPhone15 } = devices["iPhone 15"]

const appURL = "http://patrol.test/"

// The inline script records what the page looks like while it is still being
// parsed, which is when Flutter's bootstrap script would run.
const recordPage = `<script>
  window.whileParsing = {
    width: innerWidth,
    viewportMetas: document.querySelectorAll('meta[name="viewport"]').length,
    platform: navigator.platform,
  }
</script>`
const plainPage = `<html><head></head><body>${recordPage}</body></html>`

async function openContext(browser: Browser, options: BrowserContextOptions, withHelper = true) {
  const context = await browser.newContext(options)
  if (withHelper) {
    await prepareMobileEmulation(context, {
      userAgent: options.userAgent,
      isMobile: options.isMobile,
      baseURL: appURL,
    })
  }

  // Serve every URL from memory: the app's origin and an "external" one.
  await context.route("**/*", route => {
    const url = new URL(route.request().url())
    const pages: Record<string, string> = {
      "/": plainPage,
      "/with-iframe": `<html><head></head><body><iframe src="/"></iframe>${recordPage}</body></html>`,
      "/with-viewport": `<html><head><meta name="viewport" content="width=device-width"></head><body>${recordPage}</body></html>`,
    }
    return route.fulfill({ contentType: "text/html", body: pages[url.pathname] ?? plainPage })
  })

  return context
}

async function whileParsing(browser: Browser, options: BrowserContextOptions, url = appURL, withHelper = true) {
  const context = await openContext(browser, options, withHelper)
  const page = await context.newPage()
  await page.goto(url)
  const result = await page.evaluate(() => window.whileParsing)
  await context.close()
  return result
}

test("without the helper, a mobile page starts about 980 px wide on the host platform", async ({ browser }) => {
  const result = await whileParsing(browser, pixel7, appURL, false)

  // Chromium's default layout width for pages without a viewport tag.
  expect(result?.width).toBeGreaterThanOrEqual(980)
  expect(result?.viewportMetas).toBe(0)
  expect(result?.platform).not.toBe("Linux aarch64")
})

test("adds Flutter's viewport tag to the app before its scripts run", async ({ browser }) => {
  expect(await whileParsing(browser, pixel7)).toEqual({ width: 412, viewportMetas: 1, platform: "Linux aarch64" })
})

test("reports the platform of an emulated iPhone", async ({ browser }) => {
  expect(await whileParsing(browser, iPhone15)).toEqual({ width: 393, viewportMetas: 1, platform: "iPhone" })
})

test("keeps a viewport tag the app already has", async ({ browser }) => {
  const context = await openContext(browser, pixel7)
  const page = await context.newPage()
  await page.goto(`${appURL}with-viewport`)

  expect(await page.evaluate(() => window.whileParsing)).toEqual({
    width: 412,
    viewportMetas: 1,
    platform: "Linux aarch64",
  })
  expect(await page.locator('meta[name="viewport"]').getAttribute("content")).toBe("width=device-width")

  await context.close()
})

test("prepares pages opened later in the same context", async ({ browser }) => {
  const context = await openContext(browser, pixel7)
  await (await context.newPage()).goto(appURL)

  const second = await context.newPage()
  await second.goto(appURL)

  expect(await second.evaluate(() => window.whileParsing)).toEqual({
    width: 412,
    viewportMetas: 1,
    platform: "Linux aarch64",
  })

  await context.close()
})

test("leaves the viewport of other sites alone", async ({ browser }) => {
  const result = await whileParsing(browser, pixel7, "http://other-site.test/")

  expect(result?.width).toBeGreaterThanOrEqual(980)
  expect(result?.viewportMetas).toBe(0)
  // The platform is the phone's on every site, as on a real phone.
  expect(result?.platform).toBe("Linux aarch64")
})

test("leaves the viewport of frames inside the app alone", async ({ browser }) => {
  const context = await openContext(browser, pixel7)
  const page = await context.newPage()
  await page.goto(`${appURL}with-iframe`)

  const frame = page.frames().find(f => f !== page.mainFrame())
  await expect.poll(() => frame?.evaluate(() => window.whileParsing?.viewportMetas)).toBe(0)
  expect(await page.evaluate(() => window.whileParsing?.viewportMetas)).toBe(1)

  await context.close()
})

test("sets the platform from a mobile user agent without mobile mode", async ({ browser }) => {
  const result = await whileParsing(browser, { ...iPhone15, isMobile: false })

  expect(result?.platform).toBe("iPhone")
  expect(result?.viewportMetas).toBe(0)
})

test("does nothing for a desktop browser", async ({ browser }) => {
  const context = await openContext(browser, {})
  expect(await context.newPage().then(p => p.evaluate(() => navigator.platform))).not.toBe("Linux aarch64")
  const page = await context.newPage()
  await page.goto(appURL)
  expect(await page.evaluate(() => window.whileParsing?.viewportMetas)).toBe(0)
  await context.close()
})

declare global {
  interface Window {
    whileParsing?: { width: number; viewportMetas: number; platform: string }
  }
}
