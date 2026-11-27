import { chromium, type FullConfig } from "@playwright/test"
import { initialise } from "./initialise"
import { DartTestEntry, PatrolTestEntry } from "./types"

async function setup(config: FullConfig) {
  const { baseURL, channel, launchOptions, locale, ignoreHTTPSErrors, connectOptions } = config.projects[0].use

  const browser = connectOptions
    ? await chromium.connect(connectOptions.wsEndpoint, {
        exposeNetwork: connectOptions.exposeNetwork,
        timeout: connectOptions.timeout,
        headers: {
          // The same handshake as Playwright's own browser fixture: the server
          // launches the browser with these options. Test discovery always runs
          // headless, like the local launch below.
          "x-playwright-launch-options": jsonStringifyForceAscii({ ...launchOptions, channel, headless: true }),
          ...connectOptions.headers,
        },
      })
    : await chromium.launch({ ...launchOptions, channel })

  const page = await browser.newPage({ locale, ignoreHTTPSErrors })

  if (!baseURL) {
    throw new Error("baseURL is not set")
  }

  const setupPageErrorPromise = new Promise<never>((_, reject) => {
    page.on("pageerror", error => {
      error.message = `Page error during setup: ${error.message}`
      // eslint-disable-next-line no-console
      console.error(error.stack ?? error.message)
      reject(error)
    })
  })

  await page.goto(baseURL)

  await initialise(page)

  try {
    const testEntriesResponse = (await Promise.race([
      page
        .waitForFunction(
          () => {
            // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
            return window.__patrol__getTests?.()!
          },
          undefined,
          { timeout: 120000 },
        )
        .then(v => v.jsonValue()),
      setupPageErrorPromise,
    ])) as { group: DartTestEntry }

    const patrolTests = mapEntry(testEntriesResponse.group)
    process.env.PATROL_TESTS = JSON.stringify(patrolTests)
  } finally {
    await browser.close()
  }
}

// HTTP header values must be ASCII, so escape anything else, like Playwright's
// own jsonStringifyForceASCII does for the same header.
function jsonStringifyForceAscii(value: unknown) {
  return JSON.stringify(value).replace(/[\u007f-\uffff]/g, c => `\\u${c.charCodeAt(0).toString(16).padStart(4, "0")}`)
}

function mapEntry(entry: DartTestEntry, parentName?: string, skip = false, tags = new Set<string>()) {
  const fullEntryName = parentName ? `${parentName} ${entry.name}` : entry.name
  const fullEntrySkip = skip || entry.skip
  const fullEntryTags = new Set([...tags, ...entry.tags.map(tag => `@${tag}`)])

  const tests: PatrolTestEntry[] = []

  if (entry.type === "test") {
    tests.push({
      name: fullEntryName,
      skip: fullEntrySkip,
      tags: [...fullEntryTags],
    })
  }

  tests.push(...entry.entries.flatMap(e => mapEntry(e, fullEntryName, fullEntrySkip, fullEntryTags)))

  return tests
}

export default setup
