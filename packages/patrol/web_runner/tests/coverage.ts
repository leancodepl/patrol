import * as fs from "node:fs/promises"
import * as path from "path"
import { Page, TestInfo } from "@playwright/test"
import { logger } from "./logger"

// Set by patrol_cli for `patrol test --coverage` on web. When present, raw V8
// coverage (plus source maps) is written here as one JSON file per test, which
// the CLI later converts into an LCOV report.
const coverageDir = process.env.PATROL_COVERAGE_DIR

export async function startCoverage(page: Page): Promise<void> {
  if (!coverageDir) {
    return
  }

  try {
    // resetOnNavigation: false keeps initial-load coverage across navigation.
    await page.coverage.startJSCoverage({ resetOnNavigation: false })
  } catch (error) {
    logger.error(`Failed to start JS coverage collection: ${error}`)
  }
}

export async function stopAndSaveCoverage(page: Page, testInfo: TestInfo): Promise<void> {
  if (!coverageDir) {
    return
  }

  try {
    const entries = await page.coverage.stopJSCoverage()

    const scripts: CoverageScriptEntry[] = (
      await Promise.all(
        entries.map(async ({ url, scriptId, source, functions }) => {
          if (!url || !source) {
            return null
          }

          const sourceMap = await fetchSourceMap(page, url, source)

          return sourceMap ? { url, scriptId, source, sourceMap, functions } : null
        }),
      )
    ).filter(s => !!s)

    if (scripts.length === 0) {
      logger.warn(`No source-mapped scripts in JS coverage for test "${testInfo.title}"`)
      return
    }

    await fs.mkdir(coverageDir, { recursive: true })
    // testId is stable across retries, so a retry overwrites the failed
    // attempt instead of double-counting.
    await fs.writeFile(path.join(coverageDir, `${testInfo.testId}.json`), JSON.stringify({ entries: scripts }))
  } catch (error) {
    logger.error(`Failed to collect JS coverage: ${error}`)
  }
}

type CoverageScriptEntry = {
  url: string
  scriptId: string
  source: string
  sourceMap: string
  functions: unknown
}

async function fetchSourceMap(page: Page, scriptUrl: string, source: string): Promise<string | null> {
  // The last sourceMappingURL comment wins, matching browser behavior. Anchored
  // to the line so a `sourceMappingURL=` inside a string literal can't false-match.
  const matches = [...source.matchAll(/^[ \t]*\/\/[#@][ \t]*sourceMappingURL=(\S+)[ \t]*$/gm)]
  const mapUrl = matches.at(-1)?.[1]
  if (!mapUrl) {
    return null
  }

  try {
    if (mapUrl.startsWith("data:")) {
      const response = await fetch(mapUrl)
      return response.ok ? await response.text() : null
    }

    const response = await page.request.get(new URL(mapUrl, scriptUrl).toString())
    return response.ok() ? await response.text() : null
  } catch {
    return null
  }
}
