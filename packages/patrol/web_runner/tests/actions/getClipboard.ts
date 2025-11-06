import { Page } from "playwright"
import { logger } from "../logger"
import { sleep } from "../utils"

export async function getClipboard(page: Page): Promise<string | null> {
  try {
    return await Promise.race([page.evaluate(() => navigator.clipboard.readText()), sleep(1)])
  } catch (error) {
    logger.error(error, "Clipboard is not available")
    return null
  }
}
