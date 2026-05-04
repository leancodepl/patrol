import { Page } from "playwright"
import { ScreenshotRequest } from "../contracts"

export async function screenshot(page: Page, params: ScreenshotRequest["params"]) {
  await page.screenshot({ path: params.path })
}
