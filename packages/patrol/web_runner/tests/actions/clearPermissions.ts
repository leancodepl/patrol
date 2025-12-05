import { Page } from "playwright"

export async function clearPermissions(page: Page) {
  await page.context().clearPermissions()
}
