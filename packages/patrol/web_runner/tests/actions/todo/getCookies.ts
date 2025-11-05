import { Page } from "playwright"

export async function getCookies(page: Page) {
  return await page.context().cookies()
}
