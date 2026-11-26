import { test as base } from "@playwright/test"
import { startCoverage, stopAndSaveCoverage } from "./coverage"
import { initialise } from "./initialise"
import { logger } from "./logger"
import { PageManager } from "./pageManager"
import { exposePatrolPlatformHandler } from "./patrolPlatformHandler"
import { PatrolTestEntry } from "./types"
import { DartTestProgress, trackDartTestProgress, unreportedFailureLines } from "./unreportedTests"

const tests: PatrolTestEntry[] = process.env.PATROL_TESTS ? JSON.parse(process.env.PATROL_TESTS) : []
if (tests.length === 0) {
  logger.error("PATROL_TESTS env is empty")
}

// A worker runs one test at a time, so one progress object per worker is enough. It is reset
// after each test (and Playwright starts a new worker after a failed test).
let dartTestProgress: DartTestProgress = { started: false, finished: false }

export const patrolTest = base.extend({
  page: async ({ page, context }, use, testInfo) => {
    page.on("console", message => {
      const text = message.text()
      if (text.startsWith("PATROL_LOG")) {
        trackDartTestProgress(text, dartTestProgress)
        // eslint-disable-next-line no-console
        console.log(text)
        return
      }

      // eslint-disable-next-line no-console
      console.log(`Playwright: ${text}`)
    })

    await startCoverage(page)

    await page.goto("/", { waitUntil: "load" })

    const pageManager = new PageManager(context, page)
    await exposePatrolPlatformHandler(context, pageManager)

    await initialise(page)

    await use(page)

    await stopAndSaveCoverage(page, testInfo)

    // Teardown: close all secondary pages (not the initial one)
    for (const p of context.pages()) {
      if (p !== page && !p.isClosed()) {
        await p.close().catch(() => {})
      }
    }
  },
})

// Runs also when the page fixture fails or the test times out before the Dart test reports a
// result. Report such a test as failed, so Patrol's summary counts it.
patrolTest.afterEach(({}, testInfo) => {
  const test = tests.find(({ name }) => name === testInfo.title) ?? { name: testInfo.title, skip: false }
  for (const line of unreportedFailureLines(test, dartTestProgress, testInfo)) {
    // eslint-disable-next-line no-console
    console.log(line)
  }
  dartTestProgress = { started: false, finished: false }
})

for (const { name, skip, tags } of tests) {
  patrolTest(name, { tag: tags }, async ({ page }) => {
    patrolTest.skip(skip)

    await page.waitForFunction(() => window.__patrol__runTest, undefined, {
      timeout: 300000,
    })

    // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
    const result = await page.evaluate(async name => await window.__patrol__runTest!(name), name)
    if (result?.result === "failure") {
      throw new Error(result.details ?? `Test "${name}" failed`)
    }
  })
}
