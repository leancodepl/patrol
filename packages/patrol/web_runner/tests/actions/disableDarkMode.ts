import { Page } from "playwright"
import { logger } from "../logger"

export async function disableDarkMode(page: Page) {
  await page.emulateMedia({ colorScheme: "light" })
  logger.info("Dark mode disabled")
}
