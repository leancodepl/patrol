import { Page } from "playwright"
import { logger } from "../logger"

export async function enableDarkMode(page: Page) {
  await page.emulateMedia({ colorScheme: "dark" })
  logger.info("Dark mode enabled")
}
