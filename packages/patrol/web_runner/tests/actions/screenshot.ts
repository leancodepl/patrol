import * as fs from "fs"
import * as path from "path"
import { Page } from "playwright"
import { ScreenshotRequest } from "../contracts"

export async function screenshot(page: Page, params: ScreenshotRequest["params"]) {
  const dir = path.dirname(params.path)
  if (dir && !fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true })
  }
  await page.screenshot({ path: params.path })
}
