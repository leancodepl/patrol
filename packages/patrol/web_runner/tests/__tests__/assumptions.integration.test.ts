import { test, expect } from "@playwright/test"
import { PageManager } from "../pageManager"
import { startTest, downloadedFiles } from "../actions/startTest"

// ---------------------------------------------------------------------------
// Teardown tests
// ---------------------------------------------------------------------------

test("teardown closes secondary pages without errors", async ({ browser }) => {
  const context = await browser.newContext()
  const page = await context.newPage()
  new PageManager(context, page)

  // Open 3 additional pages
  const second = await context.newPage()
  const third = await context.newPage()
  const fourth = await context.newPage()

  expect(context.pages()).toHaveLength(4)

  // Close one manually before teardown to simulate a page that was closed
  // during the test itself
  await third.close()
  expect(context.pages()).toHaveLength(3)

  // Run the exact teardown logic from test.spec.ts
  for (const p of context.pages()) {
    if (p !== page && !p.isClosed()) {
      await p.close().catch(() => {})
    }
  }

  // Only the initial page should remain
  expect(context.pages()).toHaveLength(1)
  expect(context.pages()[0]).toBe(page)

  // The pages we closed should all report as closed
  expect(second.isClosed()).toBe(true)
  expect(third.isClosed()).toBe(true)
  expect(fourth.isClosed()).toBe(true)

  await context.close()
})

test("teardown handles page that was already closed", async ({ browser }) => {
  const context = await browser.newContext()
  const page = await context.newPage()

  // Open a secondary page and immediately close it
  const secondary = await context.newPage()
  await secondary.close()
  expect(secondary.isClosed()).toBe(true)

  // Run teardown — should NOT throw even though secondary is already closed.
  // The isClosed() guard should skip it entirely.
  await expect(
    (async () => {
      for (const p of context.pages()) {
        if (p !== page && !p.isClosed()) {
          await p.close().catch(() => {})
        }
      }
    })(),
  ).resolves.toBeUndefined()

  // Only the initial page remains
  expect(context.pages()).toHaveLength(1)
  expect(context.pages()[0]).toBe(page)

  await context.close()
})

// ---------------------------------------------------------------------------
// Download tracking tests
// ---------------------------------------------------------------------------

test("download in a secondary tab is captured by verifyFileDownloads", async ({ browser }) => {
  const context = await browser.newContext({ acceptDownloads: true })
  const page = await context.newPage()
  new PageManager(context, page)

  // Set up download tracking via startTest
  await startTest(page)

  // Open a secondary page — startTest's context.on('page') listener should
  // register a download listener on it automatically
  const secondPage = await context.newPage()

  // Trigger a download on the secondary page
  await secondPage.setContent(`
    <a href="data:text/plain,hello" download="test-file.txt">Download</a>
  `)

  const [download] = await Promise.all([secondPage.waitForEvent("download"), secondPage.click("a")])

  // Wait for the download to finish so the event handler has fired
  await download.path()

  // Verify that downloadedFiles captured the file from the secondary tab
  expect(downloadedFiles).toContain("test-file.txt")

  await context.close()
})

test("download tracking is cleared between tests", async ({ browser }) => {
  const context = await browser.newContext({ acceptDownloads: true })
  const page = await context.newPage()

  // First call to startTest should clear downloadedFiles
  await startTest(page)
  expect(downloadedFiles).toHaveLength(0)

  // Trigger a download
  await page.setContent(`
    <a href="data:text/plain,hello" download="first-file.txt">Download</a>
  `)

  const [download1] = await Promise.all([page.waitForEvent("download"), page.click("a")])
  await download1.path()

  expect(downloadedFiles).toHaveLength(1)
  expect(downloadedFiles[0]).toBe("first-file.txt")

  // Calling startTest again should clear the list (simulates a new test run)
  await startTest(page)
  expect(downloadedFiles).toHaveLength(0)

  await context.close()
})

// ---------------------------------------------------------------------------
// Binding timing tests
// ---------------------------------------------------------------------------

test("context.exposeBinding works on a page that loaded content BEFORE the binding was set up", async ({
  browser,
}) => {
  const context = await browser.newContext()
  const page = await context.newPage()

  // Navigate to content FIRST — before any binding is registered
  await page.setContent(`
    <button id="test-btn">Click me</button>
  `)

  // THEN set up the binding on the context
  let bindingCalled = false
  let receivedArg: unknown = null
  await context.exposeBinding("testBinding", (_source, arg) => {
    bindingCalled = true
    receivedArg = arg
    return "binding-response"
  })

  // Call the binding from the already-loaded page
  const result = await page.evaluate(async () => {
    return await (window as any).testBinding("hello-from-page")
  })

  expect(bindingCalled).toBe(true)
  expect(receivedArg).toBe("hello-from-page")
  expect(result).toBe("binding-response")

  await context.close()
})

test("context.exposeBinding works on a NEW page created AFTER the binding was set up", async ({ browser }) => {
  const context = await browser.newContext()
  const page = await context.newPage()

  // Set up binding on the context first
  let bindingCalled = false
  let receivedArg: unknown = null
  await context.exposeBinding("testBinding", (_source, arg) => {
    bindingCalled = true
    receivedArg = arg
    return "binding-response-new-page"
  })

  // Create a NEW page after the binding is in place
  const newPage = await context.newPage()

  // Set content on the new page
  await newPage.setContent(`
    <button id="test-btn">Click me</button>
  `)

  // Call the binding from the new page
  const result = await newPage.evaluate(async () => {
    return await (window as any).testBinding("hello-from-new-page")
  })

  expect(bindingCalled).toBe(true)
  expect(receivedArg).toBe("hello-from-new-page")
  expect(result).toBe("binding-response-new-page")

  // Also verify the binding still works on the original page
  bindingCalled = false
  receivedArg = null

  await page.setContent(`<div>original</div>`)
  const resultOriginal = await page.evaluate(async () => {
    return await (window as any).testBinding("hello-from-original")
  })

  expect(bindingCalled).toBe(true)
  expect(receivedArg).toBe("hello-from-original")
  expect(resultOriginal).toBe("binding-response-new-page")

  await context.close()
})
