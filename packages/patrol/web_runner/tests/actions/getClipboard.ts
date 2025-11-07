import { Page } from "playwright"
import { logger } from "../logger"
import { sleep } from "../utils"

export async function getClipboard(page: Page): Promise<string> {
  try {
    // we need timeout, because when browser has no permissions to clipboard, it will be waiting for the user to choose an option on dialog
    const result = await Promise.race([page.evaluate(() => navigator.clipboard.readText()), sleep(1)])

    if (!result) {
      throw new Error("Timeout")
    }

    return result
  } catch (error) {
    logger.error(error, "Clipboard is not available")
    throw error
  }
}
