import { logger } from "../logger"
import { sleep } from "../utils"
import type { ActionParams, GetClipboardRequest } from "../contracts"

export async function getClipboard({ pageManager }: ActionParams<GetClipboardRequest>): Promise<string> {
  try {
    // we need timeout, because when browser has no permissions to clipboard, it will be waiting for the user to choose an option on dialog
    const result = await Promise.race([pageManager.activePage.evaluate(() => navigator.clipboard.readText()), sleep(1)])

    if (!result) {
      throw new Error("Timeout")
    }

    return result
  } catch (error) {
    logger.error(error, "Clipboard is not available")
    throw error
  }
}
