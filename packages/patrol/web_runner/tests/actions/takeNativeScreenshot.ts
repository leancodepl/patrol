import { test } from "@playwright/test"
import type { ActionParams, TakeNativeScreenshotRequest } from "../contracts"

// Mirrors the Android implementation: the caller-supplied tag is sanitized so it
// can't escape the output directory, and a timestamp prefix keeps repeated tags
// from overwriting each other.
export async function takeNativeScreenshot({ pageManager, params }: ActionParams<TakeNativeScreenshotRequest>) {
  const testInfo = test.info()
  const safeTag = params.tag.replace(/[^A-Za-z0-9._-]/g, "_")

  // outputPath() resolves inside the per-test directory under PATROL_TEST_RESULTS_DIR,
  // so screenshots end up next to Playwright's own traces, videos and failure screenshots.
  const path = testInfo.outputPath("screenshots", `${Date.now()}_${safeTag}.png`)

  await pageManager.activePage.screenshot({ path })
  await testInfo.attach(safeTag, { path, contentType: "image/png" })

  return path
}
