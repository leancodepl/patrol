import { Page } from "playwright"

export async function clearCookies(page: Page) {
  await page.context().clearCookies()
}
