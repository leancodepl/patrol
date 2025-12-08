import { Page } from "playwright"

export async function goBack(page: Page) {
  await page.goBack()
}
