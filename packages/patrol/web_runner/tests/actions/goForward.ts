import { Page } from "playwright"

export async function goForward(page: Page) {
  await page.goForward()
}
