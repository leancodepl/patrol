import { Page } from "playwright"
import { logger } from "../logger"

export async function disableDarkMode(page: Page) {
  await page.emulateMedia({ colorScheme: "no-preference" })
  logger.info("Dark mode disabled")
}
