import { Page } from "playwright"

export async function getClipboard(page: Page): Promise<string> {
  return await page.evaluate(() => navigator.clipboard.readText())
}
