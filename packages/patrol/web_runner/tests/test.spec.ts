import { test as base } from "@playwright/test"
import { initialise } from "./initialise"
import { logger } from "./logger"
import { PageManager } from "./pageManager"
import { exposePatrolPlatformHandler } from "./patrolPlatformHandler"
import { PatrolTestEntry } from "./types"

const tests: PatrolTestEntry[] = process.env.PATROL_TESTS ? JSON.parse(process.env.PATROL_TESTS) : []
if (tests.length === 0) {
  logger.error("PATROL_TESTS env is empty")
}

export const patrolTest = base.extend({
  page: async ({ page, context }, use) => {
    page.on("console", message => {
      const text = message.text()
      if (text.startsWith("PATROL_LOG")) {
        // eslint-disable-next-line no-console
        console.log(text)
        return
      }

      // eslint-disable-next-line no-console
      console.log(`Playwright: ${text}`)
    })

    await page.goto("/", { waitUntil: "load" })

    const pageManager = new PageManager(context, page)
    await exposePatrolPlatformHandler(context, pageManager)

    await initialise(page)

    await use(page)

    // Teardown: close all secondary pages (not the initial one)
    for (const p of context.pages()) {
      if (p !== page && !p.isClosed()) {
        await p.close().catch(() => {})
      }
    }
  },
})

for (const { name, skip, tags } of tests) {
  patrolTest(name, { tag: tags }, async ({ page }) => {
    patrolTest.skip(skip)

    await page.waitForFunction(() => window.__patrol__runTest, {
      timeout: 300000,
    })

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    await page.evaluate(async name => await window.__patrol__runTest!(name), name)
  })
}
