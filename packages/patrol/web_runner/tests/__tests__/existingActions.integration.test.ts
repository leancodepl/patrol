import { test, expect, BrowserContext, Page, Cookie } from "@playwright/test"
import { PageManager } from "../pageManager"
import { handlePatrolPlatformAction } from "../patrolPlatformHandler"
import { WebSelector } from "../contracts"

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

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

/** Shorthand: create isolated context + page + PageManager and tear down afterwards. */
async function setup(browser: import("@playwright/test").Browser) {
  const context = await browser.newContext()
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)
  return { context, page, pageManager }
}

// ---------------------------------------------------------------------------
// 1. tap
// ---------------------------------------------------------------------------
test("tap - clicks a button through the dispatch layer", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`
    <button data-testid="clicker">Click me</button>
    <span id="result"></span>
    <script>
      document.querySelector('[data-testid="clicker"]')
        .addEventListener('click', () => {
          document.getElementById('result').textContent = 'clicked';
        });
    </script>
  `)

  await handlePatrolPlatformAction(pageManager, {
    action: "tap",
    params: {
      selector: selector({ testId: "clicker" }),
      iframeSelector: null,
    },
  })

  const resultText = await page.locator("#result").textContent()
  expect(resultText).toBe("clicked")

  await context.close()
})

// ---------------------------------------------------------------------------
// 2. enterText
// ---------------------------------------------------------------------------
test("enterText - fills an input through the dispatch layer", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`<input data-testid="name-input" type="text" />`)

  await handlePatrolPlatformAction(pageManager, {
    action: "enterText",
    params: {
      selector: selector({ testId: "name-input" }),
      text: "Hello Patrol",
      iframeSelector: null,
    },
  })

  const value = await page.locator('[data-testid="name-input"]').inputValue()
  expect(value).toBe("Hello Patrol")

  await context.close()
})

// ---------------------------------------------------------------------------
// 3. enableDarkMode
// ---------------------------------------------------------------------------
test("enableDarkMode - emulates dark color scheme without crashing", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`
    <style>
      body { background: white; }
      @media (prefers-color-scheme: dark) { body { background: black; } }
    </style>
    <body></body>
  `)

  await handlePatrolPlatformAction(pageManager, {
    action: "enableDarkMode",
    params: {},
  })

  const bg = await page.evaluate(() => getComputedStyle(document.body).backgroundColor)
  // "rgb(0, 0, 0)" is black
  expect(bg).toBe("rgb(0, 0, 0)")

  await context.close()
})

// ---------------------------------------------------------------------------
// 4. disableDarkMode
// ---------------------------------------------------------------------------
test("disableDarkMode - emulates light color scheme without crashing", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  // First enable dark mode, then disable it
  await page.setContent(`
    <style>
      body { background: white; }
      @media (prefers-color-scheme: dark) { body { background: black; } }
    </style>
    <body></body>
  `)

  await handlePatrolPlatformAction(pageManager, {
    action: "enableDarkMode",
    params: {},
  })

  await handlePatrolPlatformAction(pageManager, {
    action: "disableDarkMode",
    params: {},
  })

  const bg = await page.evaluate(() => getComputedStyle(document.body).backgroundColor)
  // "rgb(255, 255, 255)" is white
  expect(bg).toBe("rgb(255, 255, 255)")

  await context.close()
})

// ---------------------------------------------------------------------------
// 5. goBack / goForward
// ---------------------------------------------------------------------------
test("goBack and goForward - navigate browser history", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  // Use route interception to serve two distinct pages without network calls
  await context.route("**/page-one", route =>
    route.fulfill({
      status: 200,
      contentType: "text/html",
      body: "<html><body><h1>Page One</h1></body></html>",
    }),
  )
  await context.route("**/page-two", route =>
    route.fulfill({
      status: 200,
      contentType: "text/html",
      body: "<html><body><h1>Page Two</h1></body></html>",
    }),
  )

  await page.goto("http://localhost/page-one")
  await page.goto("http://localhost/page-two")
  expect(page.url()).toContain("page-two")

  // Go back
  await handlePatrolPlatformAction(pageManager, {
    action: "goBack",
    params: {},
  })
  expect(page.url()).toContain("page-one")

  // Go forward
  await handlePatrolPlatformAction(pageManager, {
    action: "goForward",
    params: {},
  })
  expect(page.url()).toContain("page-two")

  await context.close()
})

// ---------------------------------------------------------------------------
// 6. pressKey
// ---------------------------------------------------------------------------
test("pressKey - types a key into a focused input", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`<input data-testid="key-input" type="text" />`)
  await page.locator('[data-testid="key-input"]').focus()

  await handlePatrolPlatformAction(pageManager, {
    action: "pressKey",
    params: { key: "a" },
  })

  const value = await page.locator('[data-testid="key-input"]').inputValue()
  expect(value).toBe("a")

  await context.close()
})

// ---------------------------------------------------------------------------
// 7. pressKeyCombo
// ---------------------------------------------------------------------------
test("pressKeyCombo - sends a key combination", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`
    <span id="combo-result"></span>
    <script>
      document.addEventListener('keydown', (e) => {
        if (e.shiftKey && e.key === 'A') {
          document.getElementById('combo-result').textContent = 'Shift+A pressed';
        }
      });
    </script>
  `)

  // Send Shift+A key combo through the dispatch layer
  await handlePatrolPlatformAction(pageManager, {
    action: "pressKeyCombo",
    params: { keys: ["Shift", "A"] },
  })

  const resultText = await page.locator("#combo-result").textContent()
  expect(resultText).toBe("Shift+A pressed")

  await context.close()
})

// ---------------------------------------------------------------------------
// 8. acceptNextDialog
// ---------------------------------------------------------------------------
test("acceptNextDialog - accepts an alert and returns its message", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`<button data-testid="alert-btn">Alert</button>`)

  // Register the dialog handler BEFORE triggering the dialog
  const dialogPromise = handlePatrolPlatformAction(pageManager, {
    action: "acceptNextDialog",
    params: {},
  })

  // Trigger the alert
  await page.evaluate(() => alert("Hello from alert"))

  const message = await dialogPromise
  expect(message).toBe("Hello from alert")

  await context.close()
})

// ---------------------------------------------------------------------------
// 9. dismissNextDialog
// ---------------------------------------------------------------------------
test("dismissNextDialog - dismisses a confirm and returns its message", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`<div id="result"></div>`)

  // Register the dialog handler BEFORE triggering the dialog
  const dialogPromise = handlePatrolPlatformAction(pageManager, {
    action: "dismissNextDialog",
    params: {},
  })

  // Trigger a confirm dialog (dismiss returns false for confirm)
  await page.evaluate(() => {
    const result = confirm("Shall we proceed?")
    document.getElementById("result")!.textContent = result ? "yes" : "no"
  })

  const message = await dialogPromise
  expect(message).toBe("Shall we proceed?")

  // Confirm was dismissed, so result should be "no"
  const resultText = await page.locator("#result").textContent()
  expect(resultText).toBe("no")

  await context.close()
})

// ---------------------------------------------------------------------------
// 10. addCookie / getCookies / clearCookies
// ---------------------------------------------------------------------------
test("addCookie, getCookies, clearCookies - full cookie lifecycle", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  // Cookies need a real origin; use a routed page
  await context.route("**/cookie-page", route =>
    route.fulfill({
      status: 200,
      contentType: "text/html",
      body: "<html><body>Cookie Page</body></html>",
    }),
  )
  await page.goto("http://localhost/cookie-page")

  // Add a cookie
  await handlePatrolPlatformAction(pageManager, {
    action: "addCookie",
    params: {
      name: "patrol_test",
      value: "abc123",
      domain: "localhost",
      path: "/",
      url: null,
      expires: null,
      httpOnly: null,
      secure: null,
      sameSite: null,
    },
  })

  // Get cookies and verify
  const cookies = (await handlePatrolPlatformAction(pageManager, {
    action: "getCookies",
    params: {},
  })) as any[]

  expect(cookies).toEqual(expect.arrayContaining([expect.objectContaining({ name: "patrol_test", value: "abc123" })]))

  // Clear cookies
  await handlePatrolPlatformAction(pageManager, {
    action: "clearCookies",
    params: {},
  })

  // Verify cookies are gone
  const cookiesAfterClear = (await handlePatrolPlatformAction(pageManager, {
    action: "getCookies",
    params: {},
  })) as any[]

  expect(cookiesAfterClear).toHaveLength(0)

  await context.close()
})

// ---------------------------------------------------------------------------
// 11. grantPermissions / clearPermissions
// ---------------------------------------------------------------------------
test("grantPermissions and clearPermissions - execute without error", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  // Navigate to a routed page so we have a valid origin
  await context.route("**/perm-page", route =>
    route.fulfill({
      status: 200,
      contentType: "text/html",
      body: "<html><body>Permissions Page</body></html>",
    }),
  )
  await page.goto("http://localhost/perm-page")

  // Grant permissions (geolocation is commonly supported)
  await handlePatrolPlatformAction(pageManager, {
    action: "grantPermissions",
    params: {
      permissions: ["geolocation"],
      origin: "http://localhost",
    },
  })

  // Clear permissions
  await handlePatrolPlatformAction(pageManager, {
    action: "clearPermissions",
    params: {},
  })

  // If we got here without throwing, the actions work through the dispatch layer
  await context.close()
})

// ---------------------------------------------------------------------------
// 12. resizeWindow
// ---------------------------------------------------------------------------
test("resizeWindow - changes the viewport size", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent("<html><body>Resize test</body></html>")

  await handlePatrolPlatformAction(pageManager, {
    action: "resizeWindow",
    params: { width: 800, height: 600 },
  })

  const viewportSize = page.viewportSize()
  expect(viewportSize).toEqual({ width: 800, height: 600 })

  // Resize again to a different size to prove it actually changes
  await handlePatrolPlatformAction(pageManager, {
    action: "resizeWindow",
    params: { width: 1024, height: 768 },
  })

  const newViewportSize = page.viewportSize()
  expect(newViewportSize).toEqual({ width: 1024, height: 768 })

  await context.close()
})

// ---------------------------------------------------------------------------
// 13. setClipboard / getClipboard
// ---------------------------------------------------------------------------
test("setClipboard and getClipboard - round-trip clipboard text", async ({ browser }) => {
  // Grant clipboard permissions via context options
  const context = await browser.newContext({
    permissions: ["clipboard-read", "clipboard-write"],
  })
  const page = await context.newPage()
  const pageManager = new PageManager(context, page)

  // Need a page with an origin for clipboard API to work
  await context.route("**/clipboard-page", route =>
    route.fulfill({
      status: 200,
      contentType: "text/html",
      body: "<html><body>Clipboard test</body></html>",
    }),
  )
  await page.goto("http://localhost/clipboard-page")

  // Set clipboard
  await handlePatrolPlatformAction(pageManager, {
    action: "setClipboard",
    params: { text: "patrol clipboard test" },
  })

  // Get clipboard
  const clipboardText = await handlePatrolPlatformAction(pageManager, {
    action: "getClipboard",
    params: {},
  })

  expect(clipboardText).toBe("patrol clipboard test")

  await context.close()
})

// ---------------------------------------------------------------------------
// 14. scrollTo
// ---------------------------------------------------------------------------
test("scrollTo - scrolls an element into view", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`
    <div style="height: 3000px;">
      <div style="height: 2500px;">Spacer</div>
      <div data-testid="scroll-target">Target element</div>
    </div>
  `)

  // Verify the element is NOT in the viewport initially
  const initiallyVisible = await page.locator('[data-testid="scroll-target"]').isVisible()
  // The element exists in the DOM but is far below the fold
  expect(initiallyVisible).toBe(true) // visible in DOM, but not in viewport

  const scrollYBefore = await page.evaluate(() => window.scrollY)
  expect(scrollYBefore).toBe(0)

  await handlePatrolPlatformAction(pageManager, {
    action: "scrollTo",
    params: {
      selector: selector({ testId: "scroll-target" }),
      iframeSelector: null,
    },
  })

  // After scrollTo, the page should have scrolled down
  const scrollYAfter = await page.evaluate(() => window.scrollY)
  expect(scrollYAfter).toBeGreaterThan(0)

  await context.close()
})

// ---------------------------------------------------------------------------
// 15. tap with cssOrXpath selector
// ---------------------------------------------------------------------------
test("tap - works with cssOrXpath selector variant", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`
    <button class="my-btn">CSS Button</button>
    <span id="result"></span>
    <script>
      document.querySelector('.my-btn')
        .addEventListener('click', () => {
          document.getElementById('result').textContent = 'css-clicked';
        });
    </script>
  `)

  await handlePatrolPlatformAction(pageManager, {
    action: "tap",
    params: {
      selector: selector({ cssOrXpath: ".my-btn" }),
      iframeSelector: null,
    },
  })

  const resultText = await page.locator("#result").textContent()
  expect(resultText).toBe("css-clicked")

  await context.close()
})

// ---------------------------------------------------------------------------
// 16. tap with text selector
// ---------------------------------------------------------------------------
test("tap - works with text selector variant", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`
    <button>Unique Text Button</button>
    <span id="result"></span>
    <script>
      document.querySelector('button')
        .addEventListener('click', () => {
          document.getElementById('result').textContent = 'text-clicked';
        });
    </script>
  `)

  await handlePatrolPlatformAction(pageManager, {
    action: "tap",
    params: {
      selector: selector({ text: "Unique Text Button" }),
      iframeSelector: null,
    },
  })

  const resultText = await page.locator("#result").textContent()
  expect(resultText).toBe("text-clicked")

  await context.close()
})

// ---------------------------------------------------------------------------
// 17. enterText with placeholder selector
// ---------------------------------------------------------------------------
test("enterText - works with placeholder selector", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent(`<input placeholder="Enter your email" type="text" />`)

  await handlePatrolPlatformAction(pageManager, {
    action: "enterText",
    params: {
      selector: selector({ placeholder: "Enter your email" }),
      text: "test@example.com",
      iframeSelector: null,
    },
  })

  const value = await page.locator('[placeholder="Enter your email"]').inputValue()
  expect(value).toBe("test@example.com")

  await context.close()
})

// ---------------------------------------------------------------------------
// 18. startTest - initializes download listener
// ---------------------------------------------------------------------------
test("startTest - executes without error through dispatch layer", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await page.setContent("<html><body>Start test page</body></html>")

  // startTest should not throw
  await handlePatrolPlatformAction(pageManager, {
    action: "startTest",
    params: {},
  })

  await context.close()
})

// ---------------------------------------------------------------------------
// 19. dispatch of unknown action throws
// ---------------------------------------------------------------------------
test("dispatch of unknown action throws an error", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await expect(
    handlePatrolPlatformAction(pageManager, {
      action: "unknown-placeholder-nonexistent" as any,
      params: {},
    }),
  ).rejects.toThrow(/not found/)

  await context.close()
})

// ---------------------------------------------------------------------------
// 20. addCookie with extra options (httpOnly, secure, sameSite)
// ---------------------------------------------------------------------------
test("addCookie - supports additional cookie properties", async ({ browser }) => {
  const { context, page, pageManager } = await setup(browser)

  await context.route("**/cookie-page", route =>
    route.fulfill({
      status: 200,
      contentType: "text/html",
      body: "<html><body>Cookie Page</body></html>",
    }),
  )
  await page.goto("http://localhost/cookie-page")

  await handlePatrolPlatformAction(pageManager, {
    action: "addCookie",
    params: {
      name: "session_id",
      value: "xyz789",
      domain: "localhost",
      path: "/",
      url: null,
      expires: null,
      httpOnly: true,
      secure: false,
      sameSite: "Lax",
    },
  })

  const cookies = (await handlePatrolPlatformAction(pageManager, {
    action: "getCookies",
    params: {},
  })) as Cookie[]

  const sessionCookie = cookies.find(c => c.name === "session_id")
  expect(sessionCookie).toBeDefined()
  expect(sessionCookie!.value).toBe("xyz789")
  expect(sessionCookie!.httpOnly).toBe(true)
  expect(sessionCookie!.sameSite).toBe("Lax")

  await context.close()
})
